# F-Droid
PRODUCT_PACKAGES += \
    F-DroidOfficial \
    F-DroidPrivilegedExtensionOfficial

# UnifiedNLP
PRODUCT_PACKAGES += \
    UnifiedNLP \
    DejaVuNlpBackend \
    IchnaeaNlpBackend \
    NominatimNlpBackend

# Replacements
PRODUCT_PACKAGES += \
    EtarPrebuilt \
    FennecDOS \
    FairEmail \
    SimpleGallery \
    VanillaMusic

ifeq ($(findstring flox,$(TARGET_PRODUCT)),)
PRODUCT_PACKAGES += \
    OpenCamera
endif

# Extras
PRODUCT_PACKAGES += \
    TalkBack \
    SupportDivestOS

# Notes
# - Available (via PrebuiltApps submodule): eSpeakNG
# - Camera Choices: None (Camera2/Snap), OpenCamera
# - Gallery Choices: None (AOSP/Lineage), SimpleGallery
