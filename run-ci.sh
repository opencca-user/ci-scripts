#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

#
# $0 <PROJ_ROOT/> <script_to_run.sh>
# Script will prepare /opencca mount environment for docker container
# - opencca-build mounted
# - snapshot directory created
#

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <proj_root> <script_to_run>"
    exit 1
fi

PROJ_ROOT=$(realpath "${1:-.}")
SCRIPT_TO_RUN=$(realpath "$2")
SNAPSHOT_DIR="$PROJ_ROOT/snapshot"

if [[ ! -d "$PROJ_ROOT" ]]; then
    echo "Error: Project root '$PROJ_ROOT' not found."
    exit 1
fi

if [[ ! -f "$SCRIPT_TO_RUN" ]]; then
    echo "Error: Script '$SCRIPT_TO_RUN' not found."
    exit 1
fi

cd $PROJ_ROOT

rm -r "$SNAPSHOT_DIR" || true
mkdir -p "$SNAPSHOT_DIR"

BUILD_REPO=https://github.com/opencca-user/docker-image-test.git
BUILD_DIRNAME=opencca-build
BUILD_REPO_DIR="$PROJ_ROOT/$BUILD_DIRNAME"

echo ""
echo "Fetching build environment..."

if [[ ! -d "$BUILD_REPO_DIR" ]]; then
    git clone --depth 1 "$BUILD_REPO" "$BUILD_REPO_DIR"
else 
    echo "Updating build repo..."
    cd "$BUILD_REPO_DIR"
    git fetch origin
    git reset --hard origin/opencca/main
fi

cd "$BUILD_REPO_DIR/docker"

echo ""
echo "Pulling docker image..."
make pull

echo ""
echo "Starting container..."
make start

echo ""
echo "Running script in container: $SCRIPT_TO_RUN"
make run-script SCRIPT="$SCRIPT_TO_RUN"