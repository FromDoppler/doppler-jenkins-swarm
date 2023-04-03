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
    echo "Usage: sh encrypt-swarmpit-files.sh [OPTIONS]"
    echo ""
    echo "Encrypt files using SOPS"
    echo ""
    echo "Options:"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh encrypt-swarmpit-files.sh"
}

for i in "$@" ; do
case $i in
    -h|--help)
    print_help
    exit 0
    ;;
esac
done

sops --output "./cd-helper/appsettings.Encrypted.Secret.shared.json" \
  --encrypt "./cd-helper/appsettings.Secret.shared.json"
