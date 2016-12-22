#!/bin/bash

user_error() {
  echo user error, please replace user and try again >&2
  exit 1
}

[[ $# -eq 1 ]] || user_error
[[ -n $BUILD_NUMBER ]] || user_error

KEY_DIR=keys
OUT=out/release-$1

source device/common/clear-factory-images-variables.sh

if [[ $1 == bullhead ]]; then
  BOOTLOADER=bhz10r
  RADIO=m8994f-2.6.32.1.13
  VERITY=true
elif [[ $1 == flounder ]]; then
  BOOTLOADER=3.48.0.0135
  VERITY=true
elif [[ $1 == hammerhead ]]; then
  BOOTLOADER=hhz20h
  RADIO=m8974a-2.0.50.2.29
  VERITY=false
elif [[ $1 == angler ]]; then
  BOOTLOADER=angler-03.54
  RADIO=angler-03.61
  VERITY=true
else
  user_error
fi

BUILD=$BUILD_NUMBER
if [[ $1 == bullhead ]] || [[ $1 == angler ]]; then
  VERSION=mtc20f
else
  VERSION=mob30y
fi
DEVICE=$1
PRODUCT=$1

mkdir -p $OUT || exit 1

TARGET_FILES=$DEVICE-target_files-$BUILD.zip

if [[ $VERITY == true ]]; then
  EXTRA=(--replace_verity_public_key "$KEY_DIR/verity_key.pub"
         --replace_verity_private_key "$KEY_DIR/verity")
fi

if [[ $DEVICE == bullhead ]]; then
  EXTRA_OTA=(-b device/lge/bullhead/update-binary)
fi

build/tools/releasetools/sign_target_files_apks -o -d "$KEY_DIR" "${EXTRA[@]}" \
  out/dist/aosp_$DEVICE-target_files-$BUILD_NUMBER.zip $OUT/$TARGET_FILES || exit 1

build/tools/releasetools/img_from_target_files -n $OUT/$TARGET_FILES \
  $OUT/$DEVICE-img-$BUILD.zip || exit 1

build/tools/releasetools/ota_from_target_files --block -k "$KEY_DIR/releasekey" "${EXTRA_OTA[@]}" $OUT/$TARGET_FILES \
  $OUT/$DEVICE-ota_update-$BUILD.zip || exit 1

cd $OUT || exit 1

source ../../device/common/generate-factory-images-common.sh
