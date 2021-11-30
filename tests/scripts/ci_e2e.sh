#!/bin/bash

# Copyright 2018 Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
ROOT="$( cd -P "$( dirname "$SOURCE" )/../.." && pwd )"

# Exit immediately for non zero status
set -e
set -u
set -x



MILVUS_HELM_RELEASE_NAME="${MILVUS_HELM_RELEASE_NAME:-milvus-testing}"
MILVUS_CLUSTER_ENABLED="${MILVUS_CLUSTER_ENABLED:-false}"
MILVUS_HELM_NAMESPACE="${MILVUS_HELM_NAMESPACE:-default}"
PARALLEL_NUM="${PARALLEL_NUM:-6}"
MILVUS_CLIENT="${MILVUS_CLIENT:-pymilvus}"
CI_LOG_PATH=/tmp/ci_logs/test
MILVUS_SERVICE_NAME=$(echo "${MILVUS_HELM_RELEASE_NAME}-milvus.milvus-ci" | tr -d '\n')
MILVUS_SERVICE_PORT="19530"

# shellcheck source=build/lib.sh
source "${ROOT}/build/lib.sh"


# shellcheck source=ci-util.sh
source "${ROOT}/tests/scripts/ci-util.sh"


cd ${ROOT}/tests/python_client
python3 -V
if [ ! -d "${CI_LOG_PATH}" ]; then
mkdir -p ${CI_LOG_PATH}
fi
trace "prepare e2e test"  install_pytest_requirements  

if [[ -n "${TEST_TIMEOUT:-}" ]]; then
  timeout  "${TEST_TIMEOUT}" pytest --host ${MILVUS_SERVICE_NAME} --port ${MILVUS_SERVICE_PORT} \
                                      --html=${CI_LOG_PATH}/report.html  --self-contained-html ${@:-}
else
  pytest --host ${MILVUS_SERVICE_NAME} --port ${MILVUS_SERVICE_PORT} \
                                      --html=${CI_LOG_PATH}/report.html --self-contained-html ${@:-}
fi