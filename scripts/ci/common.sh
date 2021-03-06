#!/usr/bin/env bash
# for details about how it works see https://github.com/elastic/apm-integration-testing#continuous-integration

function stopEnv() {
  make stop-env
}

function runTests() {
  targets=""
  if [ -z "${REUSE_CONTAINERS}" ]; then
    trap "stopEnv" EXIT
    targets="destroy-env"
  fi
  targets="${targets} $@"
  export VENV=${VENV:-${TMPDIR:-/tmp/}venv-$$}
  make ${targets}
}

if [ -n "${APM_SERVER_BRANCH}" ]; then
 BUILD_OPTS="${BUILD_OPTS} --apm-server-build https://github.com/elastic/apm-server.git@${APM_SERVER_BRANCH}"
fi

if [ -z "${DISABLE_BUILD_PARALLEL}" ]; then
 BUILD_OPTS="${BUILD_OPTS} --build-parallel"
fi

ELASTIC_STACK_VERSION=${ELASTIC_STACK_VERSION:-'master'}

# assume we're under CI if BUILD_NUMBER is set
if [ -n "${BUILD_NUMBER}" ]; then
  # kill any running containers under CI
  docker ps -aq | xargs -t docker rm -f || true
fi
