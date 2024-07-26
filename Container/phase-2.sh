#!/usr/bin/env bash

set -exo pipefail

version="$1"  # (e.g. "20.0")
device="$2"  # (e.g. "sailfish")

if [ "$2" = "" ]; then
  echo "Missing arguments"
  exit 1
fi

cd "DivestOS/Build/LineageOS-$version"

# Download
repo init -u https://github.com/LineageOS/android.git -b "lineage-$version" --git-lfs
repo forall --ignore-missing -vc "git reset --hard"
repo sync --fail-fast

# Prepare workspace
if [ "$(echo "$version < 20.0" | bc -l)" = 1 ]; then
  virtualenv venv --python=python2
fi
source ../../Scripts/init.sh

# Patch Workspace so keys can be generated.
resetWorkspace
rm -rf packages/apps/Fennec_DOS-Shim/ vendor/divested/ vendor/fdroid_prebuilt/ packages/apps/SupportDivestOS/
rm -rf out
patchWorkspace

# Generate signing keys
if [ "$(echo "$version > 20.0" | bc -l)" = 1 ]; then
  awk -i inplace '!/enforce-product-packages-exist-internal/' vendor/lineage/config/common.mk
fi
source build/envsetup.sh
breakfast "lineage_$device-user"
make -j20 generate_verity_key
sh "$DOS_WORKSPACE_ROOT/Scripts/Generate_Signing_Keys.sh" "$device"
mv -nv "$DOS_SIGNING_KEYS/NEW/"* "$DOS_SIGNING_KEYS/"

# Patch Workspace
resetWorkspace
rm -rf packages/apps/Fennec_DOS-Shim/ vendor/divested/ vendor/fdroid_prebuilt/ packages/apps/SupportDivestOS/
rm -rf out
successpattern="\[SCRIPT COMPLETE\]"
successes=$(patchWorkspace |& tee /dev/stderr | grep -c "$successpattern")

# Verify the changes applied
expected=$(grep -c "$successpattern" "$DOS_WORKSPACE_ROOT/Logs/patchWorkspace-LineageOS-$version.log")
if [ "$successes" != "$expected" ]; then
  echo "Expected $expected '[SCRIPT COMPLETE]' lines but only found $successes."
  exit 1
fi

# Build
buildDevice "$device"
