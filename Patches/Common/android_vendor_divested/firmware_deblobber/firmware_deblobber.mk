FD_PREBUILTS_PATH := vendor/divested/firmware_deblobber

FD_INSTALL_OUT := $(PRODUCT_OUT)/firmware_deblobber/
FD_INSTALL_TARGET := $(PRODUCT_OUT)/firmware_deblobber-$(TARGET_ARCH).zip

$(FD_INSTALL_TARGET): $(ALL_MODULES.updater.BUILT)
	$(hide) rm -rf $@ $(FD_INSTALL_OUT)
	$(hide) mkdir -p $(FD_INSTALL_OUT)/META-INF/com/google/android/
	$(hide) cp $(ALL_MODULES.updater.BUILT) $(FD_INSTALL_OUT)/META-INF/com/google/android/update-binary
	$(hide) cp $(FD_PREBUILTS_PATH)/firmware_deblobber.sh $(FD_INSTALL_OUT)/
	$(hide) cp $(FD_PREBUILTS_PATH)/updater-script $(FD_INSTALL_OUT)/META-INF/com/google/android/updater-script
	$(hide) (cd $(FD_INSTALL_OUT) && zip -qr $@ *)

.PHONY: firmware_deblobber
firmware_deblobber: $(FD_INSTALL_TARGET)
	@echo "Done: $(FD_INSTALL_TARGET)"
