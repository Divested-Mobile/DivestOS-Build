PRODUCT_BRAND ?= DivestOS
#PRODUCT_VERSION_MAJOR = 1
#PRODUCT_VERSION_MINOR = 0
#PRODUCT_VERSION_MAINTENANCE := 0

#Overlays
LOCAL_AAPT_FLAGS += --auto-add-overlay
DEVICE_PACKAGE_OVERLAYS += vendor/divested/overlay/common

#Extra settings
PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_UTC_DATE=0

PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Pong.ogg \
    ro.config.alarm_alert=Alarm_Buzzer.ogg \
    keyguard.no_require_sim=true \
    ro.build.selinux=1 \
    ro.storage_manager.enabled=true

#Copy extra files
PRODUCT_COPY_FILES += \
    vendor/divested/prebuilts/etc/additional_fdroid_repos.xml:system/etc/org.fdroid.fdroid/additional_repos.xml

#Include packages
#PRODUCT_PACKAGES += ModuleBlocker
include vendor/divested/packages.mk
