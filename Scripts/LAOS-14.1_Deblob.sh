#!/bin/bash
base="/home/tad/Android/Build/LineageOS-14.1/"
deblob() {
	dir=$1
	blobList=$2;
	cd $base$dir; #Enter the target directory
	cp $blobList $blobList".bak"; #Make a backup
	#
	#START OF REMOVAL
	#
	#TODO: GPS, IZat, Location Provider, Tether Extensions, Wireless Display
	#
	#grep -vE "()" $blobList > $blobList".new";

	#Nuke CNE/DPM XXX: Requires unsetting 'BOARD_USES_QCNE' in BoardConfig.mk and 'persist.cne.feature'/'persist.dpm.feature' in system.prop. XXX: Breaks radio, requires hexediting
	#grep -vE "(andsfCne.xml|ATT_profiles.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.motorola.motosignature.jar|com.motorola.motosignature.xml|com.qti.dpmframework.jar|com.qti.dpmframework.xml|com.quicinc.cne.jar|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libcneapiclient.so|libcneconn.so|libcneqmiutils.so|libcne.so|libdpmframework.so|libdpmnsrm.so|libNimsWrap.so|libvendorconn.so|libwqe.so|NsrmConfiguration.xml|ROW_profiles.xml|SwimConfig.xml|VZW_profiles.xml)" $blobList > $blobList".new";
	#mv $blobList".new" $blobList; #Move the new list into place

	#Nuke DivX files
	grep -vE "(dxhdcp2.b00|dxhdcp2.b01|dxhdcp2.b02|dxhdcp2.b03|dxhdcp2.mdt|libDxHdcp.so|libSHIMDivxDrm.so)" $blobList > $blobList".new";
	mv $blobList".new" $blobList; #Move the new list into place

	#Nuke DRM files XXX: Breaks FDE
	#grep -vE "(libmm-hdcpmgr.so|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libtzdrmgenprov.so)" $blobList > $blobList".new";
	#mv $blobList".new" $blobList; #Move the new list into place

	#Nuke Microsoft Playready files
	grep -vE "(playread.b00|playread.b01|playread.b02|playread.b03|playread.mdt)" $blobList > $blobList".new";
	mv $blobList".new" $blobList; #Move the new list into place

	#Nuke Sprint files
	grep -vE "(com.android.omadm.service.xml|ConnMO.apk|CQATest.apk|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|GCS.apk|HiddenMenu.apk|libdmengine.so|libdmjavaplugin.so|LifetimeData.apk|SprintDM.apk|SprintHM.apk|whitelist_com.android.omadm.service.xml)" $blobList > $blobList".new";
	mv $blobList".new" $blobList; #Move the new list into place

	#Nuke Verizon files
	grep -vE "(com.verizon.apn.xml|com.verizon.embms.xml|com.verizon.provider.xml|VerizonUnifiedSettings.jar|VZWAPNLib.apk|VZWAPNService.apk|VZWAVS.apk|VzwLcSilent.apk|vzw_msdc_api.apk|VzwOmaTrigger.apk|vzw_sso_permissions.xml)" $blobList > $blobList".new";
	mv $blobList".new" $blobList; #Move the new list into place

	#Nuke Widevine files
	grep -vE "(com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|libdrmwvmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|widevine.b00|widevine.b01|widevine.b02|widevine.b03|widevine.mdt)" $blobList > $blobList".new";
	mv $blobList".new" $blobList; #Move the new list into place

	#
	#END OF REMOVAL
	#
	delta=$(($(wc -l < $blobList".bak") - $(wc -l < $blobList))); #Calculate the difference in size
	echo "Removed "$delta" blobs from "$blobList; #Inform the user
	sh -c "cd $base$dir && ./setup-makefiles.sh"; #Update the makefiles
}

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
deblob "device/oneplus/bacon/" "proprietary-files-qc.txt";
deblob "device/oneplus/bacon/" "proprietary-files.txt";
deblob "device/oppo/msm8974-common/" "device-proprietary-files.txt";
deblob "device/oppo/msm8974-common/" "proprietary-files.txt";
