# F-Droid
PRODUCT_PACKAGES += \
    F-Droid \
    F-DroidPrivilegedExtension

# F-Droid Official
#PRODUCT_PACKAGES += \
#    F-DroidOfficial \
#    F-DroidPrivilegedExtensionOfficial

# UnifiedNLP
PRODUCT_PACKAGES += \
    UnifiedNLP \
    DejaVuNlpBackend \
    IchnaeaNlpBackend \
    NominatimNlpBackend

# Replacements
PRODUCT_PACKAGES += \
    CameraRoll \
    K9Mail \
    Silence \
    VanillaMusic

# Others
PRODUCT_PACKAGES += \
    LocalCalendar

# Browser
# This is a shim, it is intended that F-Droid will update on first run to the real version of Fennec DOS
PRODUCT_PACKAGES += \
    FennecDOS

# Notes
# - Official F-Droid will be included once #843 is implemented
# - K-9 Mail will be included after 5.5xx release
# - OpenKeychain inclusion is undecided yet
# - Net Monitor will be included after #58 is merged
# - Orbot/Orfox will most likely never be included due to various reasons
# - Replacing HOSTS with DNS66 isn't ideal as it breaks regular VPN usage
