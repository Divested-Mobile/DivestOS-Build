#!/bin/bash

base="/home/tad/Android/Build/LineageOS-14.1/";
export base;

#
#START OF BLOBS ARRAY
#
	blobs="";

	#ATFWD (Miracast/Wireless Display)
	blobs=$blobs"ATFWD-daemon|atfwd.apk";

	#CNE Core XXX: Breaks radio
	#blobs=$blobs"|libcneapiclient.so";

	#CNE (Automatic Cell/Wi-Fi Switching)
	blobs=$blobs"|andsfCne.xml|ATT_profile1.xml|ATT_profile2.xml|ATT_profile3.xml|ATT_profile4.xml|ATT_profiles.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.quicinc.cne.jar|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|libcneconn.so|libcneqmiutils.so|libcne.so|libNimsWrap.so|libvendorconn.so|libwqe.so|profile1.xml|profile2.xml|profile3.xml|profile4.xml|profile5.xml|ROW_profile1.xml|ROW_profile2.xml|ROW_profile3.xml|ROW_profile4.xml|ROW_profile5.xml|ROW_profiles.xml|SwimConfig.xml|VZW_profile1.xml|VZW_profile2.xml|VZW_profile3.xml|VZW_profile4.xml|VZW_profile5.xml|VZW_profile6.xml|VZW_profiles.xml";

	#Diagnostics
	blobs=$blobs"|[/]diag[/]|diag_callback_client|diag_dci_sample|diag_klog|diag_mdlog|diag_mdlog-getlogs|diag_mdlog-wrap|diag[/]mdm|diag_qshrink4_daemon|diag_socket_log|diag_uart_log|drmdiagapp|ibdrmdiag.so|ssr_diag|test_diag";

	#Discretix (DRM/HDCP)
	blobs=$blobs"|discretix|DxHDCP.cfg|dxhdcp2.b00|dxhdcp2.b01|dxhdcp2.b02|dxhdcp2.b03|dxhdcp2.mdt|libDxHdcp.so";

	#DivX (DRM)
	blobs=$blobs"|libDivxDrm.so|libSHIMDivxDrm.so";

	#DPM (Data Power Management)
	blobs=$blobs"|com.qti.dpmframework.jar|com.qti.dpmframework.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libdpmctmgr.so|libdpmfdmgr.so|libdpmframework.so|libdpmnsrm.so|libdpmtcm.so|NsrmConfiguration.xml|tcmclient.jar";

	#DRM XXX: Breaks full disk encryption
	#blobs=$blobs"|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libtzdrmgenprov.so";

	#Google Project Fi
	blobs=$blobs"|Tycho.apk";

	#Google Widevine (DRM)
	blobs=$blobs"|com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|libdrmwvmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|widevine.b00|widevine.b01|widevine.b02|widevine.b03|widevine.mdt";

	#GPS XXX: Breaks GPS
	#blobs=$blobs"|flp.conf|flp.default.so|flp.msm8084.so|flp.msm8960.so|gpsd|gps.msm8084.so|gps.msm8960.so|libflp.so|libgps.utils.so|libloc_api_v02.so|libloc_core.so|libloc_ds_api.so|libloc_eng.so|libloc_ext.so";

	#HDCP (DRM)
	blobs=$blobs"|libmm-hdcpmgr.so";

	#IPACM (Loadbalances traffic between Cell/Wi-Fi)
	blobs=$blobs"|ipacm|ipacm-diag";

	#Location (gpsOne/gpsOneXTRA/IZat/Lumicast/QUIP)
	blobs=$blobs"|com.qti.location.sdk.jar|com.qti.location.sdk.xml|com.qualcomm.location.apk|com.qualcomm.location.vzw_library.jar|com.qualcomm.location.vzw_library.xml|com.qualcomm.location.xml|gpsone_daemon|izat.xt.srv.jar|izat.xt.srv.xml|libalarmservice_jni.so|libasn1cper.so|libasn1crt.so|libasn1crtx.so|libdataitems.so|libdrplugin_client.so|libDRPlugin.so|libevent_observer.so|libgdtap.so|libgeofence.so|libizat_core.so|liblbs_core.so|liblocationservice_glue.so|liblocationservice.so|liblowi_client.so|liblowi_wifihal_nl.so|liblowi_wifihal.so|libquipc_os_api.so|libquipc_ulp_adapter.so|libulp2.so|libxtadapter.so|libxt_native.so|libxtwifi_ulp_adaptor.so|libxtwifi_zpp_adaptor.so|location-mq|loc_launcher|lowi-server|slim_ap_daemon|slim_daemon|xtwifi-client|xtwifi-inet-agent";

	#Microsoft Playready (DRM)
	blobs=$blobs"|playread.b00|playread.b01|playread.b02|playread.b03|playread.mdt";

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

	export blobs;
#
#END OF BLOBS ARRAY
#

#
#START OF FUNCTIONS
#
deblobDevice() {
	devicePath=$1;
	cd $base$devicePath;
	if [ -f BoardConfig.mk ]; then 
		sed -i 's/BOARD_USES_QCNE := true/BOARD_USES_QCNE := false/' BoardConfig.mk; 
	fi;
	if [ -f system.prop ]; then
		sed -i 's/persist.cne.feature=./persist.cne.feature=0/' system.prop;
		sed -i 's/persist.dpm.feature=./persist.dpm.feature=0/' system.prop;
		sed -i 's/persist.gps.qc_nlp_in_use=1/persist.gps.qc_nlp_in_use=0/' system.prop;
		if ! grep -q "drm.service.enabled=false" system.prop; then echo "drm.service.enabled=false" >> system.prop; fi;
	fi;
	rm -rf data-ipa-cfg-mgr; #Remove the second half of IPACM
	rm -rf libshimwvm; #Remove the compatibility module
	if [ -f setup-makefiles.sh ]; then
		awk -i inplace '!/'$blobs'/' *proprietary*.txt; #Remove all blob references from blob manifest
		sh -c "cd $base$devicePath && ./setup-makefiles.sh"; #Update the makefiles
	fi;
	cd $base;
}
export -f deblobDevice;

deblobVendors() {
	cd $base;
	find vendor -regextype posix-extended -regex '.*('$blobs')' -type f -delete;
}

deblobVendor() {
	makefile=$1;
	cd $base;
	awk -i inplace '!/'$blobs'/' $makefile; #Remove all blob references from makefile
}
export -f deblobVendor;
#
#END OF FUNCTIONS
#

#
#START OF DEBLOBBING
#
find device -maxdepth 2 -mindepth 2 -type d -exec bash -c 'deblobDevice "$0"' {} \; #Deblob all device directories
find vendor -name "*vendor*.mk" -type f -exec bash -c 'deblobVendor "$0"' {} \; #Deblob all makefiles
deblobVendors; #Deblob entire vendor directory
#
#END OF DEBLOBBING
#
