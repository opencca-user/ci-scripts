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
DEBIAN_OUT=$SNAPSHOT_DIR/debian

rm -r $DEBIAN_OUT || true
mkdir -p $DEBIAN_OUT

cd $BUILD_DIR/buildconf

./debos_rootfs_host.mk build DEBIAN_RELEASE_DIR=$DEBIAN_OUT

ls -al $SNAPSHOT_DIR



