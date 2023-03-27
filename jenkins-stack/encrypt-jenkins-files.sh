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
    echo "Usage: sh decrypt-jenkins-files.sh [OPTIONS]"
    echo ""
    echo "Encrypt Stack's files using SOPS"
    echo ""
    echo "Options:"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  sh decrypt-jenkins-files.sh"
}

for i in "$@" ; do
case $i in
    -h|--help)
    print_help
    exit 0
    ;;
esac
done

encryptedProperties="^(password|clientSecret|value|privateKey|secret)$"

sops \
  --encrypted-regex "${encryptedProperties}" \
  --output "./casc_configs/jenkins-base.encrypted.secret.shared.yaml" \
  --encrypt "./casc_configs/jenkins-base.secret.shared.yaml"
sops \
  --encrypted-regex "${encryptedProperties}" \
  --output "./casc_configs/jenkins-test.encrypted.secret.shared.yaml" \
  --encrypt "./casc_configs/jenkins-test.secret.shared.yaml"
sops \
  --encrypted-regex "${encryptedProperties}" \
  --output "./casc_configs/jenkins-prod.encrypted.secret.shared.yaml" \
  --encrypt "./casc_configs/jenkins-prod.secret.shared.yaml"
