#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

#
# XXX: This runs inside opencca-build environment
#

PRE_RUN_DIR=$PWD
cd $SCRIPT_DIR

# XXX: /opencca in container
PROJECT_ROOT=/opencca
SNAPSHOT_DIR=$PROJECT_ROOT/snapshot
BUILD_DIR=$PROJECT_ROOT/opencca-build
UBOOT_DIR=$PROJECT_ROOT/uboot

clone_repo() {
    local dir="$1"
    local repo="$2"
    local branch="$3"

    if [[ ! -d "$dir" ]]; then
        git clone --depth 1 --branch "$branch" --recurse-submodules "$repo" "$dir"
    else
        cd "$dir" || exit 1
        git fetch origin "$branch"
        git reset --hard "origin/$branch"
        git submodule update --init --recursive
    fi
}



#
# XXX: We are building u-boot with a openca/main version of tfa and rmm
#      so we get a functional artifact
#
TFA_REPO=https://github.com/opencca/opencca-assets.git
TFA_REPO_BRANCH=opencca/main
TFA_DIR=$PROJECT_ROOT/opencca-assets
clone_repo "$TFA_DIR" "$TFA_REPO" "$TFA_REPO_BRANCH"

#
# build firmware
#
cd $BUILD_DIR/buildconf

export LOG=50
export DEBUG=1
export ENABLE_OPENCCA_PERF=1

./firmware_opencca.mk build



ls -al $SNAPSHOT_DIR
