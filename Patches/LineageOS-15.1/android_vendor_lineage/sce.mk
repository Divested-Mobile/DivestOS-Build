# MicroG
PRODUCT_PACKAGES += \
    GmsCore \
    GsfProxy \
    FakeStore

# UnifiedNLP Backends
PRODUCT_PACKAGES += \
    DejaVuNlpBackend \
    IchnaeaNlpBackend \
    NominatimNlpBackend

# F-Droid
PRODUCT_PACKAGES += \
    F-Droid \
    F-DroidPrivilegedExtension

# Others
PRODUCT_PACKAGES += \
    CameraRoll \
    LocalCalendar

# Browser
# This is a shim, it is intended that F-Droid will update on first run to the real version of Fennec DOS
PRODUCT_PACKAGES += \
    FennecDOS
