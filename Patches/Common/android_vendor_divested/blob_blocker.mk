include $(CLEAR_VARS)

# vendor makefiles often end up with these not being removed from Android.mk
# which causes build failures since their files were deleted
# override here to prevent breakage

LOCAL_MODULE := BlobBlocker

LOCAL_OVERRIDES_PACKAGES := \
    a4wpservice \
    appdirectedsmspermission \
    AppDirectedSMSProxy \
    ApplicationBar \
    aptxui \
    atfwd \
    AtvRemoteService \
    BuaContactAdapter \
    CABLService \
    CanvasPackageInstaller \
    CarrierServices \
    CNEService \
    colorservice \
    ConnMO \
    CQATest \
    DCMO \
    DiagMon \
    DMConfigUpdate \
    DMService \
    DolbyVisionService \
    dpmserviceapp \
    DragonKeyboardFirmwareUpdater \
    DTVPlayer \
    DTVService \
    EasyAccessService \
    embms \
    FMRadioGooogle \
    FmRadioTrampoline2 \
    GamepadPairingService \
    GCS \
    GeminiInputDevices \
    Gemini_Keyboard \
    GlobalkeyInteceptor \
    HiddenMenu \
    HotwordEnrollment \
    HWSarControlService \
    imssettings \
    LeanbackIme \
    LeanbackLauncher \
    LifetimeData \
    LifeTimerService \
    ModFmwkProxyService \
    ModService \
    MotCameraMod \
    MotoDisplayFWProxy \
    MotoSignatureApp \
    MyVerizonServices \
    OBDM_Permissions \
    obdm_stub \
    Overscan \
    Perfdump \
    PowerOffAlarm \
    PPPreference \
    ProjecterApp \
    QtiTetherService \
    QuickBoot \
    RCSBootstraputil \
    RcsImsBootstraputil \
    RemoteControlService \
    SDM \
    SecPhone \
    SecProtect \
    SprintDM \
    SprintHM \
    SprintMenu \
    SyncMLSvc \
    SystemUpdateUI \
    TriggerEnroll \
    TriggerTrainingService \
    Tycho \
    uceShimService \
    VerizonAuthDialog \
    VerizonSSOEngine \
    VerizonUnifiedSettings \
    VZWAPNLib \
    vzwapnpermission \
    VZWAPNService \
    VZWAVS \
    VzwLcSilent \
    vzw_msdc_api \
    VzwOmaTrigger \
    WfcActivation \
    WfdService

include $(BUILD_PREBUILT)
