# OpenCCA CI Scripts

This repository stores the build and workflow scripts to run a CI builder for OpenCCA.

## Runner Setup
We use a stock Ubuntu LTS image.

**Dependencies:**
```
docker
kvm (must have user access to /dev/kvm)
make
git
repo
```

All jobs pull opencca-build and run the payload inside the opencca-build docker image.

## Commit Builds

For selected repositories and branches, we build artifacts upon new commits.
We follow these conventions:

- Do not clutter a forked repository. Only include a minimal workflow that calls a workflow in this repository.
- The workflows can optionally create temporary build artifacts that are kept in the job for 90 days. However, we use a dedicated release job for a snapshot release.
- The build jobs are stored in `.github/workflows/build-*.yml`. They are included in the source repositories workflow file.


Example: Opencca's kvmtool includes a workflow as follows:
```yml
name: opencca-build

permissions:
  contents: write

on:
  push:
    branches: [opencca/main, opencca/systex25, opencca/next]
  workflow_dispatch:

jobs:
  trigger-external:
    uses: opencca/ci-scripts/.github/workflows/build-kvmtool.yml@opencca/main
    with:
      branch: ${{ github.ref_name }}
    secrets:
      RELEASES_REPO_TOKEN: ${{ secrets.RELEASES_REPO_TOKEN }}

# RELEASES_REPO_TOKEN is a secret to gain write access to opencca-releases
# Currently the build workflows do not commit to releases. So this is not needed.
```

**CI Jobs:**
| Name          | Repository                                                                        | Workflow File                                              | Job                                                                                                                                                                                                    |
| ------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Build Linux   | [`opencca/linux`](https://github.com/opencca/linux)                               | [`build-linux.yml`](.github/workflows/build-linux.yml)     | [![opencca-build](https://github.com/opencca/linux/actions/workflows/opencca-build.yml/badge.svg)](https://github.com/opencca/linux/actions/workflows/opencca-build.yml)                               |
| Build U-Boot   | [`opencca/u-boot`](https://github.com/opencca/u-boot)                             | [`build-u-boot.yml`](.github/workflows/build-u-boot.yml)   | [![opencca-build](https://github.com/opencca/u-boot/actions/workflows/opencca-build.yml/badge.svg)](https://github.com/opencca/u-boot/actions/workflows/opencca-build.yml)                             |
| Build TF-RMM  | [`opencca/tf-rmm`](https://github.com/opencca/tf-rmm)                             | [`build-tf-rmm.yml`](.github/workflows/build-tf-rmm.yml)   | [![opencca-build](https://github.com/opencca/tf-rmm/actions/workflows/opencca-build.yml/badge.svg)](https://github.com/opencca/tf-rmm/actions/workflows/opencca-build.yml)                             |
| Build TFA     | [`opencca/arm-trusted-firmware`](https://github.com/opencca/arm-trusted-firmware) | [`opencca-tfa.yml`](.github/workflows/build-tfa.yml)       | [![opencca-build](https://github.com/opencca/arm-trusted-firmware/actions/workflows/opencca-build.yml/badge.svg)](https://github.com/opencca/arm-trusted-firmware/actions/workflows/opencca-build.yml) |
| Build kvmtool | [`opencca/kvmtool`](https://github.com/opencca/kvmtool)                           | [`build-kvmtool.yml`](.github/workflows/build-kvmtool.yml) | [![opencca-build](https://github.com/opencca/kvmtool/actions/workflows/opencca-build.yml/badge.svg)](https://github.com/opencca/kvmtool/actions/workflows/opencca-build.yml)                           |




## Releases
Releases are stored as Github Releases in [opencca-releases](https://github.com/opencca/opencca-releases).

__Naming convention__:
- `{project}`/snapshot/`{branch-name}`/latest: Always points to the latest release
- `{project}`/snapshot/`{branch-name}`/{date}: A snapshot with date
+ project = {firmware | linux | kvmtool | rootfs}

This allows us to have predicatable download links. For instance:

```
# Download latest firmware for opencca/main branch
wget https://github.com/opencca/opencca-releases/releases/download/firmware/snapshot/opencca/main/latest/firmware.tar.gz
```

The release workflows are triggered from this repository. They are in `.github/workflows/release-*.yml`

**CI Jobs:**
| Name             | Workflow File                                                                                                            | Job                                                                                                                                                                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Release Linux    | [`release-linux.yml`](.github/workflows/release-linux.yml)               | [![release-linux](https://github.com/opencca/ci-scripts/actions/workflows/release-linux.yml/badge.svg)](https://github.com/opencca/ci-scripts/actions/workflows/release-linux.yml)                       |
| Release Firmware | [`release-firmware.yml`](.github/workflows/release-firmware.yml)         | [![release-firmware](https://github.com/opencca/ci-scripts/actions/workflows/release-firmware.yml/badge.svg)](https://github.com/opencca/ci-scripts/actions/workflows/release-firmware.yml)              |
| Release Kvmtool  | [`release-kvmtool.yml`](.github/workflows/release-kvmtool.yml)           | [![release-kvmtool](https://github.com/opencca/ci-scripts/actions/workflows/release-kvmtool.yml/badge.svg)](https://github.com/opencca/ci-scripts/actions/workflows/release-kvmtool.yml)                 |
| Release Rootfs   | [`release-debos-rootfs.yml`](.github/workflows/release-debos-rootfs.yml) | [![release-debian-rootfs](https://github.com/opencca/ci-scripts/actions/workflows/release-debos-rootfs.yml/badge.svg)](https://github.com/opencca/ci-scripts/actions/workflows/release-debos-rootfs.yml) |
