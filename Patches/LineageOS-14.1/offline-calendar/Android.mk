#Created from F-Droid's Android.mk

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := OfflineCalendar
LOCAL_MODULE_TAGS := optional
LOCAL_PACKAGE_NAME := OfflineCalendar

offlinecalendar_root  := $(LOCAL_PATH)
offlinecalendar_dir   := Offline-Calendar
offlinecalendar_out   := $(PWD)/$(OUT_DIR)/target/common/obj/APPS/$(LOCAL_MODULE)_intermediates
offlinecalendar_build := $(offlinecalendar_root)/$(offlinecalendar_dir)/build
offlinecalendar_apk   := build/outputs/apk/$(offlinecalendar_dir)-release-unsigned.apk

$(offlinecalendar_root)/$(offlinecalendar_dir)/$(offlinecalendar_apk):
	rm -Rf $(offlinecalendar_build)
	mkdir -p $(offlinecalendar_out)
	ln -sf $(offlinecalendar_out) $(offlinecalendar_build)
	cd $(offlinecalendar_root)/$(offlinecalendar_dir) && gradle assembleRelease

LOCAL_CERTIFICATE := platform
LOCAL_PRIVILEGED_MODULE := true
LOCAL_SRC_FILES := $(offlinecalendar_dir)/$(offlinecalendar_apk)
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)

include $(BUILD_PREBUILT)
