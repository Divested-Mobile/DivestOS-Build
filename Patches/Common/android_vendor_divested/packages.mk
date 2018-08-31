# F-Droid (source)
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
    FennecDOS \
    Silence \
    SimpleGallery \
    VanillaMusic

# Others
PRODUCT_PACKAGES += \
    LocalCalendar

# Notes
# - Available: DNS66, K9Mail, NetMonitor, OpenKeychain, Shelter, TalkBack
# - Official F-Droid will be included once #843 is implemented
# - $DOS_HOSTS_BLOCKING should become a tristate and support DNS66
# - K-9 Mail Will be included after 5.5xx release
# - Net Monitor will be included after #58 is merged
# - OpenKeychain inclusion is undecided yet
# - Orbot/Orfox will most likely never be included due to various reasons
# - microG needs to be added back to support $DOS_MICROG_INCLUDED="FULL"
