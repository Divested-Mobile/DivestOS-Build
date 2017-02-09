#!/bin/bash

#Goal: Remove as many proprietary blobs without breaking core functionality
#Outcome: Increased battery/performance/privacy/security, Decreased ROM size
#This script and subsequent builds have been tested

#
#Device Status
#
#Fully Functional: clark
#LTE Broken (Potentially Unrelated): bacon, mako

base="/home/tad/Android/Build/LineageOS-14.1/"
deblob() {
	dir=$1
	blobList=$2;
	cd $base$dir; #Enter the target directory
	cp $blobList $blobList".bak";
	blobs="";
	
	#Blobs to *NOT* remove: ADSP/Hexagon (Hardware audio decoding), Venus (Hardware video decoding), WCNSS (Wi-Fi), Gatekeeper/Keystore/Qsee/Trustzone (Hardware encryption)

	#ATFWD (Miracast/Wireless Display)
	blobs=$blobs"ATFWD-daemon|atfwd.apk";

	#CNE Core XXX: Breaks radio
	#blobs=$blobs"|libcneapiclient.so";

	#CNE (Automatic Cell/Wi-Fi Switching)
	blobs=$blobs"|andsfCne.xml|ATT_profile1.xml|ATT_profile2.xml|ATT_profile3.xml|ATT_profile4.xml|ATT_profiles.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.quicinc.cne.jar|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|libcneconn.so|libcneqmiutils.so|libcne.so|libNimsWrap.so|libvendorconn.so|libwqe.so|profile1.xml|profile2.xml|profile3.xml|profile4.xml|profile5.xml|ROW_profile1.xml|ROW_profile2.xml|ROW_profile3.xml|ROW_profile4.xml|ROW_profile5.xml|ROW_profiles.xml|SwimConfig.xml|VZW_profile1.xml|VZW_profile2.xml|VZW_profile3.xml|VZW_profile4.xml|VZW_profile5.xml|VZW_profile6.xml|VZW_profiles.xml";
	if [ -f system.prop ]; then sed -i 's/persist.cne.feature=./persist.cne.feature=0/' system.prop; fi
	if [ -f BoardConfig.mk ]; then sed -i 's/BOARD_USES_QCNE := true/BOARD_USES_QCNE := false/' BoardConfig.mk; fi;

	#Diagnostics
	blobs=$blobs"|/diag/|diag_callback_client|diag_dci_sample|diag_klog|diag_mdlog|diag_mdlog-getlogs|diag_mdlog-wrap|diag/mdm|diag_qshrink4_daemon|diag_socket_log|diag_uart_log|drmdiagapp|ibdrmdiag.so|ssr_diag|test_diag";

	#Discretix (DRM/HDCP)
	blobs=$blobs"|discretix|DxHDCP.cfg|dxhdcp2.b00|dxhdcp2.b01|dxhdcp2.b02|dxhdcp2.b03|dxhdcp2.mdt|libDxHdcp.so";

	#DivX (DRM)
	blobs=$blobs"|libDivxDrm.so|libSHIMDivxDrm.so";

	#DPM (Data Power Management)
	blobs=$blobs"|com.qti.dpmframework.jar|com.qti.dpmframework.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libdpmctmgr.so|libdpmfdmgr.so|libdpmframework.so|libdpmnsrm.so|libdpmtcm.so|NsrmConfiguration.xml|tcmclient.jar";
	if [ -f system.prop ]; then sed -i 's/persist.dpm.feature=./persist.dpm.feature=0/' system.prop; fi;

	#DRM XXX: Breaks full disk encryption
	#blobs=$blobs"|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libtzdrmgenprov.so";
	if [ -f system.prop ]; then if ! grep -q "drm.service.enabled=false" system.prop; then echo "drm.service.enabled=false" >> system.prop; fi; fi;

	#Google Project Fi
	blobs=$blobs"|Tycho.apk";

	#Google Widevine (DRM)
	blobs=$blobs"|com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|libdrmwvmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|widevine.b00|widevine.b01|widevine.b02|widevine.b03|widevine.mdt";
	#grep -v "WV_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(WV_IMAGES)))" Android.mk >> Android.mk.new; #FIXME: Figure out a way to do this
	#mv Android.mk.new Android.mk;
	rm -rf libshimwvm; #Remove the compatibility module

	#GPS XXX: Breaks GPS
	#blobs=$blobs"|flp.conf|flp.default.so|flp.msm8084.so|flp.msm8960.so|gpsd|gps.msm8084.so|gps.msm8960.so|libflp.so|libgps.utils.so|libloc_api_v02.so|libloc_core.so|libloc_ds_api.so|libloc_eng.so|libloc_ext.so";

	#HDCP (DRM)
	blobs=$blobs"|libmm-hdcpmgr.so";

	#IPACM (Loadbalances traffic between Cell/Wi-Fi)
	blobs=$blobs"|ipacm|ipacm-diag";
	rm -rf data-ipa-cfg-mgr; #Remove the second half of IPACM

	#Location (gpsOne/gpsOneXTRA/IZat/Lumicast/QUIP)
	blobs=$blobs"|com.qti.location.sdk.jar|com.qti.location.sdk.xml|com.qualcomm.location.apk|com.qualcomm.location.vzw_library.jar|com.qualcomm.location.vzw_library.xml|com.qualcomm.location.xml|gpsone_daemon|izat.xt.srv.jar|izat.xt.srv.xml|libalarmservice_jni.so|libasn1cper.so|libasn1crt.so|libasn1crtx.so|libdataitems.so|libdrplugin_client.so|libDRPlugin.so|libevent_observer.so|libgdtap.so|libgeofence.so|libizat_core.so|liblbs_core.so|liblocationservice_glue.so|liblocationservice.so|liblowi_client.so|liblowi_wifihal_nl.so|liblowi_wifihal.so|libquipc_os_api.so|libquipc_ulp_adapter.so|libulp2.so|libxtadapter.so|libxt_native.so|libxtwifi_ulp_adaptor.so|libxtwifi_zpp_adaptor.so|location-mq|loc_launcher|lowi-server|slim_ap_daemon|slim_daemon|xtwifi-client|xtwifi-inet-agent";
	if [ -f system.prop ]; then sed -i 's/persist.gps.qc_nlp_in_use=1/persist.gps.qc_nlp_in_use=0/' system.prop; fi;

	#Microsoft Playready (DRM)
	blobs=$blobs"|playread.b00|playread.b01|playread.b02|playread.b03|playread.mdt";
	#grep -v "PLAYREADY_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(PLAYREADY_IMAGES)))" Android.mk >> Android.mk.new; #FIXME: Figure out a way to do this
	#mv Android.mk.new Android.mk;

	#Misc
	blobs=$blobs"|libuiblur.so";

	#Motorola
	blobs=$blobs"|AppDirectedSMSProxy.apk|BuaContactAdapter.apk|com.motorola.DirectedSMSProxy.xml|com.motorola.motosignature.jar|com.motorola.motosignature.xml|com.motorola.triggerenroll.xml|MotoSignatureApp.apk|TriggerEnroll.apk|TriggerTrainingService.apk";

	#QTI (Tethering Extensions)
	blobs=$blobs"|libQtiTether.so|QtiTetherService.apk";

	#Sprint
	blobs=$blobs"|com.android.omadm.service.xml|ConnMO.apk|CQATest.apk|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|GCS.apk|HiddenMenu.apk|libdmengine.so|libdmjavaplugin.so|LifetimeData.apk|SprintDM.apk|SprintHM.apk|whitelist_com.android.omadm.service.xml";

	#Time Service XXX: Breaks time, can be replaced with https://github.com/LineageOS/android_hardware_sony_timekeep
	#blobs=$blobs"|libtime_genoff.so|libTimeService.so|time_daemon|TimeService.apk";

	#Verizon
	blobs=$blobs"|com.verizon.apn.xml|com.verizon.embms.xml|com.verizon.provider.xml|VerizonUnifiedSettings.jar|VZWAPNLib.apk|VZWAPNService.apk|VZWAVS.apk|VzwLcSilent.apk|vzw_msdc_api.apk|VzwOmaTrigger.apk|vzw_sso_permissions.xml|com.vzw.vzwapnlib.xml";

	#Voice Recognition
	blobs=$blobs"|aonvr1.bin|aonvr2.bin|audiomonitor|HotwordEnrollment.apk|libadpcmdec.so|liblistenhardware.so|liblistenjni.so|liblisten.so|liblistensoundmodel.so|librecoglib.so|libsmwrapper.so|libsupermodel.so|libtrainingcheck.so|sound_trigger.primary.msm8916.so|sound_trigger.primary.msm8996.so";

	grep -vE "("$blobs")" $blobList > $blobList".new"; #Remove the bad blobs from the manifest
	mv $blobList".new" $blobList; #Move the new list into place
	delta=$(($(wc -l < $blobList".bak") - $(wc -l < $blobList))); #Calculate the difference in size
	echo "Removed "$delta" blobs from "$dir$blobList; #Inform the user
	sh -c "cd $base$dir && ./setup-makefiles.sh"; #Update the makefiles
	cd $base;
}

#Find all using: cd device && find . -name "*proprietary*.txt" | grep -v ".bak"
deblob "device/amazon/hdx-common/" "proprietary-adreno-files.txt";
deblob "device/amazon/hdx-common/" "proprietary-files.txt";
deblob "device/asus/msm8916-common/" "proprietary-files.txt";
deblob "device/lge/g3-common/" "proprietary-files.txt";
deblob "device/motorola/msm8916-common/" "proprietary-files.txt";
deblob "device/oppo/msm8974-common/" "device-proprietary-files.txt";
deblob "device/oppo/msm8974-common/" "proprietary-files.txt";
deblob "device/amazon/thor/" "proprietary-files.txt";
deblob "device/asus/Z00T/" "proprietary-files.txt";
deblob "device/huawei/angler/" "lineage-proprietary-blobs.txt";
deblob "device/huawei/angler/" "lineage-proprietary-blobs-vendorimg.txt";
deblob "device/huawei/angler/" "proprietary-blobs.txt";
deblob "device/google/marlin/" "device-proprietary-files.txt";
deblob "device/lge/bullhead/" "proprietary-blobs.txt";
deblob "device/lge/bullhead/" "proprietary-blobs-vendorimg.txt";
deblob "device/lge/hammerhead/" "proprietary-blobs.txt";
deblob "device/lge/mako/" "proprietary-blobs.txt";
#cd "vendor/lge/mako" && mv mako-vendor-blobs.mk mako-vendor.mk; #Creates malformed makefiles due to commit a85aa35fda31ef77b7424d0be108b0a5a2e71edf
deblob "device/lge/vs985/" "proprietary-files.txt";
deblob "device/motorola/clark/" "proprietary-files.txt";
deblob "device/motorola/osprey/" "proprietary-files.txt";
deblob "device/moto/shamu/" "device-proprietary-files.txt";
deblob "device/moto/shamu/" "proprietary-blobs.txt";
echo "vendor/lib/libcneapiclient.so" >> device/oneplus/bacon/proprietary-files-qc.txt; #Commit b7b6d94529e17ce51566aa6509cebab6436b153d disabled CNE but left this binary in the makefile vendor since NetMgr requires it. Without this line rerunning setup-makefiles.sh breaks cell service, since the resulting build will be missing it.
deblob "device/oneplus/bacon/" "proprietary-files-qc.txt";
deblob "device/oneplus/bacon/" "proprietary-files.txt";
