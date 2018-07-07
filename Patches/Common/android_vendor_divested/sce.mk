# F-Droid
PRODUCT_PACKAGES += \
    F-Droid \
    F-DroidPrivilegedExtension

# UnifiedNLP Backends (DejaVu is always included even when microG is disabled to prevent deletion of a user's database)
PRODUCT_PACKAGES += \
    DejaVuNlpBackend

# Replacements
PRODUCT_PACKAGES += \
    CameraRoll \
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
