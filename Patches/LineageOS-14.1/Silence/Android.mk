#Created from F-Droid's Android.mk

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := Silence
LOCAL_MODULE_TAGS := optional
LOCAL_PACKAGE_NAME := Silence

silence_root  := $(LOCAL_PATH)
silence_out   := $(PWD)/$(OUT_DIR)/target/common/obj/APPS/$(LOCAL_MODULE)_intermediates
silence_build := $(silence_root)/build
silence_apk   := build/outputs/apk/Silence-release-unsigned.apk

$(silence_root)/$(silence_apk):
	rm -Rf $(silence_build)
	mkdir -p $(silence_out)
	ln -sf $(silence_out) $(silence_build)
	cd $(silence_root) && git submodule update --recursive --init
	cd $(silence_root) && gradle assembleRelease

LOCAL_CERTIFICATE := platform
LOCAL_PRIVILEGED_MODULE := true
#LOCAL_OVERRIDES_PACKAGES := Messaging
LOCAL_SRC_FILES := $(silence_apk)
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)

include $(BUILD_PREBUILT)
