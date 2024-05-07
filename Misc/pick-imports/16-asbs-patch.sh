applyPatch "$DOS_PATCHES/android_external_aac/332775.patch"; #P_asb_2022-06 Reject invalid out of band config in transportDec_OutOfBandConfig() and skip re-allocation.
applyPatch "$DOS_PATCHES/android_external_aac/364605.patch"; #P_asb_2023-08 Increase patchParam array size by one and fix out-of-bounce write in resetLppTransposer().
applyPatch "$DOS_PATCHES/android_external_dtc/342096.patch"; #P_asb_2022-10 libfdt: fdt_offset_ptr(): Fix comparison warnings
applyPatch "$DOS_PATCHES/android_external_dtc/344161.patch"; #P_asb_2022-11 Fix integer wrap sanitisation.
applyPatch "$DOS_PATCHES/android_external_dtc/345891.patch"; #P_asb_2022-12 libfdt: fdt_path_offset_namelen: Reject empty paths
applyPatch "$DOS_PATCHES/android_external_expat/338353.patch"; #P_asb_2022-09 Prevent integer overflow in copyString
applyPatch "$DOS_PATCHES/android_external_expat/338354.patch"; #P_asb_2022-09 Prevent XML_GetBuffer signed integer overflow
applyPatch "$DOS_PATCHES/android_external_expat/338355.patch"; #P_asb_2022-09 Prevent integer overflow in function doProlog
applyPatch "$DOS_PATCHES/android_external_expat/338356.patch"; #P_asb_2022-09 Prevent more integer overflows
applyPatch "$DOS_PATCHES/android_external_expat/349328.patch"; #P_asb_2023-02 [CVE-2022-43680] Fix overeager DTD destruction (fixes
applyPatch "$DOS_PATCHES/android_external_freetype/361250.patch"; #P_asb_2023-07 Cherry-pick two upstream changes
applyPatch "$DOS_PATCHES/android_external_freetype/364606.patch"; #P_asb_2023-08 Cherrypick following three changes
applyPatch "$DOS_PATCHES/android_external_libcups/374932.patch"; #P_asb_2023-11 Upgrade libcups to v2.3.1
applyPatch "$DOS_PATCHES/android_external_libcups/374933.patch"; #P_asb_2023-11 Upgrade libcups to v2.3.3
applyPatch "$DOS_PATCHES/android_external_libxml2/370701.patch"; #P_asb_2023-10 malloc-fail: Fix OOB read after xmlRegGetCounter
applyPatch "$DOS_PATCHES/android_external_zlib/351909.patch"; #P_asb_2023-03 Fix a bug when getting a gzip header extra field with inflate().
applyPatch "$DOS_PATCHES/android_frameworks_av/344167.patch"; #P_asb_2022-11 setSecurityLevel in clearkey
applyPatch "$DOS_PATCHES/android_frameworks_av/349329.patch"; #P_asb_2023-02 move MediaCodec metrics processing to looper thread
applyPatch "$DOS_PATCHES/android_frameworks_av/359729.patch"; #P_asb_2023-06 Fix NuMediaExtractor::readSampleData buffer Handling
applyPatch "$DOS_PATCHES/android_frameworks_av/366126.patch"; #P_asb_2023-09 Fix Segv on unknown address error flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/374924.patch"; #P_asb_2023-11 Fix for heap buffer overflow issue flagged by fuzzer test.
applyPatch "$DOS_PATCHES/android_frameworks_av/377765.patch"; #P_asb_2023-12 httplive: fix use-after-free
applyPatch "$DOS_PATCHES/android_frameworks_av/379788.patch"; #P_asb_2024-01 Fix convertYUV420Planar16ToY410 overflow issue for unsupported cropwidth.
applyPatch "$DOS_PATCHES/android_frameworks_av/383562.patch"; #P_asb_2024-02 Update mtp packet buffer
applyPatch "$DOS_PATCHES/android_frameworks_av/385670.patch"; #P_asb_2024-03 Validate OMX Params for VPx encoders
applyPatch "$DOS_PATCHES/android_frameworks_av/385671.patch"; #P_asb_2024-03 Fix out of bounds read and write in onQueueFilled in outQueue
applyPatch "$DOS_PATCHES/android_frameworks_base/330961.patch"; #P_asb_2022-05 Keyguard - Treat messsages to lock with priority
applyPatch "$DOS_PATCHES/android_frameworks_base/330962.patch"; #P_asb_2022-05 Verify caller before auto granting slice permission
applyPatch "$DOS_PATCHES/android_frameworks_base/330963.patch"; #P_asb_2022-05 Always restart apps if base.apk gets updated.
applyPatch "$DOS_PATCHES/android_frameworks_base/332756.patch"; #P_asb_2022-06 Add finalizeWorkProfileProvisioning.
applyPatch "$DOS_PATCHES/android_frameworks_base/332757.patch"; #P_asb_2022-06 limit TelecomManager#registerPhoneAccount to 10; api doc update
applyPatch "$DOS_PATCHES/android_frameworks_base/332776.patch"; #P_asb_2022-06 Update GeofenceHardwareRequestParcelable to match parcel/unparcel format.
applyPatch "$DOS_PATCHES/android_frameworks_base/332777.patch"; #P_asb_2022-06 Add an OEM configurable limit for zen rules
applyPatch "$DOS_PATCHES/android_frameworks_base/332778.patch"; #P_asb_2022-06 Fix security hole in GateKeeperResponse
applyPatch "$DOS_PATCHES/android_frameworks_base/332779.patch"; #P_asb_2022-06 Prevent non-admin users from deleting system apps.
applyPatch "$DOS_PATCHES/android_frameworks_base/334256.patch"; #P_asb_2022-07 StorageManagerService: don't ignore failures to prepare user storage
applyPatch "$DOS_PATCHES/android_frameworks_base/334257.patch"; #P_asb_2022-07 UserDataPreparer: reboot to recovery if preparing user storage fails
applyPatch "$DOS_PATCHES/android_frameworks_base/334258.patch"; #P_asb_2022-07 UserDataPreparer: reboot to recovery for system user only
applyPatch "$DOS_PATCHES/android_frameworks_base/334259.patch"; #P_asb_2022-07 Ignore errors preparing user storage for existing users
applyPatch "$DOS_PATCHES/android_frameworks_base/334260.patch"; #P_asb_2022-07 Log to EventLog on prepareUserStorage failure
applyPatch "$DOS_PATCHES/android_frameworks_base/334262.patch"; #P_asb_2022-07 Crash invalid FGS notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/335117.patch"; #P_asb_2022-08 Only allow system and same app to apply relinquishTaskIdentity
applyPatch "$DOS_PATCHES/android_frameworks_base/335118.patch"; #P_asb_2022-08 Suppress notifications when device enter lockdown
applyPatch "$DOS_PATCHES/android_frameworks_base/335119.patch"; #P_asb_2022-08 Remove package title from notification access confirmation intent
applyPatch "$DOS_PATCHES/android_frameworks_base/335120.patch"; #P_asb_2022-08 Stop using invalid URL to prevent unexpected crash
applyPatch "$DOS_PATCHES/android_frameworks_base/335121.patch"; #P_asb_2022-08 Only allow the system server to connect to sync adapters
applyPatch "$DOS_PATCHES/android_frameworks_base/338346.patch"; #P_asb_2022-09 Fix duplicate permission privilege escalation
applyPatch "$DOS_PATCHES/android_frameworks_base/338347.patch"; #P_asb_2022-09 Parcel: recycle recycles
applyPatch "$DOS_PATCHES/android_frameworks_base/338348.patch"; #P_asb_2022-09 IMMS: Make IMMS PendingIntents immutable
applyPatch "$DOS_PATCHES/android_frameworks_base/338349.patch"; #P_asb_2022-09 Remove package name from SafetyNet logs
applyPatch "$DOS_PATCHES/android_frameworks_base/342100.patch"; #P_asb_2022-10 Limit the number of concurrently snoozed notifications
applyPatch "$DOS_PATCHES/android_frameworks_base/344168.patch"; #P_asb_2022-11 Move accountname and typeName length check from Account.java to AccountManagerService.
applyPatch "$DOS_PATCHES/android_frameworks_base/344169.patch"; #P_asb_2022-11 switch TelecomManager List getters to ParceledListSlice
applyPatch "$DOS_PATCHES/android_frameworks_base/344170.patch"; #P_asb_2022-11 Do not send new Intent to non-exported activity when navigateUpTo
applyPatch "$DOS_PATCHES/android_frameworks_base/344171.patch"; #P_asb_2022-11 Do not send AccessibilityEvent if notification is for different user.
applyPatch "$DOS_PATCHES/android_frameworks_base/344172.patch"; #P_asb_2022-11 Trim any long string inputs that come in to AutomaticZenRule
applyPatch "$DOS_PATCHES/android_frameworks_base/344173.patch"; #P_asb_2022-11 Check permission for VoiceInteraction
applyPatch "$DOS_PATCHES/android_frameworks_base/344174.patch"; #P_asb_2022-11 Do not dismiss keyguard after SIM PUK unlock
applyPatch "$DOS_PATCHES/android_frameworks_base/345892.patch"; #P_asb_2022-12 Revert "Prevent non-admin users from deleting system apps."
applyPatch "$DOS_PATCHES/android_frameworks_base/345893.patch"; #P_asb_2022-12 Limit the size of NotificationChannel and NotificationChannelGroup
applyPatch "$DOS_PATCHES/android_frameworks_base/345894.patch"; #P_asb_2022-12 Prevent non-admin users from deleting system apps.
applyPatch "$DOS_PATCHES/android_frameworks_base/345895.patch"; #P_asb_2022-12 Validate package name passed to setApplicationRestrictions.
applyPatch "$DOS_PATCHES/android_frameworks_base/345896.patch"; #P_asb_2022-12 Include all enabled services when FEEDBACK_ALL_MASK.
applyPatch "$DOS_PATCHES/android_frameworks_base/345897.patch"; #P_asb_2022-12 [pm] forbid deletion of protected packages
applyPatch "$DOS_PATCHES/android_frameworks_base/345898.patch"; #P_asb_2022-12 Fix NPE
applyPatch "$DOS_PATCHES/android_frameworks_base/345899.patch"; #P_asb_2022-12 Fix a security issue in app widget service.
applyPatch "$DOS_PATCHES/android_frameworks_base/345900.patch"; #P_asb_2022-12 Ignore malformed shortcuts
applyPatch "$DOS_PATCHES/android_frameworks_base/345901.patch"; #P_asb_2022-12 Fix permanent denial of service via setComponentEnabledSetting
applyPatch "$DOS_PATCHES/android_frameworks_base/345902.patch"; #P_asb_2022-12 Add safety checks on KEY_INTENT mismatch.
applyPatch "$DOS_PATCHES/android_frameworks_base/347044.patch"; #P_asb_2023-01 Limit lengths of fields in Condition to a max length.
applyPatch "$DOS_PATCHES/android_frameworks_base/347045.patch"; #P_asb_2023-01 Disable all A11yServices from an uninstalled package.
applyPatch "$DOS_PATCHES/android_frameworks_base/347046.patch"; #P_asb_2023-01 Fix conditionId string trimming in AutomaticZenRule
applyPatch "$DOS_PATCHES/android_frameworks_base/347047.patch"; #P_asb_2023-01 [SettingsProvider] mem limit should be checked before settings are updated
applyPatch "$DOS_PATCHES/android_frameworks_base/347048.patch"; #P_asb_2023-01 Revert "Revert "Validate permission tree size..."
applyPatch "$DOS_PATCHES/android_frameworks_base/347049.patch"; #P_asb_2023-01 [SettingsProvider] key size limit for mutating settings
applyPatch "$DOS_PATCHES/android_frameworks_base/347050.patch"; #P_asb_2023-01 Revoke SYSTEM_ALERT_WINDOW on upgrade past api 23
applyPatch "$DOS_PATCHES/android_frameworks_base/347051.patch"; #P_asb_2023-01 Add protections agains use-after-free issues if cancel() or queue() is called after a device connection has been closed.
applyPatch "$DOS_PATCHES/android_frameworks_base/349330.patch"; #P_asb_2023-02 Correct the behavior of ACTION_PACKAGE_DATA_CLEARED
applyPatch "$DOS_PATCHES/android_frameworks_base/349331.patch"; #P_asb_2023-02 Convert argument to intent in ChooseTypeAndAccountActivity
applyPatch "$DOS_PATCHES/android_frameworks_base/351910.patch"; #P_asb_2023-03 Move service initialization
applyPatch "$DOS_PATCHES/android_frameworks_base/351911.patch"; #P_asb_2023-03 Enable user graularity for lockdown mode
applyPatch "$DOS_PATCHES/android_frameworks_base/351912.patch"; #P_asb_2023-03 Revoke dev perm if app is upgrading to post 23 and perm has pre23 flag
applyPatch "$DOS_PATCHES/android_frameworks_base/351913.patch"; #P_asb_2023-03 Reconcile WorkSource parcel and unparcel code.
applyPatch "$DOS_PATCHES/android_frameworks_base/354242.patch"; #P_asb_2023-04 Context#startInstrumentation could be started from SHELL only now.
applyPatch "$DOS_PATCHES/android_frameworks_base/354243.patch"; #P_asb_2023-04 Checking if package belongs to UID before registering broadcast receiver
applyPatch "$DOS_PATCHES/android_frameworks_base/354244.patch"; #P_asb_2023-04 Fix checkKeyIntentParceledCorrectly's bypass
applyPatch "$DOS_PATCHES/android_frameworks_base/354245.patch"; #P_asb_2023-04 Encode Intent scheme when serializing to URI string RESTRICT AUTOMERGE
applyPatch "$DOS_PATCHES/android_frameworks_base/356154.patch"; #P_asb_2023-05 Checks if AccessibilityServiceInfo is within parcelable size.
applyPatch "$DOS_PATCHES/android_frameworks_base/356155.patch"; #P_asb_2023-05 Uri: check authority and scheme as part of determining URI path
applyPatch "$DOS_PATCHES/android_frameworks_base/356156.patch"; #P_asb_2023-05 enforce stricter rules when registering phoneAccounts
applyPatch "$DOS_PATCHES/android_frameworks_base/359730.patch"; #P_asb_2023-06 Check key intent for selectors and prohibited flags
applyPatch "$DOS_PATCHES/android_frameworks_base/359731.patch"; #P_asb_2023-06 Handle invalid data during job loading.
applyPatch "$DOS_PATCHES/android_frameworks_base/359732.patch"; #P_asb_2023-06 Allow filtering of services
applyPatch "$DOS_PATCHES/android_frameworks_base/359733.patch"; #P_asb_2023-06 Prevent RemoteViews crashing SystemUi
applyPatch "$DOS_PATCHES/android_frameworks_base/361254.patch"; #P_asb_2023-07 Sanitize VPN label to prevent HTML injection
applyPatch "$DOS_PATCHES/android_frameworks_base/361255.patch"; #P_asb_2023-07 Limit the number of supported v1 and v2 signers
applyPatch "$DOS_PATCHES/android_frameworks_base/361256.patch"; #P_asb_2023-07 Import translations. DO NOT MERGE ANYWHERE
applyPatch "$DOS_PATCHES/android_frameworks_base/361257.patch"; #P_asb_2023-07 Dismiss keyguard when simpin auth'd and...
applyPatch "$DOS_PATCHES/android_frameworks_base/361258.patch"; #P_asb_2023-07 Truncate ShortcutInfo Id
applyPatch "$DOS_PATCHES/android_frameworks_base/361259.patch"; #P_asb_2023-07 Visit URIs in landscape/portrait custom remote views.
applyPatch "$DOS_PATCHES/android_frameworks_base/364607.patch"; #P_asb_2023-08 ActivityManager#killBackgroundProcesses can kill caller's own app only
applyPatch "$DOS_PATCHES/android_frameworks_base/364608.patch"; #P_asb_2023-08 Verify URI permissions for notification shortcutIcon.
applyPatch "$DOS_PATCHES/android_frameworks_base/364609.patch"; #P_asb_2023-08 On device lockdown, always show the keyguard
applyPatch "$DOS_PATCHES/android_frameworks_base/364610.patch"; #P_asb_2023-08 Ensure policy has no absurdly long strings
applyPatch "$DOS_PATCHES/android_frameworks_base/364611.patch"; #P_asb_2023-08 Implement visitUris for RemoteViews ViewGroupActionAdd.
applyPatch "$DOS_PATCHES/android_frameworks_base/364612.patch"; #P_asb_2023-08 Check URIs in notification public version.
applyPatch "$DOS_PATCHES/android_frameworks_base/364613.patch"; #P_asb_2023-08 Verify URI permissions in MediaMetadata
applyPatch "$DOS_PATCHES/android_frameworks_base/364614.patch"; #P_asb_2023-08 Use Settings.System.getIntForUser instead of getInt to make sure user specific settings are used
applyPatch "$DOS_PATCHES/android_frameworks_base/364615.patch"; #P_asb_2023-08 Resolve StatusHints image exploit across user.
applyPatch "$DOS_PATCHES/android_frameworks_base/366127.patch"; #P_asb_2023-09 Forbid granting access to NLSes with too-long component names
applyPatch "$DOS_PATCHES/android_frameworks_base/366128.patch"; #P_asb_2023-09 Update AccountManagerService checkKeyIntentParceledCorrectly.
applyPatch "$DOS_PATCHES/android_frameworks_base/370693.patch"; #P_asb_2023-10 RingtoneManager: verify default ringtone is audio
applyPatch "$DOS_PATCHES/android_frameworks_base/370694.patch"; #P_asb_2023-10 Do not share key mappings with JNI object
applyPatch "$DOS_PATCHES/android_frameworks_base/370695.patch"; #P_asb_2023-10 Verify URI Permissions in Autofill RemoteViews
applyPatch "$DOS_PATCHES/android_frameworks_base/370696.patch"; #P_asb_2023-10 Fix KCM key mapping cloning
applyPatch "$DOS_PATCHES/android_frameworks_base/370697.patch"; #P_asb_2023-10 Disallow loading icon from content URI to PipMenu
applyPatch "$DOS_PATCHES/android_frameworks_base/370698.patch"; #P_asb_2023-10 Fixing DatabaseUtils to detect malformed UTF-16 strings
applyPatch "$DOS_PATCHES/android_frameworks_base/370699.patch"; #P_asb_2023-10 Revert "Dismiss keyguard when simpin auth'd and..."
applyPatch "$DOS_PATCHES/android_frameworks_base/374921.patch"; #P_asb_2023-11 Fix BAL via notification.publicVersion
applyPatch "$DOS_PATCHES/android_frameworks_base/374922.patch"; #P_asb_2023-11 Use type safe API of readParcelableArray
applyPatch "$DOS_PATCHES/android_frameworks_base/374923.patch"; #P_asb_2023-11 [SettingsProvider] verify ringtone URI before setting
applyPatch "$DOS_PATCHES/android_frameworks_base/377766.patch"; #P_asb_2023-12 Visit Uris added by WearableExtender
applyPatch "$DOS_PATCHES/android_frameworks_base/377767.patch"; #P_asb_2023-12 Drop invalid data.
applyPatch "$DOS_PATCHES/android_frameworks_base/377768.patch"; #P_asb_2023-12 Require permission to unlock keyguard
applyPatch "$DOS_PATCHES/android_frameworks_base/377769.patch"; #P_asb_2023-12 Use readUniqueFileDescriptor in incidentd service
applyPatch "$DOS_PATCHES/android_frameworks_base/377770.patch"; #P_asb_2023-12 Validate userId when publishing shortcuts
applyPatch "$DOS_PATCHES/android_frameworks_base/377771.patch"; #P_asb_2023-12 Revert "On device lockdown, always show the keyguard"
applyPatch "$DOS_PATCHES/android_frameworks_base/377772.patch"; #P_asb_2023-12 Adding in verification of calling UID in onShellCommand
applyPatch "$DOS_PATCHES/android_frameworks_base/377773.patch"; #P_asb_2023-12 Updated: always show the keyguard on device lockdown
applyPatch "$DOS_PATCHES/android_frameworks_base/379789.patch"; #P_asb_2024-01 Dismiss keyguard when simpin auth'd and...
applyPatch "$DOS_PATCHES/android_frameworks_base/379790.patch"; #P_asb_2024-01 Ensure finish lockscreen when usersetup incomplete
applyPatch "$DOS_PATCHES/android_frameworks_base/379791.patch"; #P_asb_2024-01 Truncate user data to a limit of 500 characters
applyPatch "$DOS_PATCHES/android_frameworks_base/379792.patch"; #P_asb_2024-01 Validate component name length before requesting notification access.
applyPatch "$DOS_PATCHES/android_frameworks_base/379793.patch"; #P_asb_2024-01 Log to detect usage of whitelistToken when sending non-PI target
applyPatch "$DOS_PATCHES/android_frameworks_base/379794.patch"; #P_asb_2024-01 Fix vulnerability that allowed attackers to start arbitary activities
applyPatch "$DOS_PATCHES/android_frameworks_base/379980.patch"; #P_asb_2024-01 Fix ActivityManager#killBackgroundProcesses permissions
applyPatch "$DOS_PATCHES/android_frameworks_base/383563.patch"; #P_asb_2024-02 Unbind TileService onNullBinding
applyPatch "$DOS_PATCHES/android_frameworks_base/385672.patch"; #P_asb_2024-03 Resolve custom printer icon boundary exploit.
applyPatch "$DOS_PATCHES/android_frameworks_base/385673.patch"; #P_asb_2024-03 Disallow system apps to be installed/updated as instant.
applyPatch "$DOS_PATCHES/android_frameworks_base/385674.patch"; #P_asb_2024-03 Close AccountManagerService.session after timeout.
applyPatch "$DOS_PATCHES/android_frameworks_base/389269.patch"; #P_asb_2024-04 isUserInLockDown can be true when there are other strong auth requirements
applyPatch "$DOS_PATCHES/android_frameworks_base/389270.patch"; #P_asb_2024-04 Fix security vulnerability that creates user with no restrictions when accountOptions are too long.
applyPatch "$DOS_PATCHES/android_frameworks_minikin/345903.patch"; #P_asb_2022-12 Fix OOB read for registerLocaleList
applyPatch "$DOS_PATCHES/android_frameworks_minikin/345904.patch"; #P_asb_2022-12 Fix OOB crash for registerLocaleList
applyPatch "$DOS_PATCHES/android_frameworks_native/356151.patch"; #P_asb_2023-05 Check for malformed Sensor Flattenable
applyPatch "$DOS_PATCHES/android_frameworks_native/356152.patch"; #P_asb_2023-05 Remove some new memory leaks from SensorManager
applyPatch "$DOS_PATCHES/android_frameworks_native/356153.patch"; #P_asb_2023-05 Add removeInstanceForPackageMethod to SensorManager
applyPatch "$DOS_PATCHES/android_frameworks_native/366129.patch"; #P_asb_2023-09 Allow sensors list to be empty
applyPatch "$DOS_PATCHES/android_frameworks_opt_telephony/334263.patch"; #P_asb_2022-07 Enforce privileged phone state for getSubscriptionProperty(GROUP_UUID)
applyPatch "$DOS_PATCHES/android_hardware_nxp_nfc/344180.patch"; #P_asb_2022-11 OOBW in phNxpNciHal_write_unlocked()
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332758.patch"; #P_asb_2022-06 Removes app access to BluetoothAdapter#setScanMode by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/332759.patch"; #P_asb_2022-06 Removes app access to BluetoothAdapter#setDiscoverableTimeout by requiring BLUETOOTH_PRIVILEGED permission.
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/345907.patch"; #P_asb_2022-12 Fix URI check in BluetoothOppUtility.java
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/349332.patch"; #P_asb_2023-02 Fix OPP comparison
applyPatch "$DOS_PATCHES/android_packages_apps_Bluetooth/377774.patch"; #P_asb_2023-12 Fix UAF in ~CallbackEnv
applyPatch "$DOS_PATCHES/android_packages_apps_Contacts/332760.patch"; #P_asb_2022-06 No longer export CallSubjectDialog
applyPatch "$DOS_PATCHES/android_packages_apps_Dialer/332761.patch"; #P_asb_2022-06 No longer export CallSubjectDialog
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/342101.patch"; #P_asb_2022-06 Prevent exfiltration of system files via user image settings.
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/345908.patch"; #P_asb_2022-12 Revert "Prevent exfiltration of system files via user image settings."
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/345909.patch"; #P_asb_2022-12 Prevent exfiltration of system files via avatar picker.
applyPatch "$DOS_PATCHES/android_packages_apps_EmergencyInfo/349333.patch"; #P_asb_2023-02 Removes unnecessary permission from the EmergencyInfo app.
applyPatch "$DOS_PATCHES/android_packages_apps_KeyChain/334264.patch"; #P_asb_2022-07 Encode authority part of uri before showing in UI
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/332762.patch"; #P_asb_2022-06 OOB read in phNciNfc_RecvMfResp()
applyPatch "$DOS_PATCHES/android_packages_apps_Nfc/347043.patch"; #P_asb_2023-01 OOBW in Mfc_Transceive()
applyPatch "$DOS_PATCHES/android_packages_apps_PackageInstaller/344181.patch"; #P_asb_2022-11 Hide overlays on ReviewPermissionsAtivity
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/330960.patch"; #P_asb_2022-05 Hide private DNS settings UI in Guest mode
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/332763.patch"; #P_asb_2022-06 Prevent exfiltration of system files via user image settings.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/334265.patch"; #P_asb_2022-07 Fix LaunchAnyWhere in AppRestrictionsFragment
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335111.patch"; #P_asb_2022-08 Verify ringtone from ringtone picker is audio
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335112.patch"; #P_asb_2022-08 Make bluetooth not discoverable via SliceDeepLinkTrampoline
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335113.patch"; #P_asb_2022-08 Fix: policy enforcement for location wifi scanning
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335114.patch"; #P_asb_2022-08 Fix Settings crash when setting a null ringtone
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335115.patch"; #P_asb_2022-08 Fix can't change notification sound for work profile.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/335116.patch"; #P_asb_2022-08 Extract app label from component name in notification access confirmation UI
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345910.patch"; #P_asb_2022-12 Revert "Prevent exfiltration of system files via user image settings."
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345911.patch"; #P_asb_2022-12 Prevent exfiltration of system files via avatar picker.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/345912.patch"; #P_asb_2022-12 Add FLAG_SECURE for ChooseLockPassword and Pattern
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/351914.patch"; #P_asb_2023-03 FRP bypass defense in the settings app
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/351915.patch"; #P_asb_2023-03 Add DISALLOW_APPS_CONTROL check into uninstall app for all users
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/359734.patch"; #P_asb_2023-06 Convert argument to intent in AddAccountSettings.
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/366136.patch"; #P_asb_2023-09 Prevent non-system IME from becoming device admin
applyPatch "$DOS_PATCHES/android_packages_apps_Settings/370700.patch"; #P_asb_2023-10 Restrict ApnEditor settings
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/378475.patch"; #P_asb_2023-06 Update Traceur to check admin user status
applyPatch "$DOS_PATCHES/android_packages_apps_Traceur/378476.patch"; #P_asb_2023-06 Add DISALLOW_DEBUGGING_FEATURES check
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/366137.patch"; #P_asb_2023-09 Fix permission issue in legacy shortcut
applyPatch "$DOS_PATCHES/android_packages_apps_Trebuchet/377775.patch"; #P_asb_2023-12 Fix permission bypass in legacy shortcut
applyPatch "$DOS_PATCHES/android_packages_apps_TvSettings/359735.patch"; #P_asb_2023-06 Convert argument to intent in addAccount TvSettings.
applyPatch "$DOS_PATCHES/android_packages_providers_ContactsProvider/335110.patch"; #P_asb_2022-08 enforce stricter CallLogProvider query
applyPatch "$DOS_PATCHES/android_packages_providers_DownloadProvider/383567.patch"; #P_asb_2024-02 Consolidate queryChildDocumentsXxx() implementations
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/344182.patch"; #P_asb_2022-11 Check dir path before updating permissions.
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/364616.patch"; #P_asb_2023-08 Update file permissions using canonical path
applyPatch "$DOS_PATCHES/android_packages_providers_TelephonyProvider/374920.patch"; #P_asb_2023-11 Block access to sms/mms db from work profile.
applyPatch "$DOS_PATCHES/android_packages_services_BuiltInPrintService/374919.patch"; #P_asb_2023-11 Adjust APIs for CUPS 2.3.3
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/330959.patch"; #P_asb_2022-05 Handle null bindings returned from ConnectionService.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/332764.patch"; #P_asb_2022-06 limit TelecomManager#registerPhoneAccount to 10
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/344183.patch"; #P_asb_2022-11 switch TelecomManager List getters to ParceledListSlice
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/345913.patch"; #P_asb_2022-12 Hide overlay windows when showing phone account enable/disable screen.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/347042.patch"; #P_asb_2023-01 Fix security vulnerability when register phone accounts.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/356150.patch"; #P_asb_2023-05 enforce stricter rules when registering phoneAccounts
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/364617.patch"; #P_asb_2023-08 Resolve StatusHints image exploit across user.
applyPatch "$DOS_PATCHES/android_packages_services_Telecomm/377776.patch"; #P_asb_2023-12 Resolve account image icon profile boundary exploit.
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/347041.patch"; #P_asb_2023-01 prevent overlays on the phone settings
applyPatch "$DOS_PATCHES/android_packages_services_Telephony/366130.patch"; #P_asb_2023-09 Fixed leak of cross user data in multiple settings.
applyPatch "$DOS_PATCHES/android_system_bt/334266.patch"; #P_asb_2022-07 Security: Fix out of bound write in HFP client
applyPatch "$DOS_PATCHES/android_system_bt/334267.patch"; #P_asb_2022-07 Check Avrcp packet vendor length before extracting length
applyPatch "$DOS_PATCHES/android_system_bt/334268.patch"; #P_asb_2022-07 Security: Fix out of bound read in AT_SKIP_REST
applyPatch "$DOS_PATCHES/android_system_bt/335109.patch"; #P_asb_2022-08 Removing bonded device when auth fails due to missing keys
applyPatch "$DOS_PATCHES/android_system_bt/338350.patch"; #P_asb_2022-09 Fix OOB in bnep_is_packet_allowed
applyPatch "$DOS_PATCHES/android_system_bt/338351.patch"; #P_asb_2022-09 Fix OOB in BNEP_Write
applyPatch "$DOS_PATCHES/android_system_bt/338352.patch"; #P_asb_2022-09 Fix OOB in reassemble_and_dispatch
applyPatch "$DOS_PATCHES/android_system_bt/342097.patch"; #P_asb_2022-10 Fix potential interger overflow when parsing vendor response
applyPatch "$DOS_PATCHES/android_system_bt/344184.patch"; #P_asb_2022-11 Add negative length check in process_service_search_rsp
applyPatch "$DOS_PATCHES/android_system_bt/344185.patch"; #P_asb_2022-11 Add buffer in pin_reply in bluetooth.cc
applyPatch "$DOS_PATCHES/android_system_bt/345914.patch"; #P_asb_2022-12 Add length check when copy AVDTP packet
applyPatch "$DOS_PATCHES/android_system_bt/345915.patch"; #P_asb_2022-12 Added max buffer length check
applyPatch "$DOS_PATCHES/android_system_bt/345916.patch"; #P_asb_2022-12 Add missing increment in bnep_api.cc
applyPatch "$DOS_PATCHES/android_system_bt/345917.patch"; #P_asb_2022-12 Add length check when copy AVDT and AVCT packet
applyPatch "$DOS_PATCHES/android_system_bt/345918.patch"; #P_asb_2022-12 Fix integer overflow when parsing avrc response
applyPatch "$DOS_PATCHES/android_system_bt/347127.patch"; #P_asb_2023-01 BT: Once AT command is retrieved, return from method.
applyPatch "$DOS_PATCHES/android_system_bt/347128.patch"; #P_asb_2023-01 AVRC: Validating msg size before accessing fields
applyPatch "$DOS_PATCHES/android_system_bt/349334.patch"; #P_asb_2023-02 Report failure when not able to connect to AVRCP
applyPatch "$DOS_PATCHES/android_system_bt/349335.patch"; #P_asb_2023-02 Add bounds check in avdt_scb_act.cc
applyPatch "$DOS_PATCHES/android_system_bt/351916.patch"; #P_asb_2023-03 Fix an OOB Write bug in gatt_check_write_long_terminate
applyPatch "$DOS_PATCHES/android_system_bt/351917.patch"; #P_asb_2023-03 Fix an OOB access bug in A2DP_BuildMediaPayloadHeaderSbc
applyPatch "$DOS_PATCHES/android_system_bt/351918.patch"; #P_asb_2023-03 Fix an OOB write in SDP_AddAttribute
applyPatch "$DOS_PATCHES/android_system_bt/354246.patch"; #P_asb_2023-04 Fix OOB access in avdt_scb_hdl_pkt_no_frag
applyPatch "$DOS_PATCHES/android_system_bt/354247.patch"; #P_asb_2023-04 Fix an OOB bug in register_notification_rsp
applyPatch "$DOS_PATCHES/android_system_bt/359736.patch"; #P_asb_2023-06 Prevent use-after-free of HID reports
applyPatch "$DOS_PATCHES/android_system_bt/359737.patch"; #P_asb_2023-06 Revert "Revert "Validate buffer length in sdpu_build_uuid_seq""
applyPatch "$DOS_PATCHES/android_system_bt/359738.patch"; #P_asb_2023-06 Revert "Revert "Fix wrong BR/EDR link key downgrades (P_256->P_192)""
applyPatch "$DOS_PATCHES/android_system_bt/361252.patch"; #P_asb_2023-07 Fix gatt_end_operation buffer overflow
applyPatch "$DOS_PATCHES/android_system_bt/366131.patch"; #P_asb_2023-09 Fix an integer overflow bug in avdt_msg_asmbl
applyPatch "$DOS_PATCHES/android_system_bt/366132.patch"; #P_asb_2023-09 Fix integer overflow in build_read_multi_rsp
applyPatch "$DOS_PATCHES/android_system_bt/366133.patch"; #P_asb_2023-09 Fix potential abort in btu_av_act.cc
applyPatch "$DOS_PATCHES/android_system_bt/366134.patch"; #P_asb_2023-09 Fix reliable write.
applyPatch "$DOS_PATCHES/android_system_bt/366135.patch"; #P_asb_2023-09 Fix UAF in gatt_cl.cc
applyPatch "$DOS_PATCHES/android_system_bt/377777.patch"; #P_asb_2023-12 Reject access to secure service authenticated from a temp bonding [1]
applyPatch "$DOS_PATCHES/android_system_bt/377778.patch"; #P_asb_2023-12 Reject access to secure services authenticated from temp bonding [2]
applyPatch "$DOS_PATCHES/android_system_bt/377779.patch"; #P_asb_2023-12 Reject access to secure service authenticated from a temp bonding [3]
applyPatch "$DOS_PATCHES/android_system_bt/377780.patch"; #P_asb_2023-12 Reorganize the code for checking auth requirement
applyPatch "$DOS_PATCHES/android_system_bt/377781.patch"; #P_asb_2023-12Enforce authentication if encryption is required
applyPatch "$DOS_PATCHES/android_system_bt/377782.patch"; #P_asb_2023-12 Fix timing attack in BTM_BleVerifySignature
applyPatch "$DOS_PATCHES/android_system_bt/379796.patch"; #P_asb_2024-01 Fix some OOB errors in BTM parsing
applyPatch "$DOS_PATCHES/android_system_bt/383565.patch"; #P_asb_2024-02 Fix an OOB bug in btif_to_bta_response and attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/383566.patch"; #P_asb_2024-02 Fix an OOB write bug in attp_build_read_by_type_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/385675.patch"; #P_asb_2024-03 Fix OOB caused by invalid SMP packet length
applyPatch "$DOS_PATCHES/android_system_bt/385676.patch"; #P_asb_2024-03 Fix an OOB bug in smp_proc_sec_req
applyPatch "$DOS_PATCHES/android_system_bt/385677.patch"; #P_asb_2024-03 Reland: Fix an OOB write bug in attp_build_value_cmd
applyPatch "$DOS_PATCHES/android_system_bt/385678.patch"; #P_asb_2024-03 Fix a security bypass issue in access_secure_service_from_temp_bond
applyPatch "$DOS_PATCHES/android_system_ca-certificates/365328.patch"; #P_asb_2023-08 Drop TrustCor certificates
applyPatch "$DOS_PATCHES/android_system_ca-certificates/374916.patch"; #P_asb_2023-11 Remove E-Tugra certificates.
applyPatch "$DOS_PATCHES/android_system_core/332765.patch"; #P_asb_2022-06 Backport of Win-specific suppression of potentially rogue construct that can engage in directory traversal on the host.
applyPatch "$DOS_PATCHES/android_system_netd/378480.patch"; #P_asb_2023-12 Fix Heap-use-after-free in MDnsSdListener::Monitor::run
applyPatch "$DOS_PATCHES/android_system_nfc/332766.patch"; #P_asb_2022-06 Out of Bounds Read in nfa_dm_check_set_config
applyPatch "$DOS_PATCHES/android_system_nfc/332767.patch"; #P_asb_2022-06 Double Free in ce_t4t_data_cback
applyPatch "$DOS_PATCHES/android_system_nfc/332768.patch"; #P_asb_2022-06 OOBR in nfc_ncif_proc_ee_discover_req()
applyPatch "$DOS_PATCHES/android_system_nfc/342098.patch"; #P_asb_2022-10 The length of a packet should be non-zero
applyPatch "$DOS_PATCHES/android_system_nfc/354248.patch"; #P_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
applyPatch "$DOS_PATCHES/android_system_nfc/361251.patch"; #P_asb_2023-07 OOBW in rw_i93_send_to_upper()
applyPatch "$DOS_PATCHES/android_tools_apksig/361280.patch"; #P_asb_2023-07 Create source stamp verifier
applyPatch "$DOS_PATCHES/android_tools_apksig/361281.patch"; #P_asb_2023-07 Limit the number of supported v1 and v2 signers
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332769.patch"; #P_asb_2022-06 Prevent OOB write in nfc_ncif_proc_ee_discover_req
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332770.patch"; #P_asb_2022-06 Out of Bounds Read in nfa_dm_check_set_config
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332771.patch"; #P_asb_2022-06 Double Free in ce_t4t_data_cback
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/332772.patch"; #P_asb_2022-06 OOBR in nfc_ncif_proc_ee_discover_req()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/342099.patch"; #P_asb_2022-10 The length of a packet should be non-zero
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/354249.patch"; #P_asb_2023-04 OOBW in nci_snd_set_routing_cmd()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_external_libnfc-nci/361253.patch"; #P_asb_2023-07 OOBW in rw_i93_send_to_upper()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_halimpl/344190.patch"; #P_asb_2022-11 OOBW in phNxpNciHal_write_unlocked()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/332773.patch"; #P_asb_2022-06 OOB read in phNciNfc_RecvMfResp()
applyPatch "$DOS_PATCHES/android_vendor_nxp_opensource_packages_apps_Nfc/349336.patch"; #P_asb_2023-02 OOBW in phNciNfc_MfCreateXchgDataHdr
