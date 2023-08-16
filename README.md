# Doppler Jenkins Swarm

This repository has the configuration as code of our Jenkins service.

## ⚠️ Caution

Some changes in the jobs definition ([jenkins-base.template.yaml](./jenkins-stack/casc_configs/jenkins-base.template.yaml))
does not impact in the inner repositories jobs. In that cases, removing the organization folder and
run the scripts again (See [#how-to-use-it](#how-to-use-it)) could work.

**When the organization folder is scanned for the first time (because we have removed it or in a pristine installation),
it is important to pay attention to the builds because it can run deploys of tags already deployed.**

## How to use it

Note: _See [Initial host setup section](#initial-host-setup) if you are setting up it in a new server._

1. Connect to the Jenkins service host using SSH and update `/swarm-cd` clone to the desired version:

   ```shell
   cd /swarm-cd
   git fetch
   git reset --hard origin/main
   ```

2. Run desired scripts:

   ```shell
   sh /swarm-cd/update-host-configuration.sh
   sh /swarm-cd/deploy-shared-stacks.sh
   sh /swarm-cd/deploy-test-stacks.sh
   sh /swarm-cd/deploy-prod-stacks.sh
   ```

## Initial host setup

### Install software dependencies

We need git, docker and sops.

```shell
apt-get update
apt-get install \
   ca-certificates \
   curl \
   gnupg \
   git \
   rsync

# See https://docs.docker.com/engine/install/debian/
# shellcheck disable=SC2174
# because /etc/apt should already exists
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
   | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

# shellcheck disable=SC1091
# because we expect /etc/os-release exists on the host
echo \
   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

chmod a+r /etc/apt/keyrings/docker.gpg

apt-get update
apt-get install \
   docker-ce \
   docker-ce-cli \
   containerd.io \
   docker-buildx-plugin \
   docker-compose-plugin

# Install SOPS
curl -fsSL \
   https://github.com/mozilla/sops/releases/download/v3.7.3/sops_3.7.3_amd64.deb \
   > sops.deb

dpkg -i ./sops.deb
```

### Clone repository

All files will to setup and update the host and docker stacks will be at `/swarm-cd`
linked to the [doppler-jenkins-swarm](https://github.com/FromDoppler/doppler-jenkins-swarm/)
GitHub repository.

```shell
git clone \
   --branch main \
   --single-branch https://github.com/FromDoppler/doppler-jenkins-swarm/ \
   /swarm-cd
```

### Setup PGP keys

It will allow us to use decrypt the configuration files.

1. Import the public keys

   ```shell
   sh /swarm-cd/sops/import-dev-pub-key.sh
   sh /swarm-cd/sops/import-prod-pub-key.sh
   ```

2. Import development private key.

   Download or create `/swarm-cd/sops/Development.priv.key` with the right content, see
   [documentation](https://makingsense.atlassian.net/wiki/spaces/DOP/pages/79175790/Secretos+encriptados+con+SOPS).

   ```shell
   nano /swarm-cd/sops/Development.priv.key
   sh /swarm-cd/sops/import-dev-priv-key.sh
   rm /swarm-cd/sops/Development.priv.key
   ```

3. Import production private key.

   Download or create `/swarm-cd/sops/Production.priv.key` with the right content, see
   [documentation](https://makingsense.atlassian.net/wiki/spaces/DOP/pages/79175790/Secretos+encriptados+con+SOPS).

   ```shell
   nano /swarm-cd/sops/Production.priv.key
   sh /swarm-cd/sops/import-prod-priv-key.sh
   rm /swarm-cd/sops/Production.priv.key
   ```

### Create Swarm

Swarm will be responsible to run our docker containers and keep them up.

1. Create the swarm. If there are more than a IP address you can use the `--advertise-addr` parameter.

   ```shell
   docker swarm init
   ```

2. Set the flag `safevolumes=true`. It is required to ensure to store persistent data in only one node.

   ```shell
   # to get the node id
   docker node ls

   docker node update --label-add safevolumes=true {node id}
   ```

## Clean up wasted space and minimal state backup

`docker system prune --all` is not enough to avoid a leak of the space, `prune` does not clean all the unused docker objects.

Ideally, we could clean up all the disk structure and start from the beginning with this repository, but it will lose the build history and Jenkins' state. It is stored in the named volumes, currently, we have these:

- `/var/lib/docker/volumes/jenkins-prod_jenkins-data`
- `/var/lib/docker/volumes/jenkins-test_jenkins-data`
- `/var/lib/docker/volumes/swarmpit_db-data`
- `/var/lib/docker/volumes/swarmpit_influx-data`
- `/var/lib/docker/volumes/traefik_traefik-acme`

So, it is possible to back up those folders, start the server again from a pristine status, restore the folders, and start docker.

To quickly clean up Docker objects, this process is not so complete, but it is easier and it works:

```shell
# Having an empty folder is a precondition for the optimized cleanup
# rm -rf /empty/ && mkdir -p /empty/
systemctl stop docker.socket
rsync -a --delete /empty/ /var/lib/docker/overlay2/
rsync -a --delete /empty/ /var/lib/docker/containers/
rsync -a --delete /empty/ /var/lib/docker/image/
systemctl start docker.socket
docker system prune --all
sh /swarm-cd/deploy-shared-stacks.sh
sh /swarm-cd/deploy-test-stacks.sh
sh /swarm-cd/deploy-prod-stacks.sh
```
