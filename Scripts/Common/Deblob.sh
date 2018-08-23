#!/bin/bash
#DivestOS: A privacy oriented Android distribution
#Copyright (c) 2017-2018 Divested Computing, Inc.
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

#Goal: Remove as many proprietary blobs without breaking core functionality
#Outcome: Increased battery/performance/privacy/security, Decreased ROM size
#TODO: Clean init*.rc files, Modularize, Remove more variants

#
#Device Status (Tested under LineageOS 14.1 and 15.1)
#
#Functioning as Expected: bacon, clark, d852, grouper, mako, marlin, thor
#Partially working:
#Not booting:

echo "Deblobbing..."

#
#START OF BLOBS ARRAY
#
	#WARNING: STRAY DELIMITERS WILL RESULT IN FILE DELETIONS
	blobs=""; #Delimited using "|"
	makes="";
	overlay="";
	kernels=""; #Delimited using " "
	sepolicy="";

	#ACDB (Audio Configurations) [Qualcomm] XXX: Breaks audio output
	#blobs=$blobs"acdb";

	#ADSP/Hexagon (Hardware Digital Signal Processor) [Qualcomm]
	#blobs=$blobs"[/]adsp[/]|.*adspd.*|.*adsprpc.*|libfastcvadsp_stub.so|libfastcvopt.so|libadsp.*.so|libscve.*.so";
	#sepolicy=$sepolicy" adspd.te adsprpcd.te";

	#Alipay (Payment Platform) [Alibaba]
	blobs=$blobs"alipay.*";

	#aptX (Bluetooth Audio Compression Codec) [Qualcomm]
	blobs=$blobs"|.*aptX.*";

	#ATFWD [Qualcomm]
	blobs=$blobs"|ATFWD-daemon|atfwd.apk";
	sepolicy=$sepolicy" atfwd.te";

	#AudioFX (Audio Effects) [Qualcomm]
	if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then
		blobs=$blobs"|fmas_eq.dat|libasphere.so|libdownmix.so|libeffectproxy.so|libfmas.so|libldnhncr.so|libmmieffectswrapper.so|libqcbassboost.so|libqcreverb.so|libqcvirt.so|libreverbwrapper.so|libshoebox.so|libspeakerbundle.so|libvisualizer.so|libvolumelistener.so|libLifevibes_lvverx.so|libhwdap.so|libsonypostprocbundle.so|libsonysweffect.so";
		#blobs=$blobs"|libbundlewrapper.so|libqcompostprocbundle.so|libqcomvoiceprocessing.so|libqcomvisualizer.so";
	fi;

	#Camera
	#Attempted, don't waste your time...
	#FUN FACT: The Huawei Honor 5x ships with eight-hundred-and-thirty-five (*835*) proprietary camera blobs.
	#blobs=$blobs"|";

	#Clearkey (DRM) [Google]
	blobs=$blobs"|libdrmclearkeyplugin.so";

	#CMN (DRM?) [?]
	blobs=$blobs"|cmnlib.*";

	#CNE (Automatic Cell/Wi-Fi Switching) [Qualcomm]
	#blobs=$blobs"|libcneapiclient.so|libNimsWrap.so"; #XXX: Breaks radio
	blobs=$blobs"|andsfCne.xml|ATT_profile.*.xml|cnd|cneapiclient.jar|cneapiclient.xml|CNEService.apk|com.quicinc.cne.*.jar|com.quicinc.cne.*.so|com.quicinc.cne.xml|ConnectivityExt.jar|ConnectivityExt.xml|libcneconn.so|libcneqmiutils.so|libcne.so|libvendorconn.so|libwms.so|libwqe.so|profile1.xml|profile2.xml|profile3.xml|profile4.xml|profile5.xml|ROW_profile.*.xml|SwimConfig.xml|VZW_profile.*.xml";
	makes=$makes"libcnefeatureconfig";
	sepolicy=$sepolicy" cnd.te qcneservice.te";

	#Diagnostics [Qualcomm]
	blobs=$blobs"|[/]diag[/]|diag_callback_client|diag_dci_sample|diag_klog|diag_mdlog|diag_mdlog-getlogs|diag_mdlog-wrap|diag[/]mdm|diag_qshrink4_daemon|diag_socket_log|diag_uart_log|drmdiagapp|ibdrmdiag.so|ssr_diag|test_diag";

	#Dirac (Audio Codec + Effects) [Dirac]
	blobs=$blobs"|libDiracAPI_SHARED.so|.*dirac.*";

	#Discretix (DRM/HDCP) [Discretix Technologies]
	blobs=$blobs"|discretix|DxHDCP.cfg|libDxHdcp.so";
	blobs=$blobs"|dxhdcp.*";
	blobs=$blobs"|dxcpr.*";
	makes=$makes"|DxHDCP.cfg";

	#Display Color Tuning [Qualcomm]
	blobs=$blobs"|colorservice.apk|com.qti.snapdragon.sdk.display.jar|com.qti.snapdragon.sdk.display.xml|libdisp-aba.so|libmm-abl-oem.so|libmm-abl.so|libmm-als.so|libmm-color-convertor.so|libmm-disp-apis.so|libmm-qdcm.so|libsd_sdk_display.so|mm-pp-daemon|mm-pp-dpps|PPPreference.apk";

	#DivX (DRM) [DivX]
	blobs=$blobs"|libDivxDrm.so|libSHIMDivxDrm.so";

	#DPM (Data Power Management) [Qualcomm]
	blobs=$blobs"|com.qti.dpmframework.jar|com.qti.dpmframework.xml|dpmapi.jar|dpmapi.xml|dpm.conf|dpmd|dpmserviceapp.apk|libdpmctmgr.so|libdpmfdmgr.so|libdpmframework.so|libdpmnsrm.so|libdpmtcm.so|NsrmConfiguration.xml|tcmclient.jar";
	sepolicy=$sepolicy" dpmd.te";

	#DRM
	blobs=$blobs"|lib-sec-disp.so|libSecureUILib.so|libsecureui.so|libsecureuisvc_jni.so|libsecureui_svcsock.so";
	blobs=$blobs"|liboemcrypto.so|libtzdrmgenprov.so";
	blobs=$blobs"|libpvr.so|librmp.so|libsi.so|libSSEPKCS11.so";
	blobs=$blobs"|libdrmctaplugin.so|libdrmmtkplugin.so|libdrmmtkwhitelist.so|libmockdrmcryptoplugin.so";
	makes=$makes"|android.hardware.drm.*|libdrmclearkeyplugin";
	#makes=$makes"|libdrmframework.*"; #necessary to compile
	#makes=$makes"|mediadrmserver|com.android.mediadrm.signer.*|drmserver"; #Works but causes long boot times
	#sepolicy=$sepolicy" drmserver.te mediadrmserver.te";
	sepolicy=$sepolicy" hal_drm_default.te hal_drm.te hal_drm_widevine.te";

	#External Accessories
	if [ "$DOS_DEBLOBBER_REMOVE_ACCESSORIES" = true ]; then
		blobs=$blobs"|DragonKeyboardFirmwareUpdater.apk"; #dragon
		blobs=$blobs"|ProjectorApp.apk|projectormod.xml|motorola.hardware.mods_camera.*|libcamera_mods_legacy_hal.so|mods_camd|MotCameraMod.apk|ModFmwkProxyService.apk|ModService.apk|libmodmanager.*.so|com.motorola.mod.*.so|libmodhw.so|com.motorola.modservice.xml"; #griffin
		blobs=$blobs"|[/]Score[/]|[/]Klik[/]|vendor.essential.hardware.sidecar.*|vendor-essential-hardware-sidecar.xml"; #mata
	fi;

	#Face Unlock [Google]
	blobs=$blobs"|libfacenet.so|libfilterpack_facedetect.so|libfrsdk.so";

	#GPS [Qualcomm]
	#blobs=$blobs"|flp.conf|flp.default.so|flp.msm8084.so|flp.msm8960.so|gpsd|gps.msm8084.so|gps.msm8960.so|libflp.so|libgps.utils.so|libloc_api_v02.so|libloc_core.so|libloc_ds_api.so|libloc_eng.so|libloc_ext.so";

	#Graphics
	if [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
		blobs=$blobs"|eglsubAndroid.so|eglSubDriverAndroid.so|libbccQTI.so|libC2D2.so|libc2d30_bltlib.so|libc2d30.so|libc2d30.*.so|libCB.so|libEGL.*.so|libGLES.*.so|libgsl.so|libq3dtools_esx.so|libq3dtools.*.so|libQTapGLES.so|libscale.so|libsc.*.so";
		blobs=$blobs"|libglcore.so|libnvblit.so|libnvddk_vic.so|libnvglsi.so|libnvgr.so|libnvptx.so|libnvrmapi.*.so|libnvrm_graphics.so|libnvrm.so|libnvwsi.so"; #NVIDIA
		blobs=$blobs"|gralloc.*.so|hwcomposer.*.so|memtrack.*.so";
		blobs=$blobs"|libadreno_utils.so"; #Adreno
		blobs=$blobs"|libllvm.*.so"; #LLVM
		blobs=$blobs"|libOpenCL.*.so|libclcore_nvidia.bc"; #OpenCL
		blobs=$blobs"|librs.*.so|libRSDriver.*.so|libnvRSCompiler.so|libnvRSDriver.so"; #RenderScript
		blobs=$blobs"|vulkan.*.so"; #Vulkan
	fi;

	#Fingerprint Reader
	if [ "$DOS_DEBLOBBER_REMOVE_FP" = true ]; then
		blobs=$blobs"|android.hardware.biometrics.fingerprint.*|fingerprint.*.so|fpc_early_loader|fpctzappfingerprint.*|libbauthserver.so|libcom_fingerprints_service.so|libegis_fp_normal_sensor_test.so|lib_fpc_tac_shared.so|libfpfactory_jni.so|libfpfactory.so|libsynaFpSensorTestNwd.so";
		makes=$makes"|android.hardware.biometrics.fingerprint.*|android.hardware.fingerprint.*";
	fi;

	#Google Camera
	blobs=$blobs"|com.google.android.camera.*";

	#Google TV
	blobs=$blobs"|LeanbackIme.apk|LeanbackLauncher.apk|AtvRemoteService.apk|GamepadPairingService.apk|GlobalKeyInterceptor.apk|RemoteControlService.apk|TV.apk";

	#HDCP (DRM)
	blobs=$blobs"|libmm-hdcpmgr.so|libstagefright_hdcp.so|libhdcp2.so|srm.bin|insthk";
	blobs=$blobs"|hdcp1.*|tzhdcp.*";

	#HDR
	blobs=$blobs"|libhdr.*.so";
	blobs=$blobs"|DolbyVisionService.apk|dolby_vision.cfg|libdovi.so";

	#[HTC]
	blobs=$blobs"|gptauuid.xml";
	blobs=$blobs"|htc_drmprov.*|gpsample.mbn";

	#I/O Prefetcher [Qualcomm]
	blobs=$blobs"|libqc-opt.so";
	blobs=$blobs"|bin/iop|libqti-iop.*.so|QPerformance.jar|vendor.qti.hardware.iop.*";

	#IMS (VoLTE/Wi-Fi Calling) [Qualcomm]
	blobs=$blobs"|imscmlibrary.jar|imscmservice|imscm.xml|imsdatadaemon|imsqmidaemon|imssettings.apk|lib-imsdpl.so|lib-imscamera.so|libimscamera_jni.so|lib-imsqimf.so|lib-imsSDP.so|lib-imss.so|lib-imsvt.so|lib-imsxml.so"; #IMS
	blobs=$blobs"|ims_rtp_daemon|lib-rtpcommon.so|lib-rtpcore.so|lib-rtpdaemoninterface.so|lib-rtpsl.so|vendor.qti.imsrtpservice.*.so"; #RTP
	blobs=$blobs"|lib-dplmedia.so|librcc.so|libvcel.so|libvoice-svc.so|qti_permissions.xml"; #Misc.
	if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then #IMS (Core) (To support carriers that have phased out 2G)
		blobs=$blobs"|ims.apk|ims.xml|libimsmedia_jni.so";
		blobs=$blobs"|volte_modem[/]";
		sepolicy=$sepolicy" ims.te imscm.te imswmsproxy.te";
	fi;

	#IPA (Internet Packet Accelerator) [Qualcomm]
	#This is actually open source (excluding -diag)
	#blobs=$blobs"|ipacm";
	blobs=$blobs"|ipacm-diag";
	#makes=$makes"|ipacm|IPACM_cfg.xml";
	#kernels=$kernels" drivers/platform/msm/ipa";

	#IS? (DRM) [?]
	blobs=$blobs"|isdbtmm.*";

	#IR
	if [ "$DOS_DEBLOBBER_REMOVE_IR" = true ]; then
		blobs=$blobs"|cir_fw_update|cir.img|CIRModule.apk|consumerir.*.so|htcirlibs.jar|ibcir_driver.so|libcir_driver.so|libhtcirinterface_jni.s";
		makes=$makes"|android.hardware.ir.*|android.hardware.consumerir.*";
	fi;

	#Keystore/TrustZone (HW Crypto) [Qualcomm]
	#blobs=$blobs"|qseecomd|keystore.qcom.so|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libQSEEComAPI.so|librpmb.so|libssd.so";
	#blobs=$blobs"|keymaster.*";
	#blobs=$blobs"|tzapps.*";
	#blobs=$blobs"|vendor.qti.hardware.qteeconnector.*|libQTEEConnector.*.so";

	#Location (gpsOne/gpsOneXTRA/IZat/Lumicast/QUIP) [Qualcomm]
	blobs=$blobs"|cacert_location.pem|com.qti.location.sdk.jar|com.qti.location.sdk.xml|com.qualcomm.location.apk|com.qualcomm.location.xml|com.qualcomm.services.location.apk|gpsone_daemon|izat.conf|izat.xt.srv|izat.xt.srv.jar|izat.xt.srv.xml|libalarmservice_jni.so|libasn1cper.so|libasn1crt.so|libasn1crtx.so|libdataitems.so|libdrplugin_client.so|libDRPlugin.so|libevent_observer.so|libgdtap.so|libgeofence.so|libizat_core.so|liblbs_core.so|liblocationservice_glue.so|liblocationservice.so|libloc_ext.so|libloc_xtra.so|liblowi_client.so|liblowi_wifihal_nl.so|liblowi_wifihal.so|libquipc_os_api.so|libquipc_ulp_adapter.so|libulp2.so|libxtadapter.so|libxt_native.so|libxtwifi_ulp_adaptor.so|libxtwifi_zpp_adaptor.so|location-mq|loc_launcher|lowi.conf|lowi-server|slim_ap_daemon|slim_daemon|xtra_root_cert.pem|xtra_t_app.apk|xtwifi.conf|xtwifi-client|xtwifi-inet-agent";
	overlay=$overlay"config_comboNetworkLocationProvider|config_enableFusedLocationOverlay|config_enableNetworkLocationOverlay|config_fusedLocationProviderPackageName|config_enableNetworkLocationOverlay|config_networkLocationProviderPackageName|com.qualcomm.location";

	#Misc
	blobs=$blobs"|libjni_latinime.so|libuiblur.so|libwifiscanner.so";

	#[Motorola]
	blobs=$blobs"|AppDirectedSMSProxy.apk|BuaContactAdapter.apk|batt_health|com.motorola.DirectedSMSProxy.xml|com.motorola.motosignature.jar|com.motorola.motosignature.xml|com.motorola.camera.xml|com.motorola.gallery.xml|com.motorola.msimsettings.xml|com.motorola.triggerenroll.xml|MotoDisplayFWProxy.apk|MotoSignatureApp.apk|TriggerEnroll.apk|TriggerTrainingService.apk";
	makes=$makes"|com.motorola.cameraone.xml";

	#Performance [Qualcomm]
	#blobs=$blobs"|msm_irqbalance";
	#Devices utilizing perfd won't hotplug cores without it
	#Attempted to replace this with showp1984's msm_mpdecision, but the newer kernels simply don't have the mach_msm dependencies that are needed
	#blobs=$blobs"|mpdecision|libqti-perfd.*.so|perfd|perf-profile.*.conf|vendor.qti.hardware.perf.*";

	#Peripheral Manager
	#blobs=$blobs"|libperipheral_client.so|libspcom.so|pm-proxy|pm-service|spdaemon";

	#Gemini PDA [Planet]
	blobs=$blobs"|ApplicationBar.apk|Gemini_Keyboard.apk|GeminiInputDevices.apk|notes.apk";

	#Playready (DRM) [Microsoft]
	blobs=$blobs"|libtzplayready.so"
	blobs=$blobs"|playread.*";

	#Project Fi [Google]
	blobs=$blobs"|Tycho.apk";

	#Quickboot [Qualcomm]
	blobs=$blobs"|QuickBoot.apk";

	#QTI (Tethering Extensions) [Qualcomm]
	blobs=$blobs"|libQtiTether.so|QtiTetherService.apk";

	#RCS (Proprietary messaging protocol)
	blobs=$blobs"|rcsimssettings.jar|rcsimssettings.xml|rcsservice.jar|rcsservice.xml|lib-imsrcscmclient.so|lib-ims-rcscmjni.so|lib-imsrcscmservice.so|lib-imsrcscm.so|lib-imsrcs.so|lib-rcsimssjni.so|lib-rcsjni.so|RCSBootstraputil.apk|RcsImsBootstraputil.apk|uceShimService.apk"; #RCS
	makes=$makes"|rcs_service.*";

	#SecProtect [Qualcomm]
	blobs=$blobs"|SecProtect.apk";

	#SecureUI Frontends
	blobs=$blobs"|libHealthAuthClient.so|libHealthAuthJNI.so|libSampleAuthJNI.so|libSampleAuthJNIv1.so|libSampleExtAuthJNI.so|libSecureExtAuthJNI.so|libSecureSampleAuthClient.so|libsdedrm.so";

	#[Sprint]
	blobs=$blobs"|com.android.omadm.service.xml|ConnMO.apk|CQATest.apk|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|GCS.apk|HiddenMenu.apk|libdmengine.so|libdmjavaplugin.so|LifetimeData.apk|SprintDM.apk|SprintHM.apk|whitelist_com.android.omadm.service.xml|LifeTimerService.apk";

	#Thermal Throttling [Qualcomm]
	#blobs=$blobs"|libthermalclient.so|libthermalioctl.so|thermal-engine";

	#Time Service [Qualcomm]
	#Requires that android_hardware_sony_timekeep be included in repo manifest
	if [ "$DOS_DEBLOBBER_REPLACE_TIME" = true ]; then
		#blobs=$blobs"|libtime_genoff.so"; #XXX: Breaks radio
		blobs=$blobs"|libTimeService.so|time_daemon|TimeService.apk";
		sepolicy=$sepolicy" qtimeservice.te";
	fi;

	#Venus (Hardware Video Decoding) [Qualcomm]
	#blobs=$blobs"|venus.b00|venus.b01|venus.b02|venus.b03|venus.b04|venus.mbn|venus.mdt";

	#[Verizon]
	blobs=$blobs"|appdirectedsmspermission.apk|com.qualcomm.location.vzw_library.jar|com.qualcomm.location.vzw_library.xml|com.verizon.apn.xml|com.verizon.embms.xml|com.verizon.hardware.telephony.ehrpd.jar|com.verizon.hardware.telephony.ehrpd.xml|com.verizon.hardware.telephony.lte.jar|com.verizon.hardware.telephony.lte.xml|com.verizon.ims.jar|com.verizon.ims.xml|com.verizon.provider.xml|com.vzw.vzwapnlib.xml|qti-vzw-ims-internal.jar|qti-vzw-ims-internal.xml|VerizonSSOEngine.apk|VerizonUnifiedSettings.jar|VZWAPNLib.apk|vzwapnpermission.apk|VZWAPNService.apk|VZWAVS.apk|VzwLcSilent.apk|vzw_msdc_api.apk|VzwOmaTrigger.apk|vzw_sso_permissions.xml|VerizonAuthDialog.apk";

	#Voice Recognition
	blobs=$blobs"|aonvr1.bin|aonvr2.bin|audiomonitor|es305_fw.bin|HotwordEnrollment.apk|HotwordEnrollment.*.apk|libadpcmdec.so|liblistenhardware.so|liblistenjni.so|liblisten.so|liblistensoundmodel.so|libqvop-service.so|librecoglib.so|libsmwrapper.so|libsupermodel.so|libtrainingcheck.so|qvop-daemon|sound_trigger.primary.*.so|libgcs.*.so|vendor.qti.voiceprint.*";
	makes=$makes"|android.hardware.soundtrigger.*";

	#Wfd (Wireless Display? Wi-Fi Direct?) [Qualcomm]
	blobs=$blobs"|libmmparser_lite.so|libmmrtpdecoder.so|libmmrtpencoder.so|libmmwfdinterface.so|libmmwfdsinkinterface.so|libmmwfdsrcinterface.so|libwfdavenhancements.so|libwfdcommonutils.so|libwfdhdcpcp.so|libwfdmmsink.so|libwfdmmsrc.so|libwfdmmutils.so|libwfdnative.so|libwfdrtsp.so|libwfdservice.so|libwfdsm.so|libwfduibcinterface.so|libwfduibcsinkinterface.so|libwfduibcsink.so|libwfduibcsrcinterface.so|libwfduibcsrc.so|WfdCommon.jar|wfdconfigsink.xml|wfdconfig.xml|wfdservice|WfdService.apk";

	#Widevine (DRM) [Google]
	blobs=$blobs"|com.google.widevine.software.drm.jar|com.google.widevine.software.drm.xml|libdrmclearkeyplugin.so|libdrmwvmplugin.so|libmarlincdmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvhidl.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|libdrmmtkutil.so";
	blobs=$blobs"|tzwidevine.*|tzwvcpybuf.*|widevine.*";
	makes=$makes"|libshim_wvm";

	#WiPower (Wireless Charging) [Qualcomm]
	blobs=$blobs"|a4wpservice.apk|com.quicinc.wbc.jar|com.quicinc.wbcserviceapp.apk|com.quicinc.wbcservice.jar|com.quicinc.wbcservice.xml|com.quicinc.wbc.xml|libwbc_jni.so|wbc_hal.default.so";
	makes=$makes"|android.wipower|android.wipower.xml|com.quicinc.wbcserviceapps|libwipower_jni|wipowerservice";

	export blobs;
	export makes;
	export overlay;
	export kernels;
	export sepolicy;
#
#END OF BLOBS ARRAY
#

#
#START OF FUNCTIONS
#
deblobDevice() {
	devicePath="$1";
	cd "$DOS_BUILD_BASE$devicePath";
	if [ "$DOS_DEBLOBBER_REPLACE_TIME" = false ]; then replaceTime="false"; fi; #Disable Time replacement
	if ! grep -qi "qcom" BoardConfig*.mk; then replaceTime="false"; fi; #Disable Time Replacement
	if [ -f Android.mk ]; then
		#Some devices store these in a dedicated firmware partition, others in /system/vendor/firmware, either way the following are just symlinks
		#sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(CMN_SYMLINKS)//' Android.mk; #Remove CMN firmware
		sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(DXHDCP2_SYMLINKS)//' Android.mk; #Remove Discretix firmware
		if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then sed -i '/ALL_DEFAULT_INSTALLED_MODULES/s/$(IMS_SYMLINKS)//' Android.mk; fi; #Remove IMS firmware
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
		sed -i 's/TARGET_HAS_HDR_DISPLAY := true/TARGET_HAS_HDR_DISPLAY := false/' BoardConfig.mk; #Disable HDR
		if [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
			#sed -i 's/USE_OPENGL_RENDERER := true/USE_OPENGL_RENDERER := false/' BoardConfig.mk;
			#if ! grep -q "USE_OPENGL_RENDERER := false" BoardConfig.mk; then echo "USE_OPENGL_RENDERER := false" >> BoardConfig.mk; fi;
			awk -i inplace '!/RS_DRIVER/' BoardConfig.mk;
			if ! grep -q "USE_OPENGL_RENDERER := true" BoardConfig.mk; then echo "USE_OPENGL_RENDERER := true" >> BoardConfig.mk; fi;
		fi;
	fi;
	if [ -f device.mk ]; then
		awk -i inplace '!/'"$makes"'/' device.mk; #Remove references from device makefile
		if [ -z "$replaceTime" ]; then
			echo "PRODUCT_PACKAGES += timekeep TimeKeep" >> device.mk; #Switch to Sony TimeKeep
		fi;
		if [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
			echo "PRODUCT_PACKAGES += libyuv libEGL_swiftshader libGLESv1_CM_swiftshader libGLESv2_swiftshader" >> device.mk; #Build SwiftShader
		fi;
	fi;
	if [ -f "${PWD##*/}".mk ] && [ "${PWD##*/}".mk != "sepolicy" ]; then
		awk -i inplace '!/'"$makes"'/' "${PWD##*/}".mk; #Remove references from device makefile
		if [ -z "$replaceTime" ]; then
			echo "PRODUCT_PACKAGES += timekeep TimeKeep" >> "${PWD##*/}".mk; #Switch to Sony TimeKeep
		fi;
		if [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
			echo "PRODUCT_PACKAGES += libyuv libEGL_swiftshader libGLESv1_CM_swiftshader libGLESv2_swiftshader" >> "${PWD##*/}".mk; #Build SwiftShader
		fi;
	fi;
	if [ -f system.prop ]; then
		awk -i inplace '!/persist.loc.nlp_name/' system.prop; #Disable QC Location Provider
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
		if [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
			echo "persist.sys.ui.hw=disable" >> system.prop;
			#echo "ro.graphics.gles20.disable_on_bootanim=1" >> system.prop;
			echo "debug.sf.nobootanimation=1" >> system.prop;
			sed -i 's/ro.opengles.version=.*/ro.opengles.version=131072/' system.prop;
		fi;
		#Disable IMS
		if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
		sed -i 's/persist.data.iwlan.enable=true/persist.data.iwlan.enable=false/' system.prop;
		sed -i 's/persist.ims.volte=true/persist.ims.volte=false/' system.prop;
		sed -i 's/persist.ims.vt=true/persist.ims.vt=false/' system.prop;
		sed -i 's/persist.radio.calls.on.ims=true/persist.radio.calls.on.ims=false/' system.prop;
		sed -i 's/persist.radio.hw_mbn_update=./persist.radio.hw_mbn_update=0/' system.prop;
		sed -i 's/persist.radio.jbims=./persist.radio.jbims=0/' system.prop;
		sed -i 's/persist.radio.sw_mbn_update=./persist.radio.sw_mbn_update=0/' system.prop;
		sed -i 's/persist.radio.sw_mbn_volte=./persist.radio.sw_mbn_volte=0/' system.prop;
		sed -i 's/persist.radio.VT_ENABLE=./persist.radio.VT_ENABLE=0/' system.prop;
		sed -i 's/persist.radio.VT_HYBRID_ENABLE=./persist.radio.VT_HYBRID_ENABLE=0/' system.prop;
		sed -i 's/persist.volte_enabled_by_hw=./persist.volte_enabled_by_hw=0/' system.prop;
		fi;
	fi;
	if [ -f configs/qmi_config.xml ]; then
		sed -i 's|name="dpm_enabled" type="int"> 1 <|name="dpm_enabled" type="int"> 0 <|' configs/qmi_config.xml; #Disable DPM
	fi;
	if [ -f init/init_*.cpp ]; then
		sed -i 's/property_set("persist.rcs.supported", ".");/property_set("persist.rcs.supported", "0");/' init/init_*.cpp; #Disable RCS
		#Disable IMS
		if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
		sed -i 's/property_set("persist.ims.volte", "true");/property_set("persist.ims.volte", "false");/' init/init_*.cpp;
		sed -i 's/property_set("persist.ims.vt", "true");/property_set("persist.ims.vt", "false");/' init/init_*.cpp;
		sed -i 's/property_set("persist.radio.calls.on.ims", "true");/property_set("persist.radio.calls.on.ims", "false");/' init/init_*.cpp;
		sed -i 's/property_set("persist.radio.jbims", ".");/property_set("persist.radio.jbims", "0");/' init/init_*.cpp;
		sed -i 's/property_set("persist.radio.VT_ENABLE", ".");/property_set("persist.radio.VT_ENABLE", "0");/' init/init_*.cpp;
		sed -i 's/property_set("persist.radio.VT_HYBRID_ENABLE", ".");/property_set("persist.radio.VT_HYBRID_ENABLE", "0");/' init/init_*.cpp;
		fi;
	fi;
	if [ -f overlay/frameworks/base/core/res/res/values/config.xml ]; then
		awk -i inplace '!/'$overlay'/' overlay/frameworks/base/core/res/res/values/config.xml;
		#sed -i 's|<bool name="config_enableWifiDisplay">true</bool>|<bool name="config_enableWifiDisplay">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		sed -i 's|<bool name="config_uiBlurEnabled">true</bool>|<bool name="config_uiBlurEnabled">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml; #Disable UIBlur
		#Disable IMS
		if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then
		sed -i 's|<bool name="config_carrier_volte_available">true</bool>|<bool name="config_carrier_volte_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		sed -i 's|<bool name="config_carrier_vt_available">true</bool>|<bool name="config_carrier_vt_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		sed -i 's|<bool name="config_device_volte_available">true</bool>|<bool name="config_device_volte_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		sed -i 's|<bool name="config_device_vt_available">true</bool>|<bool name="config_device_vt_available">false</bool>|' overlay/frameworks/base/core/res/res/values/config.xml;
		sed -i 's|<bool name="config_device_wfc_ims_available">true</bool>|<bool name="config_device_wfc_ims_available">false</bool>|'  overlay/frameworks/base/core/res/res/values/config.xml;
		fi;
	fi;
	if [ -d sepolicy ]; then
		if [ -z "$replaceTime" ]; then
			numfiles=(*); numfiles=${#numfiles[@]};
			if [ "$numfiles"  -gt "5" ]; then #only if device doesn't use a common sepolicy dir
			#Switch to Sony TimeKeep
			echo "allow system_app time_data_file:dir { create_dir_perms search };" >> sepolicy/system_app.te;
			echo "allow system_app time_data_file:file create_file_perms;" >> sepolicy/system_app.te;
			fi;
		fi;
	fi;
	if [ -z "$replaceTime" ]; then #Switch to Sony TimeKeep
		sed -i 's|service time_daemon /system/bin/time_daemon|service time_daemon /system/bin/timekeep restore\n    oneshot|' init.*.rc rootdir/init.*.rc rootdir/etc/init.*.rc &> /dev/null || true;
		sed -i 's|mkdir /data/time/ 0700 system system|mkdir /data/time/ 0700 system system\n    chmod 0770 /data/time/ats_2|' init.*.rc rootdir/init.*.rc rootdir/etc/init.*.rc &> /dev/null || true;
	fi;
	rm -f board/qcom-cne.mk product/qcom-cne.mk; #Remove CNE
	rm -f rootdir/etc/init.qti.ims.sh rootdir/init.qti.ims.sh init.qti.ims.sh; #Remove IMS startup script
	rm -rf IMSEnabler; #Remove IMS compatibility module
	#rm -rf data-ipa-cfg-mgr; #Remove IPA
	rm -rf libshimwvm libshims/wvm_shim.cpp; #Remove Google Widevine compatibility module
	rm -rf board/qcom-wipower.mk product/qcom-wipower.mk; #Remove WiPower makefiles
	if [ -f setup-makefiles.sh ]; then
		awk -i inplace '!/'$blobs'/' ./*proprietary*.txt; #Remove all blob references from blob manifest
		bash -c "cd $DOS_BUILD_BASE$devicePath && ./setup-makefiles.sh"; #Update the makefiles
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f deblobDevice;

deblobKernel() {
	kernelPath="$1";
	cd "$DOS_BUILD_BASE$kernelPath";
	rm -rf $kernels;
	cd "$DOS_BUILD_BASE";
}
export -f deblobKernel;

deblobSepolicy() {
	sepolicyPath="$1";
	cd "$DOS_BUILD_BASE$sepolicyPath";
	if [ -d sepolicy ]; then
		cd sepolicy;
		rm -f $sepolicy;
	fi;
	cd "$DOS_BUILD_BASE";
}
export -f deblobSepolicy;

deblobVendors() {
	cd "$DOS_BUILD_BASE";
	find vendor -regextype posix-extended -regex '.*('$blobs')' -type f -delete; #Delete all blobs
}
export -f deblobVendors;

deblobVendor() {
	makefile="$1";
	cd "$DOS_BUILD_BASE";
	awk -i inplace '!/'$blobs'/' "$makefile"; #Remove all blob references from makefile
}
export -f deblobVendor;
#
#END OF FUNCTIONS
#


#
#START OF DEBLOBBING
#
find build -name "*.mk" -type f -exec bash -c 'awk -i inplace "!/$makes/" "$0"' {} \;; #Deblob all makefiles
find device -maxdepth 2 -mindepth 2 -type d -exec bash -c 'deblobDevice "$0"' {} \;; #Deblob all device directories
#find device -maxdepth 3 -mindepth 2 -type d -exec bash -c 'deblobSepolicy "$0"' {} \;; #Deblob all device sepolicy directories XXX: Breaks builds when other sepolicy files reference deleted ones
#find kernel -maxdepth 2 -mindepth 2 -type d -exec bash -c 'deblobKernel "$0"' {} \;; #Deblob all kernel directories
find vendor -name "*vendor*.mk" -type f -exec bash -c 'deblobVendor "$0"' {} \;; #Deblob all makefiles
deblobVendors; #Deblob entire vendor directory
rm -rf frameworks/av/drm/mediadrm/plugins/clearkey; #Remove ClearKey
rm -rf vendor/samsung/nodevice;
#
#END OF DEBLOBBING
#

cd "$DOS_BUILD_BASE";

echo "Deblobbing complete!"
