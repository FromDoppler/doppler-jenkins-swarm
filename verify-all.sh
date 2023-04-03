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
    echo "Usage: sh verify-all.sh [OPTIONS]"
    echo ""
    echo "Verify all definition files."
    echo ""
    echo "Options:"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh verify-all.sh"
}

for i in "$@" ; do
case $i in
    -h|--help)
    print_help
    exit 0
    ;;
esac
done

sh ./host-setup/verify-host-setup.sh
sh ./traefik-stack/verify-traefik-stack.sh
sh ./swarmpit-stack/verify-swarmpit-stack.sh
sh ./jenkins-stack/verify-jenkins-stack.sh
