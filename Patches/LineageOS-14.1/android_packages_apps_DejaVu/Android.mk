#Created from F-Droid's Android.mk

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := DejaVu
LOCAL_MODULE_TAGS := optional
LOCAL_PACKAGE_NAME := DejaVu

dejavu_root  := $(LOCAL_PATH)
dejavu_out   := $(PWD)/$(OUT_DIR)/target/common/obj/APPS/$(LOCAL_MODULE)_intermediates
dejavu_build := $(dejavu_root)/build
dejavu_apk   := build/outputs/apk/app-release-unsigned.apk

$(dejavu_root)/$(dejavu_apk):
	rm -Rf $(dejavu_build)
	mkdir -p $(dejavu_out)
	ln -sf $(dejavu_out) $(dejavu_build)
	cd $(dejavu_root) && gradle assembleRelease

LOCAL_CERTIFICATE := platform
LOCAL_DEX_PREOPT := false
LOCAL_SRC_FILES := $(dejavu_apk)
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)

include $(BUILD_PREBUILT)
