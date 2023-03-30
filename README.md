# Doppler Jenkins Swarm

This repository has the configuration as code of our Jenkins service.

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
   sh /swarm-cd/deploy-test-stacks.sh
   sh /swarm-cd/deploy-prod-stacks.sh
   ```

## Initial host setup

TODO: complete this section.
