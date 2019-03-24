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

echo "Deblobbing..."

#
#START OF BLOBS ARRAY
#
	#WARNING: STRAY DELIMITERS WILL RESULT IN FILE DELETIONS
	blobs=""; #Delimited using "|"
	makes="";
	overlay="";
	ipcSec="";
	kernels=""; #Delimited using " "
	sepolicy="";

	#ACDB (Audio Calibration DataBase) [Qualcomm] XXX: Breaks audio output
	#blobs=$blobs".*.acdb|florida.*.bin"; #databases
	#blobs=$blobs"|libacdb.*.so|libaditrtac.so|libaudcal.so"; #loaders

	#ADSP/Hexagon (Hardware Digital Signal Processor) [Qualcomm]
	#blobs=$blobs"[/]adsp[/]|.*adspd.*|.*adsprpc.*";
	#blobs=$blobs"|libfastcvadsp_stub.so|libfastcvopt.so|libadsp.*.so|libscve.*.so";
	#sepolicy=$sepolicy" adspd.te adsprpcd.te";

	#Alipay (Payment Platform) [Alibaba]
	blobs=$blobs"ifaadaemon|ifaadaemonProxy";
	blobs=$blobs"|alipay.*";

	#AIV (DRM) [Amazon]
	blobs=$blobs"|libaivdrmclient.so|libAivPlay.so";

	#aptX (Bluetooth Audio Compression Codec) [Qualcomm]
	blobs=$blobs"|.*aptX.*|libbt-aptx.*.so";
	blobs=$blobs"|aptxui.apk";

	#AT Command Handling/Forwarding (See: https://atcommands.org)
	blobs=$blobs"|bin[/]atd|ATFWD-daemon|drexe|log_serial_arm|at_distributor|connfwexe";
	blobs=$blobs"|vendor.qti.atcmdfwd.*";
	blobs=$blobs"|atfwd.apk|OBDM_Permissions.apk";
	sepolicy=$sepolicy" atfwd.te";

	#AudioFX (Audio Effects)
	if [ "$DOS_DEBLOBBER_REMOVE_AUDIOFX" = true ]; then
		blobs=$blobs"|fmas_eq.dat";
		blobs=$blobs"|libasphere.so|libdownmix.so|libeffectproxy.so|libfmas.so|libldnhncr.so|libmmieffectswrapper.so|libreverbwrapper.so|libshoebox.so|libspeakerbundle.so|libvisualizer.so|libvolumelistener.so|libLifevibes_lvverx.so|libhwdap.so";
		blobs=$blobs"|libqcbassboost.so|libqcreverb.so|libqcvirt.so"; #Qualcomm
		#blobs=$blobs"|libbundlewrapper.so|libqcompostprocbundle.so|libqcomvoiceprocessing.so|libqcomvisualizer.so";
		blobs=$blobs"|libhwdap.*.so|libswdap.*.so|lib_dlb_msd.so"; #Dolby
		blobs=$blobs"|libsonypostprocbundle.so|libsonysweffect.so"; #Sony
	fi;

	#Clearkey (DRM) [Google]
	blobs=$blobs"|libdrmclearkeyplugin.so";

	#CMN (DRM?) [?]
	blobs=$blobs"|cmnlib.*";

	#CNE (Automatic Cell/Wi-Fi Switching) [Qualcomm]
	#blobs=$blobs"|libcneapiclient.so|libNimsWrap.so"; #XXX: Breaks radio
	blobs=$blobs"|andsfCne.xml|ATT_profile.*.xml|cneapiclient.xml|com.quicinc.cne.xml|ConnectivityExt.xml|profile1.xml|profile2.xml|profile3.xml|profile4.xml|profile5.xml|ROW_profile.*.xml|SwimConfig.xml|VZW_profile.*.xml";
	blobs=$blobs"|cnd";
	blobs=$blobs"|cneapiclient.jar|com.quicinc.cne.*.jar|ConnectivityExt.jar";
	blobs=$blobs"|CNEService.apk";
	blobs=$blobs"|com.quicinc.cne.*.so|libcneconn.so|libcneqmiutils.so|libcne.so|libvendorconn.so|libwms.so|libwqe.so|libcneoplookup.so";
	blobs=$blobs"|vendor.qti.data.factory.*|vendor.qti.hardware.data.dynamicdds.*|vendor.qti.hardware.data.latency.*|vendor.qti.hardware.data.qmi.*|vendor.qti.latency.*";
	makes=$makes"libcnefeatureconfig";
	sepolicy=$sepolicy" cnd.te qcneservice.te";

	#Diagnostics
	blobs=$blobs"|[/]diag[/]|diag_callback_client|diag_dci_sample|diag_klog|diag_mdlog|diag_mdlog-getlogs|diag_mdlog-wrap|diag[/]mdm|diag_qshrink4_daemon|diag_socket_log|diag_uart_log|drmdiagapp|ibdrmdiag.so|ssr_diag|test_diag|cnss_diag";
	#blobs=$blobs"|libdiag.so|libsdm-diag.so|libDiagService.so"; #XXX: Breaks qseecomd AND brightness control (?)
	ipcSec="4097:4294967295:2002:2950:3009:2901|4097:4294967295:3009";

	#Dirac (Audio Codec + Effects) [Dirac]
	blobs=$blobs"|libDiracAPI_SHARED.so|.*dirac.*";

	#Discretix (DRM/HDCP) [Discretix Technologies]
	blobs=$blobs"|DxDrmServerIpc|discretix";
	blobs=$blobs"|libDxHdcp.so|libDxModularPluginNv.so|libDxDrmServer.so";
	blobs=$blobs"|DxHDCP.cfg|DxDrmConfig.txt";
	blobs=$blobs"|dxhdcp.*|dxcpr.*";
	makes=$makes"|DxHDCP.cfg";

	#Display Color Tuning [Qualcomm]
	blobs=$blobs"|com.qti.snapdragon.sdk.display.jar";
	blobs=$blobs"|com.qti.snapdragon.sdk.display.xml";
	blobs=$blobs"|mm-pp-daemon|mm-pp-dpps";
	blobs=$blobs"|colorservice.apk|PPPreference.apk|CABLService.apk";
	blobs=$blobs"|libdisp-aba.so|libmm-abl-oem.so|libmm-abl.so|libmm-als.so|libmm-color-convertor.so|libmm-disp-apis.so|libmm-qdcm.so|libsd_sdk_display.so";
	blobs=$blobs"|vendor.display.color.*|vendor.display.postproc.*";

	#DivX (DRM) [DivX]
	blobs=$blobs"|libDivxDrm.so|libSHIMDivxDrm.so";
	blobs=$blobs"|mfc_fw.bin";

	#DPM (Data Power Management) [Qualcomm]
	blobs=$blobs"|com.qti.dpmframework.jar|dpmapi.jar|tcmclient.jar";
	blobs=$blobs"|com.qti.dpmframework.xml|dpmapi.xml|dpm.conf|NsrmConfiguration.xml";
	blobs=$blobs"|dpmd|dpmQmiMgr";
	blobs=$blobs"|dpmserviceapp.apk";
	blobs=$blobs"|libdpmctmgr.so|libdpmfdmgr.so|libdpmframework.so|libdpmnsrm.so|libdpmtcm.so|libdpmqmihal.so";
	blobs=$blobs"|com.qualcomm.qti.dpm.*";
	sepolicy=$sepolicy" dpmd.te";
	ipcSec=$ipcSec"|47:4294967295:1001:3004|48:4294967295:1000:3004";

	#DRM
	blobs=$blobs"|lib-sec-disp.so|libSecureUILib.so|libsecureui.so|libsecureuisvc_jni.so|libsecureui_svcsock.so"; #Qualcomm
	blobs=$blobs"|liboemcrypto.so|libtzdrmgenprov.so";
	blobs=$blobs"|libpvr.so|librmp.so|libsi.so|libSSEPKCS11.so";
	blobs=$blobs"|libdrmctaplugin.so|libdrmmtkplugin.so|libdrmmtkwhitelist.so|libmockdrmcryptoplugin.so";
	blobs=$blobs"|libOMXVideoDecoder.*Secure.so"; #Decoding
	blobs=$blobs"|htc_drmprov.*|gpsample.mbn|gptauuid.xml"; #HTC
	blobs=$blobs"|if.bin"; #Intel PAVP backend
	blobs=$blobs"|liblgdrm.so"; #LG
	#blobs=$blobs"|libtpa_core.so|libdataencrypt_tpa.so|libpkip.so"; #OMAP SMC
	blobs=$blobs"|smc_pa.ift|drmserver.samsung"; #Samsung
	blobs=$blobs"|provision_device";
	#blobs=$blobs"|libasfparser.so|libsavsff.so"; #Parsers
	makes=$makes"|android.hardware.drm.*|libdrmclearkeyplugin";
	#makes=$makes"|libdrmframework.*"; #necessary to compile
	#makes=$makes"|mediadrmserver|com.android.mediadrm.signer.*|drmserver"; #Works but causes long boot times
	#sepolicy=$sepolicy" drmserver.te mediadrmserver.te";
	sepolicy=$sepolicy" hal_drm_default.te hal_drm.te hal_drm_widevine.te";

	#eMBMS [Qualcomm]
	blobs=$blobs"|embms.apk";
	blobs=$blobs"|embms.xml";
	blobs=$blobs"|embmslibrary.jar";

	#External Accessories
	if [ "$DOS_DEBLOBBER_REMOVE_ACCESSORIES" = true ]; then
		#dragon
		blobs=$blobs"|DragonKeyboardFirmwareUpdater.apk";
		#griffin
		blobs=$blobs"|ProjectorApp.apk|MotCameraMod.apk|ModFmwkProxyService.apk|ModService.apk";
		blobs=$blobs"|libcamera_mods_legacy_hal.so|libmodmanager.*.so|com.motorola.mod.*.so|libmodhw.so";
		blobs=$blobs"|mods_camd";
		blobs=$blobs"|projectormod.xml|com.motorola.modservice.xml";
		blobs=$blobs"|motorola.hardware.mods_camera.*";
		#mata
		blobs=$blobs"|[/]Score[/]|[/]Klik[/]";
		blobs=$blobs"|vendor.essential.hardware.sidecar.*";
		blobs=$blobs"|vendor-essential-hardware-sidecar.*.xml";
		#albus
		blobs=$blobs"|DTVPlayer.apk|DTVService.apk";
	fi;

	#Face Unlock [Google]
	blobs=$blobs"|libfacenet.so|libfilterpack_facedetect.so|libfrsdk.so";

	#GPS [Qualcomm]
	#blobs=$blobs"|gpsd";
	#blobs=$blobs"|libflp.so|libgps.utils.so|libloc_api_v02.so|libloc_core.so|libloc_ds_api.so|libloc_eng.so|libloc_ext.so|libizat_core.so";
	#blobs=$blobs"|flp.default.so|flp.msm.*.so|gps.default.so|gps.msm.*.so";
	#blobs=$blobs"|flp.conf";

	#Graphics
	if [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
		blobs=$blobs"|eglsubAndroid.so|eglSubDriverAndroid.so|libbccQTI.so|libC2D2.so|libc2d30_bltlib.so|libc2d30.so|libc2d30.*.so|libCB.so|libEGL.*.so|libGLES.*.so|libgsl.so|libq3dtools_esx.so|libq3dtools.*.so|libQTapGLES.so|libscale.so|libsc.*.so";
		blobs=$blobs"|libglcore.so|libnvblit.so|libnvddk_vic.so|libnvglsi.so|libnvgr.so|libnvptx.so|libnvrmapi.*.so|libnvrm_graphics.so|libnvrm.so|libnvwsi.so"; #NVIDIA
		blobs=$blobs"|gralloc.*.so|hwcomposer.*.so|memtrack.*.so";
		blobs=$blobs"|libadreno_utils.so"; #Adreno
		blobs=$blobs"|libllvm.*.so"; #LLVM
		blobs=$blobs"|libOpenCL.*.so|libclcore_nvidia.bc"; #OpenCL
		blobs=$blobs"|vulkan.*.so"; #Vulkan
		makes=$makes"|android.hardware.vulkan.*|libvulkan";
	fi;
	if [ "$DOS_DEBLOBBER_REMOVE_RENDERSCRIPT" = true ] || [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
		blobs=$blobs"|android.hardware.renderscript.*";
		blobs=$blobs"|librs.*.so|libRSDriver.*.so|libnvRSCompiler.so|libnvRSDriver.so"; #Adreno
		blobs=$blobs"|libPVRRS.*.so|libufwriter.so"; #Intel
		makes=$makes"|android.hardware.renderscript.*";
	fi;

	#Fingerprint Reader
	if [ "$DOS_DEBLOBBER_REMOVE_FP" = true ]; then
		blobs=$blobs"|fingerprint.*.so|libbauthserver.so|libcom_fingerprints_service.so|libegis_fp_normal_sensor_test.so|lib_fpc_tac_shared.so|libfpfactory.*.so|libsynaFpSensorTestNwd.so";
		blobs=$blobs"|fpc_early_loader";
		blobs=$blobs"|fpctzappfingerprint.*";
		blobs=$blobs"|android.hardware.biometrics.fingerprint.*";
		makes=$makes"|android.hardware.biometrics.fingerprint.*|android.hardware.fingerprint.*";
	fi;

	#FM Radio [Google]
	blobs=$blobs"|FMRadioGoogle.apk|FmRadioTrampoline2.apk";

	#Google Camera
	blobs=$blobs"|com.google.android.camera.*";

	#Google TV
	blobs=$blobs"|LeanbackIme.apk|LeanbackLauncher.apk|AtvRemoteService.apk|GamepadPairingService.apk|GlobalKeyInterceptor.apk|RemoteControlService.apk|TV.apk|CanvasPackageInstaller.apk|Overscan.apk";

	#Gemini PDA [Planet]
	blobs=$blobs"|ApplicationBar.apk|Gemini_Keyboard.apk|GeminiInputDevices.apk|notes.apk";

	#[Huawei]
	blobs=$blobs"|HWSarControlService.apk";

	#HDCP (DRM)
	blobs=$blobs"|libmm-hdcpmgr.so|libstagefright_hdcp.so|libhdcp2.so";
	blobs=$blobs"|srm.bin|insthk";
	blobs=$blobs"|hdcp1.*|tzhdcp.*";

	#HDR
	blobs=$blobs"|libhdr.*.so|libdovi.so";
	blobs=$blobs"|DolbyVisionService.apk";
	blobs=$blobs"|dolby_vision.cfg";

	#I/O Prefetcher [Qualcomm]
	blobs=$blobs"|libqc-opt.so|libqti-iop.*.so";
	blobs=$blobs"|bin[/]iop";
	blobs=$blobs"|QPerformance.jar";
	blobs=$blobs"|vendor.qti.hardware.iop.*";

	#IMS (VoLTE/Wi-Fi Calling) [Qualcomm]
	blobs=$blobs"|lib-imsdpl.so|lib-imscamera.so|libimscamera_jni.so|lib-imsqimf.so|lib-imsSDP.so|lib-imss.so|lib-imsvt.so|lib-imsxml.so|lib-imsvideocodec.so|lib-imsvtextutils.so|lib-imsvtutils.so";
	blobs=$blobs"|imscmservice|imsdatadaemon|imsqmidaemon";
	blobs=$blobs"|imscm.xml";
	blobs=$blobs"|imssettings.apk";
	blobs=$blobs"|imscmlibrary.jar";
	#RTP
	blobs=$blobs"|ims_rtp_daemon|lib-rtpcommon.so|lib-rtpcore.so|lib-rtpdaemoninterface.so|lib-rtpsl.so";
	blobs=$blobs"|vendor.qti.imsrtpservice.*";
	#Misc.
	blobs=$blobs"|lib-dplmedia.so|librcc.so|libvcel.so|libvoice-svc.so";
	blobs=$blobs"|qti_permissions.xml";
	if [ "$DOS_DEBLOBBER_REMOVE_IMS" = true ]; then #IMS (Core) (To support carriers that have phased out 2G)
		blobs=$blobs"|ims.apk";
		blobs=$blobs"|ims.xml";
		blobs=$blobs"|libimsmedia_jni.so";
		blobs=$blobs"|volte_modem[/]";
		sepolicy=$sepolicy" ims.te imscm.te imswmsproxy.te";
		ipcSec=$ipcSec"|32:4294967295:1001";
	fi;

	#IPA (Internet Packet Accelerator) [Qualcomm]
	#This is actually open source (excluding -diag)
	blobs=$blobs"|ipacm-diag";
	if [ "$DOS_DEBLOBBER_REMOVE_IPA" = true ]; then
		blobs=$blobs"|ipacm";
		makes=$makes"|ipacm|IPACM_cfg.xml";
		kernels=$kernels" drivers/platform/msm/ipa";
	fi;

	#IS? (DRM) [?]
	blobs=$blobs"|isdbtmm.*";

	#IR
	if [ "$DOS_DEBLOBBER_REMOVE_IR" = true ]; then
		blobs=$blobs"|cir_fw_update";
		blobs=$blobs"|consumerir.*.so|ibcir_driver.so|libcir_driver.so|libhtcirinterface_jni.so";
		blobs=$blobs"|htcirlibs.jar";
		blobs=$blobs"|CIRModule.apk";
		blobs=$blobs"|cir.img";
		makes=$makes"|android.hardware.ir.*|android.hardware.consumerir.*";
	fi;

	#Keystore/TrustZone (HW Crypto) [Qualcomm]
	#blobs=$blobs"|keystore.qcom.so|libdrmdecrypt.so|libdrmfs.so|libdrmtime.so|libQSEEComAPI.so|librpmb.so|libssd.so|libQTEEConnector.*.so";
	#blobs=$blobs"|qseecomd";
	#blobs=$blobs"|keymaster.*|tzapps.*";
	#blobs=$blobs"|vendor.qti.hardware.qteeconnector.*";

	#libMM (multimedia encoder/decoder/parser) [Qualcomm]
	#blobs=$blobs"|libmmparser.so|libmmipstreamsourcehttp.so";

	#Location (gpsOne/gpsOneXTRA/IZat/Lumicast/QUIP) [Qualcomm]
	blobs=$blobs"|libalarmservice_jni.so|libasn1cper.so|libasn1crt.so|libasn1crtx.so|libdataitems.so|libdrplugin_client.so|libDRPlugin.so|libevent_observer.so|libgdtap.so|libgeofence.so|liblbs_core.so|liblocationservice_glue.so|liblocationservice.so|libloc_ext.so|libloc_xtra.so|liblowi_client.so|liblowi_wifihal_nl.so|liblowi_wifihal.so|libquipc_os_api.so|libquipc_ulp_adapter.so|libulp2.so|libxtadapter.so|libxt_native.so|libxtwifi_ulp_adaptor.so|libxtwifi_zpp_adaptor.so";
	blobs=$blobs"|cacert_location.pem|com.qti.location.sdk.xml|com.qualcomm.location.xml|izat.conf|izat.xt.srv.xml|lowi.conf|xtra_root_cert.pem|xtwifi.conf";
	blobs=$blobs"|com.qti.location.sdk.jar|izat.xt.srv.jar";
	blobs=$blobs"|com.qualcomm.location.apk|com.qualcomm.services.location.apk|xtra_t_app.apk";
	blobs=$blobs"|gpsone_daemon|izat.xt.srv|location-mq|loc_launcher|lowi-server|slim_ap_daemon|slim_daemon|xtwifi-client|xtwifi-inet-agent";
	overlay=$overlay"config_comboNetworkLocationProvider|config_enableFusedLocationOverlay|config_enableNetworkLocationOverlay|config_fusedLocationProviderPackageName|config_enableNetworkLocationOverlay|config_networkLocationProviderPackageName|com.qualcomm.location";

	#Misc
	blobs=$blobs"|libjni_latinime.so|libuiblur.so|libwifiscanner.so";

	#Misc [Google]
	blobs=$blobs"|EaselServicePrebuilt.apk";

	#[Motorola] #See: http://www.beneaththewaves.net/Projects/Motorola_Is_Listening.html
	blobs=$blobs"|AppDirectedSMSProxy.apk|BuaContactAdapter.apk|com.motorola.DirectedSMSProxy.xml|com.motorola.msimsettings.xml";
	blobs=$blobs"|MotoDisplayFWProxy.apk|com.motorola.motodisplay.xml";
	blobs=$blobs"|com.motorola.camera.xml|com.motorola.gallery.xml";
	blobs=$blobs"|EasyAccessService.apk";
	blobs=$blobs"|batt_health";
	#blobs=$blobs"|dbvc_atvc_property_set";
	blobs=$blobs"|com.motorola.motosignature.jar|com.motorola.motosignature.xml|MotoSignatureApp.apk";
	blobs=$blobs"|TriggerEnroll.apk|TriggerTrainingService.apk|com.motorola.triggerenroll.xml";
	blobs=$blobs"|audio.motvr.default.so|libmotaudioutils.so";
	blobs=$blobs"|libcce-socketjni.so|libmotocare.so";
	#blobs=$blobs"|qmi_motext_hook|libmdmcutback.so|libqmimotext.so|libmotext_inf.so"; #necessary for radio
	makes=$makes"|com.motorola.cameraone.xml";

	#OMA-DM/SyncML #See: https://www.blackhat.com/docs/us-14/materials/us-14-Solnik-Cellular-Exploitation-On-A-Global-Scale-The-Rise-And-Fall-Of-The-Control-Protocol.pdf
	blobs=$blobs"|SyncMLSvc.apk|libsyncml_core.so|libsyncml_port.so"; #SyncML
	blobs=$blobs"|libvdmengine.so|libvdmfumo.so"; #RedBend
	blobs=$blobs"|libdme_main.so|libwbxmlparser.so|libprovlib.so";
	blobs=$blobs"|dm_agent|dm_agent_binder";
	blobs=$blobs"|npsmobex"; #Samsung?
	blobs=$blobs"|ConnMO.apk|OmaDmclient.apk|com.android.omadm.service.xml|DCMO.apk|DiagMon.apk|DMConfigUpdate.apk|DMService.apk|libdmengine.so|libdmjavaplugin.so|SprintDM.apk|SDM.apk|whitelist_com.android.omadm.service.xml|com.android.sdm.plugins.connmo.xml|com.android.sdm.plugins.sprintdm.xml"; #Sprint

	#OpenMobileAPI [SIM Alliance]
	#This is open source, but rarely used
	#https://github.com/seek-for-android/platform_packages_apps_SmartCardService
	#blobs=$blobs"|org.simalliance.openmobileapi.jar";
	#blobs=$blobs"|org.simalliance.openmobileapi.xml";

	#Performance [Qualcomm]
	#blobs=$blobs"|msm_irqbalance";
	#Devices utilizing perfd won't hotplug cores without it
	#blobs=$blobs"|mpdecision|perfd";
	#blobs=$blobs"|libqti-perfd.*.so";
	#blobs=$blobs"|perf-profile.*.conf";
	#blobs=$blobs"|vendor.qti.hardware.perf.*";
	blobs=$blobs"|Perfdump.apk";

	#Peripheral Manager
	#blobs=$blobs"|libperipheral_client.so|libspcom.so";
	#blobs=$blobs"|pm-proxy|pm-service|spdaemon";

	#Playready (DRM) [Microsoft]
	blobs=$blobs"|prapp|scranton_RD";
	blobs=$blobs"|libtzplayready.so|libdrmprplugin.so|libprdrmdecrypt.so|libprmediadrmdecrypt.so|libprmediadrmplugin.so|libseppr_hal.so";
	blobs=$blobs"|PR-ModelCert";
	blobs=$blobs"|playread.*|hcheck.*";

	#Power [Google]
	blobs=$blobs"|LowPowerMonitorDevice.*.jar|PowerAnomaly.*.jar";

	#Project Fi [Google]
	blobs=$blobs"|Tycho.apk";

	#Quickboot [Qualcomm]
	blobs=$blobs"|QuickBoot.apk|PowerOffAlarm.apk";

	#QTI (Tethering Extensions) [Qualcomm]
	blobs=$blobs"|libQtiTether.so";
	blobs=$blobs"|QtiTetherService.apk";

	#RIL [Qualcomm]
	blobs=$blobs"|Asdiv.apk";

	#RCS (Proprietary messaging protocol)
	blobs=$blobs"|lib-imsrcscmclient.so|lib-ims-rcscmjni.so|lib-imsrcscmservice.so|lib-imsrcscm.so|lib-imsrcs.so|lib-rcsimssjni.so|lib-rcsjni.so|lib-uceservice.so";
	blobs=$blobs"|rcsimssettings.jar|rcsservice.jar";
	blobs=$blobs"|rcsimssettings.xml|rcsservice.xml";
	blobs=$blobs"|CarrierServices.apk|RCSBootstraputil.apk|RcsImsBootstraputil.apk|uceShimService.apk";
	blobs=$blobs"|vendor.qti.ims.rcsconfig.*";
	makes=$makes"|rcs_service.*";
	ipcSec=$ipcSec"|18:4294967295:1001:3004";

	#[Samsung]
	blobs=$blobs"|SystemUpdateUI.apk";

	#SecProtect [Qualcomm]
	blobs=$blobs"|SecProtect.apk";

	#SecureUI Frontends
	blobs=$blobs"|libHealthAuthClient.so|libHealthAuthJNI.so|libSampleAuthJNI.so|libSampleAuthJNIv1.so|libSampleExtAuthJNI.so|libSecureExtAuthJNI.so|libSecureSampleAuthClient.so|libsdedrm.so";

	#[Sprint]
	blobs=$blobs"|CQATest.apk|GCS.apk|HiddenMenu.apk|LifetimeData.apk|SprintHM.apk|LifeTimerService.apk|SecPhone.apk|SprintMenu.apk";
	ipcSec=$ipcSec"|238:4294967295:1001:3004";

	#Thermal Throttling [Qualcomm]
	#blobs=$blobs"|thermal-engine";
	#blobs=$blobs"|libthermalclient.so|libthermalioctl.so";

	#Time Service [Qualcomm]
	#Requires that android_hardware_sony_timekeep be included in repo manifest
	if [ "$DOS_DEBLOBBER_REPLACE_TIME" = true ]; then
		#blobs=$blobs"|libtime_genoff.so"; #XXX: Breaks radio
		blobs=$blobs"|libTimeService.so";
		blobs=$blobs"|TimeService.apk";
		blobs=$blobs"|time_daemon";
		sepolicy=$sepolicy" qtimeservice.te";
	fi;

	#Venus (Hardware Video Decoding) [Qualcomm]
	#blobs=$blobs"|venus.*";

	#[Verizon]
	blobs=$blobs"|libmotricity.so";
	blobs=$blobs"|com.qualcomm.location.vzw_library.jar|com.verizon.hardware.telephony.ehrpd.jar|com.verizon.hardware.telephony.lte.jar|com.verizon.ims.jar|qti-vzw-ims-internal.jar|VerizonUnifiedSettings.jar";
	blobs=$blobs"|CarrierSetup.apk|OemDmTrigger.apk|appdirectedsmspermission.apk|VerizonSSOEngine.apk|VZWAPNLib.apk|vzwapnpermission.apk|VZWAPNService.apk|VZWAVS.apk|VzwLcSilent.apk|vzw_msdc_api.apk|VzwOmaTrigger.apk|VerizonAuthDialog.apk|MyVerizonServices.apk|WfcActivation.apk|obdm_stub.apk";
	blobs=$blobs"|com.android.vzwomatrigger.xml|vzw_mvs_permissions.xml|obdm_permissions.xml|com.verizon.services.xml|features-verizon.xml|com.qualcomm.location.vzw_library.xml|com.verizon.apn.xml|com.verizon.embms.xml|com.verizon.hardware.telephony.ehrpd.xml|com.verizon.hardware.telephony.lte.xml|com.verizon.ims.xml|com.verizon.provider.xml|com.vzw.vzwapnlib.xml|qti-vzw-ims-internal.xml|vzw_sso_permissions.xml|com.vzw.hardware.lte.xml|com.vzw.hardware.ehrpd.xml";

	#Voice Recognition
	blobs=$blobs"|libadpcmdec.so|liblistenhardware.so|liblistenjni.so|liblisten.so|liblistensoundmodel.so|libqvop-service.so|librecoglib.so|libsmwrapper.so|libsupermodel.so|libtrainingcheck.so|sound_trigger.primary.*.so|libgcs.*.so";
	blobs=$blobs"|audiomonitor|qvop-daemon";
	blobs=$blobs"|HotwordEnrollment.apk|HotwordEnrollment.*.apk";
	blobs=$blobs"|aonvr1.bin|aonvr2.bin|es305_fw.bin";
	blobs=$blobs"|vendor.qti.voiceprint.*";
	makes=$makes"|android.hardware.soundtrigger.*";

	#Wfd (Wireless Display? Wi-Fi Direct?) [Qualcomm]
	blobs=$blobs"|libmmparser_lite.so|libmmrtpdecoder.so|libmmrtpencoder.so|libmmwfdinterface.so|libmmwfdsinkinterface.so|libmmwfdsrcinterface.so|libwfdavenhancements.so|libwfdcommonutils.so|libwfdhdcpcp.so|libwfdmmsink.so|libwfdmmsrc.so|libwfdmmutils.so|libwfdnative.so|libwfdrtsp.so|libwfdservice.so|libwfdsm.so|libwfduibcinterface.so|libwfduibcsinkinterface.so|libwfduibcsink.so|libwfduibcsrcinterface.so|libwfduibcsrc.so";
	blobs=$blobs"|wfdservice";
	blobs=$blobs"|WfdService.apk";
	blobs=$blobs"|WfdCommon.jar";
	blobs=$blobs"|wfdconfigsink.xml|wfdconfig.xml";

	#Widevine (DRM) [Google]
	blobs=$blobs"|libdrmclearkeyplugin.so|libdrmwvmplugin.so|libmarlincdmplugin.so|libwvdrmengine.so|libwvdrm_L1.so|libwvdrm_L3.so|libwvhidl.so|libwvm.so|libWVphoneAPI.so|libWVStreamControlAPI_L1.so|libWVStreamControlAPI_L3.so|libdrmmtkutil.so|libsepdrm.*.so";
	blobs=$blobs"|test-wvdrmplugin|oemwvtest";
	blobs=$blobs"|com.google.widevine.software.drm.jar";
	blobs=$blobs"|com.google.widevine.software.drm.xml";
	#blobs=$blobs"|smc_pa_wvdrm.ift"; breaks toro boot
	blobs=$blobs"|tzwidevine.*|tzwvcpybuf.*|widevine.*";
	makes=$makes"|libshim_wvm";

	#WiPower (Wireless Charging) [Qualcomm]
	blobs=$blobs"|libwbc_jni.so|wbc_hal.default.so";
	blobs=$blobs"|a4wpservice.apk|com.quicinc.wbcserviceapp.apk";
	blobs=$blobs"|com.quicinc.wbc.jar|com.quicinc.wbcservice.jar";
	blobs=$blobs"|com.quicinc.wbcservice.xml|com.quicinc.wbc.xml";
	makes=$makes"|android.wipower|android.wipower.xml|com.quicinc.wbcserviceapps|libwipower_jni|wipowerservice";

	export blobs;
	export makes;
	export overlay;
	export ipcSec;
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
			if ! grep -q "USE_OPENGL_RENDERER := true" BoardConfig.mk; then echo "USE_OPENGL_RENDERER := true" >> BoardConfig.mk; fi;
		fi;
		if [ "$DOS_DEBLOBBER_REMOVE_RENDERSCRIPT" = true ] || [ "$DOS_DEBLOBBER_REMOVE_GRAPHICS" = true ]; then
			awk -i inplace '!/RS_DRIVER/' BoardConfig.mk;
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
	baseDirTmp=${PWD##*/};
	suffixTmp="-common";
	if [ -f "${PWD##*/}".mk ] && [ "${PWD##*/}".mk != "sepolicy" ]; then
		awk -i inplace '!/'"$makes"'/' "${PWD##*/}".mk; #Remove references from device makefile
		awk -i inplace '!/'"$makes"'/' "${baseDirTmp%"$suffixTmp"}".mk &>/dev/null || true; #Remove references from device makefile
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
	if [ "$DOS_DEBLOBBER_REMOVE_IPA" = true ]; then rm -rf data-ipa-cfg-mgr; fi; #Remove IPA
	rm -rf libshimwvm libshims/wvm_shim.cpp; #Remove Google Widevine compatibility module
	rm -rf board/qcom-wipower.mk product/qcom-wipower.mk; #Remove WiPower makefiles
	awk -i inplace '!/'$ipcSec'/' configs/sec_config &>/dev/null || true; #Remove all IPC security exceptions from sec_config
	awk -i inplace '!/'$blobs'/' ./*proprietary*.txt &>/dev/null || true; #Remove all blob references from blob manifest
	awk -i inplace '!/'$blobs'/' ./*/*proprietary*.txt &>/dev/null || true; #Remove all blob references from blob manifest location in subdirectory
	if [ -f setup-makefiles.sh ]; then
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
