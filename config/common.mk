PRODUCT_BRAND ?= resurrection

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ "$(TARGET_SCREEN_WIDTH)" -lt "$(TARGET_SCREEN_HEIGHT)" ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,,$(shell ls -1 vendor/cm/prebuilt/common/bootanimation | sort -rn))

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then \
    if [ "$(1)" -le "$(TARGET_BOOTANIMATION_SIZE)" ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/cm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/cm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# OMS ThemeInterfacer
PRODUCT_PACKAGES += \
   ThemeInterfacer

# OMS Verified
PRODUCT_PROPERTY_OVERRIDES := \
    ro.substratum.verified=true

WITH_ROOT_METHOD ?= su
ifeq ($(WITH_ROOT_METHOD), magisk)
# Magisk Manager
PRODUCT_PACKAGES += \
    MagiskManager

# Copy Magisk zip
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/zip/magisk.zip:system/addon.d/magisk.zip

# Magisk Root Flag
PRODUCT_PROPERTY_OVERRIDES := \
    ro.rr.root=magisk
endif

# Enable Google Assistant on all devices.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opa.eligible_device=true

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Chime.ogg \
    ro.config.alarm_alert=Flow.ogg

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    CHANGELOG.mkdn:system/etc/RR/Changelog.txt

# Copy features.txt from the path
PRODUCT_COPY_FILES += \
    vendor/cm/Features.mkdn:system/etc/RR/Features.txt

# NexusLauncher
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/NexusLauncher/NexusLauncher.apk:system/app/NexusLauncher/NexusLauncher.apk

# Wallpaper
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/Wallpaper/Wallpaper.apk:system/app/Wallpaper/Wallpaper.apk
    
# Adaway
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/Adaway/Adaway.apk:system/app/Adaway/Adaway.apk
    
# 3Minit Battery Resources
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/3Minit/3MinitBatteryResources.apk:system/app/3MinitBatteryResources/3MinitBatteryResources.apk \
    vendor/cm/prebuilt/3Minit/3MinitBatterySettings.apk:system/app/3MinitBatterySettings/3MinitBatterySettings.apk

# DU Utils Library
PRODUCT_BOOT_JARS += \
    org.dirtyunicorns.utils

# DU Utils Library
PRODUCT_PACKAGES += \
    org.dirtyunicorns.utils

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/cm/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/cm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/cm/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# System feature whitelists
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/backup.xml:system/etc/sysconfig/backup.xml \
    vendor/cm/config/permissions/power-whitelist.xml:system/etc/sysconfig/power-whitelist.xml

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Include CM audio files
include vendor/cm/config/cm_audio.mk

# Theme engine
include vendor/cm/config/themes_common.mk

ifneq ($(TARGET_DISABLE_CMSDK), true)
# CMSDK
include vendor/cm/config/cmsdk_common.mk
endif

# Required CM packages
PRODUCT_PACKAGES += \
    BluetoothExt \
    CMAudioService \
    CMParts \
    Development \
    Profiles \
    WeatherManagerService

# Optional CM packages
PRODUCT_PACKAGES += \
    libemoji \
    Terminal \
    LiveWallpapersPicker \
    PhotoTable

# Include explicitly to work around GMS issues
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full \
    librsjni

# Custom CM packages
PRODUCT_PACKAGES += \
    ResurrectionOTA \
    Trebuchet \
    AudioFX \
    Eleven \
    LockClock \
    CMSettingsProvider \
    ExactCalculator \
    Jelly \
    LiveLockScreenService \
    WeatherProvider \
    OmniStyle \
    OmniSwitch \
    OmniJaws \
    OmniClockOSS \
    ThemeInterfacer

# Exchange support
PRODUCT_PACKAGES += \
    Exchange2

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    mke2fs \
    tune2fs \
    nano \
    htop \
    mkfs.ntfs \
    fsck.ntfs \
    mount.ntfs \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace \
    pigz \
    7z \
    lib7z \
    bash \
    bzip2 \
    curl \
    powertop \
    unrar \
    unzip \
    vim \
    wget \
    zip

# Custom off-mode charger
ifneq ($(WITH_CM_CHARGER),false)
PRODUCT_PACKAGES += \
    charger_res_images \
    cm_charger_res_images \
    font_log.png \
    libhealthd.cm
endif

# ExFAT support
WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

#Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
     libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# Storage manager
PRODUCT_PROPERTY_OVERRIDES += \
    ro.storage_manager.enabled=true

# Telephony
PRODUCT_PACKAGES += \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank

# Conditionally build in su
WITH_ROOT_METHOD ?= magisk
ifeq ($(WITH_ROOT_METHOD), su)
PRODUCT_PACKAGES += \
    su

# CM Root Flag
PRODUCT_PROPERTY_OVERRIDES := \
    ro.rr.root=cm_root
endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=2

DEVICE_PACKAGE_OVERLAYS += vendor/cm/overlay/common

PRODUCT_VERSION = 5.8.5

ifeq ($(WITH_ROOT_METHOD), magisk)
ifneq ($(RR_BUILDTYPE),)
RR_VERSION := RR-N-MAGISK-v$(PRODUCT_VERSION)-$(shell date -u +%Y%m%d)-$(CM_BUILD)-$(RR_BUILDTYPE)
else
RR_VERSION := RR-N-MAGISK-v$(PRODUCT_VERSION)-$(shell date -u +%Y%m%d)-$(CM_BUILD)
endif
endif

ifeq ($(WITH_ROOT_METHOD), su)
ifneq ($(RR_BUILDTYPE),)
RR_VERSION := RR-N-CMSU-v$(PRODUCT_VERSION)-$(shell date -u +%Y%m%d)-$(CM_BUILD)-$(RR_BUILDTYPE)
else
RR_VERSION := RR-N-CMSU-v$(PRODUCT_VERSION)-$(shell date -u +%Y%m%d)-$(CM_BUILD)
endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
 ro.rr.version=$(RR_VERSION) \
 ro.modversion=$(RR_VERSION) \
 rr.build.type=$(RR_BUILDTYPE) \
 rr.ota.version= $(shell date +%Y%m%d) \
 ro.rr.tag=$(shell grep "refs/tags" .repo/manifest.xml  | cut -d'"' -f2 | cut -d'/' -f3)

CM_DISPLAY_VERSION := $(RR_VERSION)

PRODUCT_PROPERTY_OVERRIDES += \
  ro.rr.display.version=$(CM_DISPLAY_VERSION)

PRODUCT_EXTRA_RECOVERY_KEYS += \
  vendor/cm/build/target/product/security/lineage

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/cm/config/partner_gms.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
