base="/home/tad/Android/Build/LineageOS-14.1/"
deblob() {
	dir=$1
	blobList=$2;
	cd $base$dir; #Enter the target directory
	echo "[DEBLOBBING] "$dir; #Inform the user
	cp $blobList $blobList".bak"; #Make a backup
	#
	#START OF REMOVAL
	#
	#grep -vE "()" $blobList $blobList".new";

	#Nuke CNE/DPM
	grep -vE "(andsfCne.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.motorola.motosignature.jar|com.motorola.motosignature.xml|com.qti.dpmframework.jar|com.qti.dpmframework.xml|com.quicinc.cne.jar|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libcneapiclient.so|libcneconn.so|libcneqmiutils.so|libcne.so|libdpmframework.so|libdpmnsrm.so|libNimsWrap.so|libvendorconn.so|libwqe.so|NsrmConfiguration.xml|SwimConfig.xml)" $blobList $blobList".new";

	#Nuke DRM files
	grep -vE "(dxhdcp2.b00|dxhdcp2.b01|dxhdcp2.b02|dxhdcp2.b03|dxhdcp2.mdt|libdrmfs.so|libdrmtime.so|libdrmwvmplugin.so|libDxHdcp.so|libmm-hdcpmgr.so|libSHIMDivxDrm.so|libtzdrmgenprov.so|libwvdrmengine.so|libwvdrm_L1.so|libwvm.so|libWVStreamControlAPI_L1.so|widevine.b00|widevine.b01|widevine.b02|widevine.b03|widevine.mdt|com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|playread.b00|playread.b01|playread.b02|playread.b03|playread.mdt)" $blobList $blobList".new";

	#Nuke Sprint files
	grep -vE "(com.android.omadm.service.xml|ConnMO.apk|CQATest.apk|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|GCS.apk|HiddenMenu.apk|libdmengine.so|libdmjavaplugin.so|LifetimeData.apk|SprintDM.apk|whitelist_com.android.omadm.service.xml)" $blobList $blobList".new";

	#
	#END OF REMOVAL
	#
	mv $blobList".new" $blobList; #Move the new list into place
	source setup-makefiles.sh; #Update the make files
}

deblob "device/amazon/hdx-common/" "proprietary-adreno-files.txt"
deblob "device/amazon/hdx-common/" "proprietary-files.txt"
deblob "device/amazon/thor/" "proprietary-files.txt"
deblob "device/asus/msm8916-common/" "proprietary-files.txt"
deblob "device/asus/Z00T/" "proprietary-files.txt"
deblob "device/huawei/angler/" "lineage-proprietary-blobs.txt"
deblob "device/huawei/angler/" "lineage-proprietary-blobs-vendorimg.txt"
deblob "device/huawei/angler/" "proprietary-blobs.txt"
deblob "device/lge/bullhead/" "proprietary-blobs.txt"
deblob "device/lge/bullhead/" "proprietary-blobs-vendorimg.txt"
deblob "device/lge/g3-common/" "proprietary-files.txt"
deblob "device/lge/hammerhead/" "proprietary-blobs.txt"
deblob "device/lge/mako/" "proprietary-blobs.txt"
deblob "device/lge/vs985/" "proprietary-files.txt"
deblob "device/motorola/clark/" "proprietary-files.txt"
deblob "device/moto/shamu/" "device-proprietary-files.txt"
deblob "device/oneplus/bacon/" "proprietary-files-qc.txt"
deblob "device/oneplus/bacon/" "proprietary-files.txt"
deblob "device/oppo/msm8974-common/" "proprietary-files.txt"
