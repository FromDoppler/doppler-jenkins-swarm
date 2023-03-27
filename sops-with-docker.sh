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

# default value
gpgdata=~/gnupg

print_help () {
    echo ""
    echo "Usage: sh sops-with-docker.sh [OPTIONS]"
    echo ""
    echo "Start a docker container in interactive mode with GPG and SOPS ready to be used"
    echo ""
    echo "Options:"
    echo "  -d, --gpgdata (optional, '${gpgdata}' by default, absolute path required)"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh sops-with-docker.sh -d=/var/secure/gnupg"
    echo "  sh sops-with-docker.sh"
}

for i in "$@" ; do
case $i in
    -d=*|--gpgdata=*)
    gpgdata="${i#*=}"
    ;;
    -h|--help)
    print_help
    exit 0
    ;;
esac
done

docker run --rm -it \
    -v "$(pwd)":/work \
    -v "/${gpgdata}":/root/.gnupg \
    -w /work \
    mozilla/sops:latest
