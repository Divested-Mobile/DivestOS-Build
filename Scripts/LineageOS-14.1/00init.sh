#!/bin/bash

#Sets settings used by all other scripts

base="/mnt/Drive-1/Development/Other/Android_ROMs/Build/LineageOS-14.1/";
export base;

patches="/mnt/Drive-1/Development/Other/Android_ROMs/Patches/LineageOS-14.1/";
export patches;

cvePatches="/mnt/Drive-1/Development/Other/Android_ROMs/Patches/Linux_CVEs/";
export cvePatches;

scripts="/mnt/Drive-1/Development/Other/Android_ROMs/Scripts/LineageOS-14.1/";
export scripts;

cveScripts=$scripts"CVE_Patchers/";
export cveScripts;

ANDROID_HOME="/home/$USER/Android/Sdk";
export ANDROID_HOME;
