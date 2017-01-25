#!/bin/bash
base="/home/tad/Android/Build/LineageOS-14.1/"
deblob() { #TODO: 
	dir=$1
	blobList=$2;
	cd $base$dir; #Enter the target directory
	cp $blobList $blobList".bak"; #Make a backup
	blobs="";
	
	#Blobs to *NOT* remove: ADSP (Hardware audio decoding), Venus (Hardware video decoding), Gatekeeper/Keystore/Qseecom/Trustzone (Hardware encryption)

	#ATFWD (Wireless Display)
	blobs=$blobs"ATFWD-daemon|atfwd.apk";

	#CNE/DPM (Automatic Cell/Wi-Fi Switching) XXX: Requires unsetting 'BOARD_USES_QCNE' in BoardConfig.mk and 'persist.cne.feature'/'persist.dpm.feature' in system.prop. XXX: Breaks radio
	#blobs=$blobs"|andsfCne.xml|ATT_profile1.xml|ATT_profile2.xml|ATT_profile3.xml|ATT_profile4.xml|ATT_profiles.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.quicinc.cne.jar|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|libcneapiclient.so|libcneconn.so|libcneqmiutils.so|libcne.so|libNimsWrap.so|libvendorconn.so|libwqe.so|libxml.so|profile1.xml|profile2.xml|profile3.xml|profile4.xml|profile5.xml|ROW_profile1.xml|ROW_profile2.xml|ROW_profile3.xml|ROW_profile4.xml|ROW_profile5.xml|ROW_profiles.xml|SwimConfig.xml|VZW_profile1.xml|VZW_profile2.xml|VZW_profile3.xml|VZW_profile4.xml|VZW_profile5.xml|VZW_profile6.xml|VZW_profiles.xml";

	#DivX (DRM)
	blobs=$blobs"|DxHDCP.cfg|dxhdcp2.b00|dxhdcp2.b01|dxhdcp2.b02|dxhdcp2.b03|dxhdcp2.mdt|libDxHdcp.so|libSHIMDivxDrm.so";

	#DPM (?) XXX: Requires unsetting 'persist.dpm.feature' in system.prop.
	blobs=$blobs"|com.qti.dpmframework.jar|com.qti.dpmframework.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libdpmctmgr.so|libdpmfdmgr.so|libdpmframework.so|libdpmnsrm.so|libdpmtcm.so|NsrmConfiguration.xml|tcmclient.jar";

	#DRM XXX: Breaks full disk encryption
	#blobs=$blobs"|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libtzdrmgenprov.so";

	#Google Widevine (DRM)
	blobs=$blobs"|com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|libdrmwvmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|widevine.b00|widevine.b01|widevine.b02|widevine.b03|widevine.mdt";

	#GPS XXX: TEST THIS
	#blobs=$blobs"|com.qti.location.sdk.jar|com.qti.location.sdk.xml|com.qualcomm.location.apk|com.qualcomm.location.vzw_library.jar|com.qualcomm.location.vzw_library.xml|com.qualcomm.location.xml|flp.conf|izat.xt.srv.jar|izat.xt.srv.xml|libalarmservice_jni.so|libasn1cper.so|libasn1crt.so|libasn1crtx.so|libdataitems.so|libdrplugin_client.so|libDRPlugin.so|libevent_observer.so|libflp.so|libgdtap.so|libgeofence.so|libgps.utils.so|libizat_core.so|liblbs_core.so|libloc_api_v02.so|liblocationservice_glue.so|liblocationservice.so|libloc_core.so|libloc_ds_api.so|libloc_eng.so|libloc_ext.so|liblowi_client.so|liblowi_wifihal_nl.so|liblowi_wifihal.so|libquipc_os_api.so|libquipc_ulp_adapter.so|libulp2.so|libxtadapter.so|libxt_native.so|libxtwifi_ulp_adaptor.so|libxtwifi_zpp_adaptor.so|location-mq|loc_launcher|lowi-server|slim_ap_daemon|slim_daemon|xtwifi-client|xtwifi-inet-agent";

	#HDCP (DRM)
	blobs=$blobs"|libmm-hdcpmgr.so";

	#IPACM (Splits traffic between Cell/Wi-Fi)
	blobs=$blobs"|ipacm|ipacm-diag";
	rm -rf data-ipa-cfg-mgr; #Remove the second half of IPACM

	#Microsoft Playready (DRM)
	blobs=$blobs"|playread.b00|playread.b01|playread.b02|playread.b03|playread.mdt";

	#Misc
	blobs=$blobs"|libuiblur.so";

	#Motorola
	blobs=$blobs"|com.motorola.motosignature.jar|com.motorola.motosignature.xml|MotoSignatureApp.apk|com.motorola.DirectedSMSProxy.xml|AppDirectedSMSProxy.apk";

	#QTI (Tethering Extensions)
	blobs=$blobs"|libQtiTether.so|QtiTetherService.apk";

	#Sprint
	blobs=$blobs"|com.android.omadm.service.xml|ConnMO.apk|CQATest.apk|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|GCS.apk|HiddenMenu.apk|libdmengine.so|libdmjavaplugin.so|LifetimeData.apk|SprintDM.apk|SprintHM.apk|whitelist_com.android.omadm.service.xml";

	#Time Service XXX: Breaks time, can be replaced with https://github.com/LineageOS/android_hardware_sony_timekeep
	#blobs=$blobs"|libtime_genoff.so|libTimeService.so|time_daemon|TimeService.apk";

	#Verizon
	blobs=$blobs"|com.verizon.apn.xml|com.verizon.embms.xml|com.verizon.provider.xml|VerizonUnifiedSettings.jar|VZWAPNLib.apk|VZWAPNService.apk|VZWAVS.apk|VzwLcSilent.apk|vzw_msdc_api.apk|VzwOmaTrigger.apk|vzw_sso_permissions.xml|com.vzw.vzwapnlib.xml";

	#Voice recognition
	blobs=$blobs"|aonvr1.bin|aonvr2.bin|com.motorola.triggerenroll.xml|HotwordEnrollment.apk|libadpcmdec.so|liblistenhardware.so|liblistenjni.so|liblisten.so|liblistensoundmodel.so|librecoglib.so|libsmwrapper.so|libsupermodel.so|libtrainingcheck.so|sound_trigger.primary.msm8996.so|TriggerEnroll.apk|TriggerTrainingService.apk";

	grep -vE "("$blobs")" $blobList > $blobList".new"; #Remove the bad blobs from the manifest
	mv $blobList".new" $blobList; #Move the new list into place
	delta=$(($(wc -l < $blobList".bak") - $(wc -l < $blobList))); #Calculate the difference in size
	echo "Removed "$delta" blobs from "$dir$blobList; #Inform the user
	sh -c "cd $base$dir && ./setup-makefiles.sh"; #Update the makefiles
}

#Find all using: cd device && find . -name "*proprietary*" | grep -v ".bak"
deblob "device/amazon/hdx-common/" "proprietary-adreno-files.txt";
deblob "device/amazon/hdx-common/" "proprietary-files.txt";
deblob "device/amazon/thor/" "proprietary-files.txt";
deblob "device/asus/msm8916-common/" "proprietary-files.txt";
deblob "device/asus/Z00T/" "proprietary-files.txt";
deblob "device/huawei/angler/" "lineage-proprietary-blobs.txt";
deblob "device/huawei/angler/" "lineage-proprietary-blobs-vendorimg.txt";
deblob "device/huawei/angler/" "proprietary-blobs.txt";
deblob "device/google/marlin/" "device-proprietary-files.txt";
deblob "device/lge/bullhead/" "proprietary-blobs.txt";
deblob "device/lge/bullhead/" "proprietary-blobs-vendorimg.txt";
deblob "device/lge/g3-common/" "proprietary-files.txt";
deblob "device/lge/hammerhead/" "proprietary-blobs.txt";
#deblob "device/lge/mako/" "proprietary-blobs.txt"; #FIXME: Creates malformed makefiles for some reason
deblob "device/lge/vs985/" "proprietary-files.txt";
deblob "device/motorola/clark/" "proprietary-files.txt";
deblob "device/moto/shamu/" "device-proprietary-files.txt";
deblob "device/moto/shamu/" "proprietary-blobs.txt";
deblob "device/oneplus/bacon/" "proprietary-files-qc.txt";
deblob "device/oneplus/bacon/" "proprietary-files.txt";
deblob "device/oppo/msm8974-common/" "device-proprietary-files.txt";
deblob "device/oppo/msm8974-common/" "proprietary-files.txt";
