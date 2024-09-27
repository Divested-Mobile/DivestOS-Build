#!/usr/bin/env bash

version="$1"  # (e.g. "20.0")

if [ "$1" = "" ]; then
  echo "Missing arguments"
  exit 1
fi

# Correctness
set -exo pipefail
umask 0022

# Clone
git clone https://codeberg.org/divested-mobile/divestos-build.git DivestOS
cd DivestOS

# Submodules
sed -i 's|git@gitlab.com:|https://gitlab.com/|' .git/config .gitmodules
git submodule update --init --recursive

# Basic directories
mkdir -p "Build/LineageOS-$version/.repo/local_manifests" Builds Signing_Keys .Signing_Keys

# Encrypted key storage
# TODO There is probably an alternative to gocryptfs which doesn't require a security
# trade-off between giving the container more privileges and encrypting the keys.
if modprobe fuse; then
  gocryptfs -init .Signing_Keys
  gocryptfs .Signing_Keys/ Signing_Keys/
else
  echo "WARNING: gocryptfs failed. Signing keys will not be encrypted!"
fi

# Add the initial manifest
cd "Build/LineageOS-$version/"
cat "../../Manifests/Manifest_LAOS-$version.xml" > .repo/local_manifests/local_manifest.xml
