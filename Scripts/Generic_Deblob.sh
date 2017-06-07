#!/bin/bash
#Copyright (c) 2017 Spot Communications, Inc.

#Goal: Remove as many proprietary blobs without breaking core functionality
#Outcome: Increased battery/performance/privacy/security, Decreased ROM size
#TODO: Clean init*.rc files, Modularize, Remove more variants

#
#Device Status (Tested under LineageOS 14.1)
#
#Functioning as Expected: bacon, clark, mako

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/";
export base;

#
#START OF BLOBS ARRAY
#
	blobs=""; #Delimited using "|"
	makes="";
	kernels=""; #Delimited using " "

	#ACDB (Audio Configurations) [Qualcomm] XXX: Breaks audio output
	#blobs=$blobs"acdb";

	#ADSP/Hexagon (Hardware Audio Decoding) [Qualcomm]
	#blobs=$blobs"adsprpcd|libadsprpc.so|libadsprpc.so|libfastcvadsp_stub.so|libfastcvopt.so|libadsp_fd_skel.so";

	#Alipay (Payment Platform) [Alibaba]
	blobs=$blobs"alipay.b00|alipay.b01|alipay.b02|alipay.b03|alipay.b04|alipay.b05|alipay.b06|alipay.mdt";

	#aptX (Bluetooth Audio Compression Codec) [Qualcomm]
	blobs=$blobs"|libaptX-1.0.0-rel-Android21-ARMv7A.so|libaptXHD-1.0.0-rel-Android21-ARMv7A.so|libaptXScheduler.so";

	#ATFWD [Qualcomm]
	blobs=$blobs"|ATFWD-daemon|atfwd.apk";

	#AudioFX (Audio Effects) [Qualcomm]
	blobs=$blobs"|libqcbassboost.so|libqcreverb.so|libqcvirt.so";

	#Camera
	#I tried, don't waste your time...
	#FUN FACT: The Huawei Honor 5x ships with eight-hundred-and-thirty-five (*835*) proprietary camera blobs.
	#blobs=$blobs"|";

	#Clearkey (DRM) [Google]
	blobs=$blobs"|libdrmclearkeyplugin.so";

	#CMN (DRM) [Unknown]
	blobs=$blobs"|cmnlib.b00|cmnlib.b01|cmnlib.b02|cmnlib.b03|cmnlib.b04|cmnlib.b05|cmnlib.mdt|cmnlib64.b00|cmnlib64.b01|cmnlib64.b02|cmnlib64.b03|cmnlib64.b04|cmnlib64.b05|cmnlib64.mdt";

	#CNE (Automatic Cell/Wi-Fi Switching) [Qualcomm]
	#blobs=$blobs"|libcneapiclient.so"; #XXX: Breaks radio
	blobs=$blobs"|andsfCne.xml|ATT_profile1.xml|ATT_profile2.xml|ATT_profile3.xml|ATT_profile4.xml|ATT_profiles.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.quicinc.cne.jar|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|libcneconn.so|libcneqmiutils.so|libcne.so|libNimsWrap.so|libvendorconn.so|libwqe.so|profile1.xml|profile2.xml|profile3.xml|profile4.xml|profile5.xml|ROW_profile1.xml|ROW_profile2.xml|ROW_profile3.xml|ROW_profile4.xml|ROW_profile5.xml|ROW_profiles.xml|SwimConfig.xml|VZW_profile1.xml|VZW_profile2.xml|VZW_profile3.xml|VZW_profile4.xml|VZW_profile5.xml|VZW_profile6.xml|VZW_profiles.xml";
	makes=$makes"libcnefeatureconfig";

	#Diagnostics [Qualcomm]
	blobs=$blobs"|[/]diag[/]|diag_callback_client|diag_dci_sample|diag_klog|diag_mdlog|diag_mdlog-getlogs|diag_mdlog-wrap|diag[/]mdm|diag_qshrink4_daemon|diag_socket_log|diag_uart_log|drmdiagapp|ibdrmdiag.so|ssr_diag|test_diag";

	#Discretix (DRM/HDCP) [Discretix Technologies]
	blobs=$blobs"|discretix|DxHDCP.cfg|dxhdcp2.b00|dxhdcp2.b01|dxhdcp2.b02|dxhdcp2.b03|dxhdcp2.mdt|libDxHdcp.so";

	#Display Color Tuning [Qualcomm]
	blobs=$blobs"|colorservice.apk|com.qti.snapdragon.sdk.display.jar|com.qti.snapdragon.sdk.display.xml|libdisp-aba.so|libmm-abl-oem.so|libmm-abl.so|libmm-als.so|libmm-color-convertor.so|libmm-disp-apis.so|libmm-qdcm.so|libsd_sdk_display.so|mm-pp-daemon|mm-pp-dpps|PPPreference.apk";

	#DivX (DRM) [DivX]
	blobs=$blobs"|libDivxDrm.so|libSHIMDivxDrm.so";

	#DPM (Data Power Management) [Qualcomm]
	blobs=$blobs"|com.qti.dpmframework.jar|com.qti.dpmframework.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libdpmctmgr.so|libdpmfdmgr.so|libdpmframework.so|libdpmnsrm.so|libdpmtcm.so|NsrmConfiguration.xml|tcmclient.jar";

	#DRM
	#blobs=$blobs"|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libtzdrmgenprov.so"; #XXX: Breaks full disk encryption
	blobs=$blobs"|lib-sec-disp.so|libSecureUILib.so|libsecureui.so|libsecureuisvc_jni.so|libsecureui_svcsock.so";

	#Face Unlock [Google]
	blobs=$blobs"|libfacenet.so|libfilterpack_facedetect.so|libfrsdk.so";

	#GPS [Qualcomm]
	#blobs=$blobs"|flp.conf|flp.default.so|flp.msm8084.so|flp.msm8960.so|gpsd|gps.msm8084.so|gps.msm8960.so|libflp.so|libgps.utils.so|libloc_api_v02.so|libloc_core.so|libloc_ds_api.so|libloc_eng.so|libloc_ext.so";

	#HDCP (DRM)
	blobs=$blobs"|libmm-hdcpmgr.so|hdcp1.b00|hdcp1.b01|hdcp1.b02|hdcp1.b03|hdcp1.b04|hdcp1.b05|hdcp1.b06|hdcp1.mdt|tzhdcp.b00|tzhdcp.b01|tzhdcp.b02|tzhdcp.b03|tzhdcp.mdt";

	#[HTC]
	blobs=$blobs"|htc_drmprov.b00|htc_drmprov.b01|htc_drmprov.b02|htc_drmprov.b03|htc_drmprov.b04|htc_drmprov.b05|htc_drmprov.b06|htc_drmprov.mdt|gptauuid.xml|gpsample.mbn";

	#I/O Prefetcher [Qualcomm]
	blobs=$blobs"|iop|libqc-opt.so|libqti-iop-client.so|libqti-iop.so|QPerformance.jar";

	#IMS (VoLTE/Wi-Fi Calling) [Qualcomm]
	#blobs=$blobs"|ims.apk|ims.xml|libimsmedia_jni.so"; #IMS (Core)
	blobs=$blobs"|imscmlibrary.jar|imscmservice|imscm.xml|imsdatadaemon|imsqmidaemon|imssettings.apk|lib-imsdpl.so|lib-imscamera.so|lib-imsqimf.so|lib-imsSDP.so|lib-imss.so|lib-imsvt.so|lib-imsxml.so"; #IMS
	blobs=$blobs"|ims_rtp_daemon|lib-rtpcommon.so|lib-rtpcore.so|lib-rtpdaemoninterface.so|lib-rtpsl.so"; #RTP
	blobs=$blobs"|lib-dplmedia.so|librcc.so|libvcel.so|libvoice-svc.so|qti_permissions.xml|volte_modem[/]"; #Misc.

	#IPA (Internet Packet Accelerator) [Qualcomm]
	#This is actually open source (excluding -diag), but doesn't seem that benefical and has been shown vulnerable before
	#blobs=$blobs"|ipacm";
	blobs=$blobs"|ipacm-diag";
	#makes=$makes"|ipacm|IPACM_cfg.xml";
	#kernels=$kernels" drivers/platform/msm/ipa";

	#Location (gpsOne/gpsOneXTRA/IZat/Lumicast/QUIP) [Qualcomm]
	blobs=$blobs"|com.qti.location.sdk.jar|com.qti.location.sdk.xml|com.qualcomm.location.apk|com.qualcomm.location.xml|gpsone_daemon|izat.conf|izat.xt.srv.jar|izat.xt.srv.xml|libalarmservice_jni.so|libasn1cper.so|libasn1crt.so|libasn1crtx.so|libdataitems.so|libdrplugin_client.so|libDRPlugin.so|libevent_observer.so|libgdtap.so|libgeofence.so|libizat_core.so|liblbs_core.so|liblocationservice_glue.so|liblocationservice.so|libloc_ext.so|libloc_xtra.so|liblowi_client.so|liblowi_wifihal_nl.so|liblowi_wifihal.so|libquipc_os_api.so|libquipc_ulp_adapter.so|libulp2.so|libxtadapter.so|libxt_native.so|libxtwifi_ulp_adaptor.so|libxtwifi_zpp_adaptor.so|location-mq|loc_launcher|lowi.conf|lowi-server|slim_ap_daemon|slim_daemon|xtra_t_app.apk|xtwifi-client|xtwifi-inet-agent";

	#Misc
	blobs=$blobs"|libjni_latinime.so|libuiblur.so|libwifiscanner.so";

	#[Motorola]
	blobs=$blobs"|AppDirectedSMSProxy.apk|BuaContactAdapter.apk|batt_health|com.motorola.DirectedSMSProxy.xml|com.motorola.motosignature.jar|com.motorola.motosignature.xml|com.motorola.camera.xml|com.motorola.gallery.xml|com.motorola.msimsettings.xml|com.motorola.triggerenroll.xml|MotoDisplayFWProxy.apk|MotoSignatureApp.apk|TriggerEnroll.apk|TriggerTrainingService.apk";
	makes=$makes"|com.motorola.cameraone.xml";

	#Performance [Qualcomm]
	#blobs=$blobs"|msm_irqbalance";
	#New devices don't seem to hotplug cores without this
	#I tried to replace this with showp1984's msm_mpdecision, but the newer kernels simply don't have the mach_msm dependencies that are needed
	#blobs=$blobs"|mpdecision|libqti-perfd-client.so|perfd|perf-profile0.conf|perf-profile1.conf|perf-profile2.conf|perf-profile3.conf|perf-profile4.conf|perf-profile5.conf";

	#Playready (DRM) [Microsoft]
	blobs=$blobs"|playread.b00|playread.b01|playread.b02|playread.b03|playread.mdt";

	#Project Fi [Google]
	blobs=$blobs"|Tycho.apk";

	#Quickboot [Qualcomm]
	blobs=$blobs"|QuickBoot.apk";

	#QTI (Tethering Extensions) [Qualcomm]
	blobs=$blobs"|libQtiTether.so|QtiTetherService.apk";

	#RCS (Proprietary messaging protocol)
	blobs=$blobs"|rcsimssettings.jar|rcsimssettings.xml|rcsservice.jar|rcsservice.xml|lib-imsrcscmclient.so|lib-ims-rcscmjni.so|lib-imsrcscmservice.so|lib-imsrcscm.so|lib-imsrcs.so|lib-rcsimssjni.so|lib-rcsjni.so"; #RCS

	#SecProtect [Qualcomm]
	blobs=$blobs"|SecProtect.apk";

	#SoundFX [Sony]
	blobs=$blobs"|libsonypostprocbundle.so|libsonysweffect.so";

	#[Sprint]
	blobs=$blobs"|com.android.omadm.service.xml|ConnMO.apk|CQATest.apk|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|GCS.apk|HiddenMenu.apk|libdmengine.so|libdmjavaplugin.so|LifetimeData.apk|SprintDM.apk|SprintHM.apk|whitelist_com.android.omadm.service.xml";

	#Thermal Throttling [Qualcomm]
	#blobs=$blobs"|libthermalclient.so|libthermalioctl.so|thermal-engine";

	#Time Service [Qualcomm]
	#XXX: Requires that https://github.com/LineageOS/android_hardware_sony_timekeep be included in repo manifest
	#blobs=$blobs"|libtime_genoff.so"; #XXX: Breaks radio
	blobs=$blobs"|libTimeService.so|time_daemon|TimeService.apk";

	#Venus (Hardware Video Decoding) [Qualcomm]
	#blobs=$blobs"|venus.b00|venus.b01|venus.b02|venus.b03|venus.b04|venus.mbn|venus.mdt";

	#[Verizon]
	blobs=$blobs"|com.qualcomm.location.vzw_library.jar|com.qualcomm.location.vzw_library.xml|com.verizon.apn.xml|com.verizon.embms.xml|com.verizon.hardware.telephony.ehrpd.jar|com.verizon.hardware.telephony.ehrpd.xml|com.verizon.hardware.telephony.lte.jar|com.verizon.hardware.telephony.lte.xml|com.verizon.ims.jar|com.verizon.ims.xml|com.verizon.provider.xml|com.vzw.vzwapnlib.xml|qti-vzw-ims-internal.jar|qti-vzw-ims-internal.xml|VerizonUnifiedSettings.jar|VZWAPNLib.apk|VZWAPNService.apk|VZWAVS.apk|VzwLcSilent.apk|vzw_msdc_api.apk|VzwOmaTrigger.apk|vzw_sso_permissions.xml";

	#Voice Recognition
	blobs=$blobs"|aonvr1.bin|aonvr2.bin|audiomonitor|es305_fw.bin|HotwordEnrollment.apk|libadpcmdec.so|liblistenhardware.so|liblistenjni.so|liblisten.so|liblistensoundmodel.so|libqvop-service.so|librecoglib.so|libsmwrapper.so|libsupermodel.so|libtrainingcheck.so|qvop-daemon|sound_trigger.primary.msm8916.so|sound_trigger.primary.msm8996.so";

	#Vulkan [Qualcomm]
	#blobs=$blobs"|libllvm-qgl.so|vulkan.msm*.so";

	#Wfd (Wireless Display) [Qualcomm]
	blobs=$blobs"|libmmparser_lite.so|libmmrtpdecoder.so|libmmrtpencoder.so|libmmwfdinterface.so|libmmwfdsinkinterface.so|libmmwfdsrcinterface.so|libwfdavenhancements.so|libwfdcommonutils.so|libwfdhdcpcp.so|libwfdmmsink.so|libwfdmmsrc.so|libwfdmmutils.so|libwfdnative.so|libwfdrtsp.so|libwfdservice.so|libwfdsm.so|libwfduibcinterface.so|libwfduibcsinkinterface.so|libwfduibcsink.so|libwfduibcsrcinterface.so|libwfduibcsrc.so|WfdCommon.jar|wfdconfigsink.xml|wfdconfig.xml|wfdservice|WfdService.apk";

	#Widevine (DRM) [Google]
	blobs=$blobs"|com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|libdrmwvmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|tzwidevine.b00|tzwidevine.b01|tzwidevine.b02|tzwidevine.b03|tzwidevine.mdt|widevine.b00|widevine.b01|widevine.b02|widevine.b03|widevine.b04|widevine.b05|widevine.b06|widevine.mbn|widevine.mdt";
	makes=$makes"|libshim_wvm";

	#WiPower (Wireless Charging) [Qualcomm]
	blobs=$blobs"|a4wpservice.apk|com.quicinc.wbc.jar|com.quicinc.wbcserviceapp.apk|com.quicinc.wbcservice.jar|com.quicinc.wbcservice.xml|com.quicinc.wbc.xml|libwbc_jni.so|wbc_hal.default.so";
	makes=$makes"|android.wipower|android.wipower.xml|com.quicinc.wbcserviceapps|libwipower_jni|wipowerservice";

	export blobs;
	export makes;
	export kernels;
#
#END OF BLOBS ARRAY
#

#
#START OF FUNCTIONS
#
deblobDevice() {
	devicePath=$1;
	cd $base$devicePath;
	if [ "${PWD##*/}" == "flo" ] || [ "${PWD##*/}" == "mako" ]; then #Older devices don't seem to use time_daemon TODO: Automate or extend this
		replaceTime="false";
	fi;
	if [ -f Android.mk ]; then
		sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(CMN_SYMLINKS)//' Android.mk; #Remove CMN firmware
		sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(DXHDCP2_SYMLINKS)//' Android.mk; #Remove Discretix firmware
		#sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(IMS_SYMLINKS)//' Android.mk; #Remove IMS firmware
		sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(PLAYREADY_SYMLINKS)//' Android.mk; #Remove Microsoft Playready firmware
		sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(WIDEVINE_SYMLINKS)//' Android.mk; #Remove Google Widevine firmware
		sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(WV_SYMLINKS)//' Android.mk; #Remove Google Widevine firmware
	fi;
	if [ -f BoardConfig.mk ]; then 
		if [ -z "$replaceTime" ]; then
			sed -i 's/BOARD_USES_QC_TIME_SERVICES := true/BOARD_USES_QC_TIME_SERVICES := false/' BoardConfig.mk; #Switch to Sony TimeKeep
			if ! grep -q "BOARD_USES_QC_TIME_SERVICES := false" BoardConfig.mk; then echo "BOARD_USES_QC_TIME_SERVICES := false" >> BoardConfig.mk; fi; #Switch to Sony TimeKeep
		fi;
		sed -i 's/BOARD_USES_QCNE := true/BOARD_USES_QCNE := false/' BoardConfig.mk; #Disable CNE
		sed -i 's/BOARD_USES_WIPOWER := true/BOARD_USES_WIPOWER := false/' BoardConfig.mk; #Disable WiPower
	fi;
	if [ -f device.mk ]; then
		awk -i inplace '!/'$makes'/' device.mk; #Remove all shim references from device makefile
		if [ -z "$replaceTime" ]; then
			#Switch to Sony TimeKeep
			echo "PRODUCT_PACKAGES += \\" >> device.mk;
			echo "    timekeep \\" >> device.mk;
			echo "    TimeKeep" >> device.mk;
		fi;
	fi;
	if [ -f "${PWD##*/}".mk ] && [ "${PWD##*/}".mk != "sepolicy" ]; then
		awk -i inplace '!/'$makes'/' "${PWD##*/}".mk; #Remove all shim references from device makefile
		if [ -z "$replaceTime" ]; then
			#Switch to Sony TimeKeep
			echo "PRODUCT_PACKAGES += \\" >> "${PWD##*/}".mk;
			echo "    timekeep \\" >> "${PWD##*/}".mk;
			echo "    TimeKeep" >> "${PWD##*/}".mk;
		fi;
	fi;
	if [ -f system.prop ]; then
		sed -i 's/drm.service.enabled=true/drm.service.enabled=false/' system.prop;
		if ! grep -q "drm.service.enabled=false" system.prop; then echo "drm.service.enabled=false" >> system.prop; fi; #Disable DRM server
		sed -i 's/persist.bt.enableAptXHD=true/persist.bt.enableAptXHD=false/' system.prop; #Disable aptX
		sed -i 's/persist.cne.feature=./persist.cne.feature=0/' system.prop; #Disable CNE
		sed -i 's/persist.dpm.feature=./persist.dpm.feature=0/' system.prop; #Disable DPM
		sed -i 's/persist.gps.qc_nlp_in_use=./persist.gps.qc_nlp_in_use=0/' system.prop; #Disable QC Location Provider
		sed -i 's/persist.sys.dpmd.nsrm=./persist.sys.dpmd.nsrm=0/' system.prop; #Disable DPM
		sed -i 's/persist.rcs.supported=./persist.rcs.supported=0/' system.prop; #Disable RCS
		sed -i 's/ro.bluetooth.emb_wp_mode=true/ro.bluetooth.emb_wp_mode=false/' system.prop; #Disable WiPower
		sed -i 's/ro.bluetooth.wipower=true/ro.bluetooth.wipower=false/' system.prop; #Disable WiPower
		#Disable IMS
		#sed -i 's/persist.data.iwlan.enable=true/persist.data.iwlan.enable=false/' system.prop;
		#sed -i 's/persist.ims.volte=true/persist.ims.volte=false/' system.prop;
		#sed -i 's/persist.ims.vt=true/persist.ims.vt=false/' system.prop;
		#sed -i 's/persist.radio.calls.on.ims=true/persist.radio.calls.on.ims=false/' system.prop;
		#sed -i 's/persist.radio.hw_mbn_update=./persist.radio.hw_mbn_update=0/' system.prop;
		#sed -i 's/persist.radio.jbims=./persist.radio.jbims=0/' system.prop;
		#sed -i 's/persist.radio.sw_mbn_update=./persist.radio.sw_mbn_update=0/' system.prop;
		#sed -i 's/persist.radio.sw_mbn_volte=./persist.radio.sw_mbn_volte=0/' system.prop;
		#sed -i 's/persist.radio.VT_ENABLE=./persist.radio.VT_ENABLE=0/' system.prop;
		#sed -i 's/persist.radio.VT_HYBRID_ENABLE=./persist.radio.VT_HYBRID_ENABLE=0/' system.prop;
		#sed -i 's/persist.volte_enabled_by_hw=./persist.volte_enabled_by_hw=0/' system.prop;
	fi;
	if [ -f init/init_*.cpp ]; then
		sed -i 's/property_set("persist.rcs.supported", ".");/property_set("persist.rcs.supported", "0");/' init/init_*.cpp; #Disable RCS
		#Disable IMS
		#sed -i 's/property_set("persist.ims.volte", "true");/property_set("persist.ims.volte", "false");/' init/init_*.cpp;
		#sed -i 's/property_set("persist.ims.vt", "true");/property_set("persist.ims.vt", "false");/' init/init_*.cpp;
		#sed -i 's/property_set("persist.radio.calls.on.ims", "true");/property_set("persist.radio.calls.on.ims", "false");/' init/init_*.cpp;
		#sed -i 's/property_set("persist.radio.jbims", ".");/property_set("persist.radio.jbims", "0");/' init/init_*.cpp;
		#sed -i 's/property_set("persist.radio.VT_ENABLE", ".");/property_set("persist.radio.VT_ENABLE", "0");/' init/init_*.cpp;
		#sed -i 's/property_set("persist.radio.VT_HYBRID_ENABLE", ".");/property_set("persist.radio.VT_HYBRID_ENABLE", "0");/' init/init_*.cpp;
	fi;
	if [ -f overlay/frameworks/base/core/res/res/values/config.xml ]; then
		#sed -i 's|<bool name="config_enableWifiDisplay">true</bool>|<bool name="config_enableWifiDisplay">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		sed -i 's|<bool name="config_uiBlurEnabled">true</bool>|<bool name="config_uiBlurEnabled">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml; #Disable UIBlur
		#Disable IMS
		#sed -i 's|<bool name="config_carrier_volte_available">true</bool>|<bool name="config_carrier_volte_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		#sed -i 's|<bool name="config_carrier_vt_available">true</bool>|<bool name="config_carrier_vt_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		#sed -i 's|<bool name="config_device_volte_available">true</bool>|<bool name="config_device_volte_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		#sed -i 's|<bool name="config_device_vt_available">true</bool>|<bool name="config_device_vt_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		#sed -i 's|<bool name="config_device_wfc_ims_available">true</bool>|<bool name="config_device_wfc_ims_available">false</bool>|'  overlay/frameworks/base/core/res/res/values/config.xml;
	fi;
	if [ -d sepolicy ]; then
		if [ -z "$replaceTime" ]; then
			#Switch to Sony TimeKeep
			echo "allow system_app time_data_file:dir { create_dir_perms search };" >> sepolicy/system_app.te;
			echo "allow system_app time_data_file:file create_file_perms;" >> sepolicy/system_app.te;
		fi;
	fi;
	if [ -z "$replaceTime" ]; then sed -i 's|service time_daemon /system/bin/time_daemon|service timekeep /system/bin/timekeep restore\n    oneshot|' init.*.rc rootdir/init.*.rc rootdir/etc/init.*.rc &> /dev/null || true; fi; #Switch to Sony TimeKeep
	rm -f rootdir/etc/init.qti.ims.sh rootdir/init.qti.ims.sh init.qti.ims.sh; #Remove IMS startup script
	rm -rf IMSEnabler; #Remove IMS compatibility module
	#rm -rf data-ipa-cfg-mgr; #Remove IPA
	rm -rf libshimwvm; #Remove Google Widevine compatibility module
	rm -rf board/qcom-wipower.mk product/qcom-wipower.mk; #Remove WiPower makefiles
	if [ -f setup-makefiles.sh ]; then #FIXME: This breaks some devices using shared device trees (eg. osprey) when removing blobs that are listed in Android.mk of vendor repositories
		awk -i inplace '!/'$blobs'/' *proprietary*.txt; #Remove all blob references from blob manifest
		sh -c "cd $base$devicePath && ./setup-makefiles.sh"; #Update the makefiles
	fi;
	cd $base;
}
export -f deblobDevice;

deblobKernel() {
	kernelPath=$1;
	cd $base$kernelPath;
	rm -rf $kernels;
	cd $base;
}
export -f deblobKernel;

deblobVendors() {
	cd $base;
	find vendor -regextype posix-extended -regex '.*('$blobs')' -type f -delete; #Delete all blobs
}
export -f deblobVendors;

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
#Start of device fixes [LAOS SPECIFIC]
#
cd vendor/lge; git revert 846315c52044dd60a77da84b5180d4d93bb22ceb; cd $base; #Commit 846315c52044dd60a77da84b5180d4d93bb22ceb moves blobs but doesn't update their location in mako device tree
echo "vendor/lib/libcneapiclient.so" >> device/oneplus/bacon/proprietary-files-qc.txt; #Commit b7b6d94529e17ce51566aa6509cebab6436b153d disabled CNE but left this binary in the makefile vendor since NetMgr requires it. Without this line rerunning setup-makefiles.sh breaks cell service, since the resulting build will be missing it.
#
#End of device fixes
#


#
#START OF DEBLOBBING
#
find device -maxdepth 2 -mindepth 2 -type d -exec bash -c 'deblobDevice "$0"' {} \; #Deblob all device directories
#find kernel -maxdepth 2 -mindepth 2 -type d -exec bash -c 'deblobKernel "$0"' {} \; #Deblob all kernel directories
find vendor -name "*vendor*.mk" -type f -exec bash -c 'deblobVendor "$0"' {} \; #Deblob all makefiles
deblobVendors; #Deblob entire vendor directory
rm -rf frameworks/av/drm/mediadrm/plugins/clearkey; #Remove Clearkey
#
#END OF DEBLOBBING
#



#Fixes marlin building, really janky (recursive symlinks) and probably not the best place for it [LAOS SPECIFIC]
cd vendor/google/marlin/proprietary;
ln -s . vendor;
ln -s . lib/lib;
ln -s . lib64/lib64;
ln -s . app/app;
ln -s . bin/bin;
ln -s . etc/etc;
ln -s . framework/framework;
ln -s . priv-app/priv-app;
cd $base;
