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

sh ./decrypt-swarmpit-files.sh

set -a
. "./shared.env"
set +a

# TODO: add more validations, it is only verifying some possible issues
# TODO: remove dependency on docker-compose
docker-compose -f docker-compose.verify-preconditions.yml -f docker-compose.yml config > /dev/null
