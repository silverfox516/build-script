#!/bin/bash

BS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export BS_PRJ=kvim3_android
BS_DIR_TARGETS=${BS_DIR}/${BS_PRJ}/targets
BS_DIR_MODELS=${BS_DIR}/${BS_PRJ}/models
BS_JOBS="-j12"

source ${BS_DIR}/scripts/setup.sh
