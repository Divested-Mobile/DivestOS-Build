#!/sbin/sh

rm -f /firmware/image/playread.b00
rm -f /firmware/image/playread.b01
rm -f /firmware/image/playread.b02
rm -f /firmware/image/playread.b03
rm -f /firmware/image/playread.mdt
echo "Removed Microsoft PlayReady DRM firmware"

rm -f /firmware/image/widevine.b00
rm -f /firmware/image/widevine.b01
rm -f /firmware/image/widevine.b02
rm -f /firmware/image/widevine.b03
rm -f /firmware/image/widevine.mdt
echo "Removed Google Widevine DRM firmware"
