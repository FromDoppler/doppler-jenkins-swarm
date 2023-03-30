#!/bin/sh

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
set -u

# Lines added to get the script running in the script path shell context
# reference: http://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/
cd "$(dirname "$0")"

# To avoid issues with MINGW and Git Bash, see:
# https://github.com/docker/toolbox/issues/673
# https://gist.github.com/borekb/cb1536a3685ca6fc0ad9a028e6a959e3
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

print_help () {
    echo ""
    echo "Usage: sh setup-host.sh [OPTIONS]"
    echo ""
    echo "Prepare host for the Doppler Jenkins Swarm."
    echo ""
    echo "It requires SOPS installed with our private keys."
    echo ""
    echo "Options:"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh setup-host.sh"
}

for i in "$@" ; do
case $i in
    -h|--help)
    print_help
    exit 0
    ;;
esac
done

sh ./decrypt-host-setup-files.sh

# Install ssh keys to allow to upload to our CDN
sshPath="/var/lib/jenkins/.ssh"
chmod 600 ./ssh/id_rsa.secret.shared
mkdir -p  "${sshPath}"
cp -n ./ssh/id_rsa.pub "${sshPath}"
cp -n ./ssh/known_hosts "${sshPath}"
mv -n ./ssh/id_rsa.secret.shared "${sshPath}/id_rsa"

# Docker login
dockerPath="/root/.docker"
chmod 600 ./docker/config.secret.shared.json
mkdir -p "${dockerPath}"
mv -n ./docker/config.secret.shared.json "${dockerPath}"/config.json
