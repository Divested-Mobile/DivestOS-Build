include $(CLEAR_VARS)

LOCAL_MODULE := ModuleBlocker

LOCAL_OVERRIDES_PACKAGES := \
    bootanimation.zip \
    PhotoTable \
    Terminal \
    LockClock \
    WeatherProvider \
    bash \
    curl \
    htop \
    powertop \
    strace \
    vim \
    wget \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh \
    rsync \
    su \
    Stk \
    libdrmclearkeyplugin \
    libclearkeycasplugin \
    CtsShimPrebuilt \
    CtsShimPrivPrebuilt \
    MusicFX
#    drmserver \
#    libfwdlockengine \

include $(BUILD_PREBUILT)
