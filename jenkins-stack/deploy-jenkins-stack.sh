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
    echo "Usage: sh deploy-jenkins-stack.sh [OPTIONS]"
    echo ""
    echo "Deploy current folder's files into a Docker stack"
    echo ""
    echo "Options:"
    echo "  -e, --environment (\"test\"|\"prod\") (mandatory)"
    echo "  -h, --help"
    echo
    echo "Examples:"
    echo "  deploy-jenkins-stack.sh -e=prod"
    echo "  deploy-jenkins-stack.sh -e=test"
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
    echo "Error: environment parameter value should be int, qa or prod"
    print_help
    exit 1
fi

sh ./decrypt-jenkins-files.sh -e="${environment}"

set -a
. "./${environment}.env"
. "./_post.env"
set +a

envsubst < ./casc_configs/jenkins-base.template.yaml > "${CASC_CONFIGS__JENKINS_BASE_FILE}"

set -a
. "./_post-hash-files.env"
set +a

docker stack deploy \
    --with-registry-auth \
    --compose-file docker-compose.yml \
    "jenkins-${environment}"
