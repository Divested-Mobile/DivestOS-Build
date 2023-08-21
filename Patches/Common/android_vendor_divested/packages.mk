# F-Droid
PRODUCT_PACKAGES += \
    F-DroidOfficial

# Replacements
PRODUCT_PACKAGES += \
    EtarPrebuilt \
    FennecDOS \
    SimpleGallery

#ifeq ($(findstring flox,$(TARGET_PRODUCT)),)
#PRODUCT_PACKAGES += \
#    OpenCamera
#endif

# Extras
PRODUCT_PACKAGES += \
    TalkBack \
    SupportDivestOS \
    microg.xml

# Notes
# - Available (via PrebuiltApps submodule): eSpeakNG
# - Camera Choices: None (Camera2/Snap), OpenCamera
# - Gallery Choices: None (AOSP/Lineage), SimpleGallery
