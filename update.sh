#!/bin/bash
# shellcheck disable=SC1091

# @file .common/update.sh
# @brief Ensures the project is up-to-date with the latest upstream changes
# @description
#   This script performs maintenance on this repository. It includes several bash script
#   libraries and then it:
#
#   1. Ensures Node, jq, and Task are installed
#   2. Bootstraps the project by using Task to run initialization tasks which bootstrap the project
#   3. Notifies the user about missing software dependencies that require root priviledges to install

set -eo pipefail

source "./.common/scripts/common.sh"
source "./.common/scripts/log.sh"
source "./.common/scripts/software.sh"
source "./.common/scripts/notices.sh"

if [ "${container:=}" != 'docker' ]; then
  info "Ensuring Node.js, Task, jq, and yq are installed"
  ensureNodeSetup &
  ensureJQInstalled &
  ensureTaskInstalled &
  wait
  success "Node.js, Task, and jq are all installed"
fi

task common:update:all

if [ "${container:=}" != 'docker' ]; then
  missingDockerNotice
  missingVirtualBoxNotice
fi
