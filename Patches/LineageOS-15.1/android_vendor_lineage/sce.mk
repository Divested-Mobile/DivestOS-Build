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
    FDroidPrivilegedExtension

# Others
PRODUCT_PACKAGES += \
    LocalCalendar

# Browser
# XXX: THIS DOESN'T WORK
# This is a shim, it is intended that F-Droid will update on first run to the real version of Fennec DOS
# However it doesn't work for whatever reason
# and guess what? There is no documentation about updating system apps. Searching is useless and filled with spam.
# I'm sure Google Play Services does some special bullshit handling of system apps, but we're not allowed to know about that.
#PRODUCT_PACKAGES += \
#    FennecDOS
