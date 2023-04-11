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
    echo "Usage: sh verify-host-setup.sh [OPTIONS]"
    echo ""
    echo "Verify host setup files."
    echo ""
    echo "Options:"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh verify-host-setup.sh"
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

expectedFiles="\
  ./ssh/id_rsa.secret.shared \
  ./ssh/known_hosts \
  ./ssh/id_rsa.pub \
  ./aws/config \
  ./aws/credentials.secret.shared \
  ./docker/config.secret.shared.json"
for expectedFile in ${expectedFiles}; do
  if ! [ -f "${expectedFile}" ]; then
    echo "Error: ${expectedFile} does not exist."
    exit 1
  fi
done
