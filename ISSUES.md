Known Issues
============

All Devices
-----------
- Most devices will take longer to acquire a GPS lock. Please test using GPSTest app with *clear* and *direct* line of sky. [deblobber]
- Devices using 'encryptable=footer' in their fstab will not be encrypted by default. [patcher]
- Select older devices running 17.1/10 or higher will fail to connect to 802.11w optional enabled Wi-Fi networks due to lack of PMF support. [hardware]
- Incremental updates will often fail to successfuly apply on non A/B devices. [releasetools]
- Devices with 1GB of RAM or less will likely out-of-memory more often than usual. [slub_debug fragmentation?]
- Silence will crash if first started without a SIM-card inserted. [upstream]
- MediaProvider error toast on some boots. [permission whitelist?]
- Updater JSON parsing error on 14.1. [upstream?]

apollo/thor
-----------
- Encryption is not supported. [upstream blobs]

clark
-----
- TWRP is required for flashing images due to modem firmware being compressed. [recovery]

d852
----
- Sensors will not work unless you have a hybrid v220k modem which requires an a10b bootloader. [firmware]

d852/d855/g3
------------
- Device will often fail to reboot and become unresponsive, requiring the battery to be pulled. [hardware]

grouper
-------
- Relocking bootloader with an AOSP/Lineage/DivestOS recovery flashed will result in a *permanent hard brick* unless you have acquired your NvFlash recovery token! [bootloader]
- Camera is non-functional. [upstream kernel]
- Device is extremely slow. [hardware?]

herolte
-------
- (reported) bootloops [???]

klte
----
- SD cards will fail to mount or format [selinux]
- USB ADB does not work [selinux]

maguro/toro/toroplus
--------------------
- Not encrypted by default. [OMAP SMC limitation]

mako
----
- Will fail to boot on first boot. Force off once after 3 minutes. [modem subsystem service startup failure with forceencrypt]
- Excessive battery drain when powered-off. [???]
- /system needs to be resized to fit 17.1. [too small parition]

mata
----
- Images will often fail to install via recovery. [fstab /vendor/firmware_mnt]

nex/n900
--------
- Encryption is not supported. [upstream device tree?]
- Camera is non-functional. [upstream blobs?]
- GPS is non-funtional. [deblobber]

shamu
-----
- (reported) No microphone on phone calls. [deblobber?]
- (reported) bootloops [???]
