#
# Copyright (C) 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Changes various properties to reduce memory usage even on devices with 1GB+ RAM

# Set lowram options
PRODUCT_PROPERTY_OVERRIDES += \
     ro.config.low_ram=true \
     ro.lmk.critical_upgrade=true \
     ro.lmk.upgrade_pressure=40 \
     config.disable_atlas=true \
     persist.sys.use_16bpp_alpha=1

# set threshold to filter unused apps
PRODUCT_PROPERTY_OVERRIDES += \
     pm.dexopt.downgrade_after_inactive_days=14

# Speed profile services and wifi-service to reduce RAM and storage.
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Always preopt extracted APKs to prevent extracting out of the APK for gms
# modules.
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true
