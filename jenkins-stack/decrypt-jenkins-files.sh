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

environment=""

print_help () {
    echo ""
    echo "Usage: sh decrypt-jenkins-files.sh [OPTIONS]"
    echo ""
    echo "Decrypt environment's files using SOPS"
    echo ""
    echo "Options:"
    echo "  -e, --environment (\"test\"|\"prod\") (mandatory)"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh decrypt-jenkins-files.sh -e=prod"
    echo "  sh decrypt-jenkins-files.sh -e=test"
}

for i in "$@" ; do
case $i in
    -e=*|--environment=*)
    environment="${i#*=}"
    ;;
    -h|--help)
    print_help
    exit 0
    ;;
esac
done

if [ -z "${environment}" ]; then
    echo "Error: environment parameter is mandatory"
    print_help
    exit 1
fi

if [ "${environment}" != "test" ] && [ "${environment}" != "prod" ]; then
    echo "Error: environment parameter value should be test or prod"
    print_help
    exit 1
fi

sops \
  --output "./casc_configs/jenkins-base.secret.shared.yaml" \
  --decrypt "./casc_configs/jenkins-base.encrypted.secret.shared.yaml"
sops \
  --output "./casc_configs/jenkins-${environment}.secret.shared.yaml" \
  --decrypt "./casc_configs/jenkins-${environment}.encrypted.secret.shared.yaml"
