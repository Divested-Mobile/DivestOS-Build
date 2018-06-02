# F-Droid
PRODUCT_PACKAGES += \
    F-Droid \
    F-DroidPrivilegedExtension

# UnifiedNLP Backends (DejaVu is always included even when microG is disabled to prevent deletion of a user's database)
PRODUCT_PACKAGES += \
    DejaVuNlpBackend

# Others
PRODUCT_PACKAGES += \
    CameraRoll \
    LocalCalendar

# Browser
# This is a shim, it is intended that F-Droid will update on first run to the real version of Fennec DOS
PRODUCT_PACKAGES += \
    FennecDOS
