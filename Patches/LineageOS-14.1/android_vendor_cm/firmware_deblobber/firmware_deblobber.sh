#!/sbin/sh
#Maintain "safe" parity with Deblob.sh
#Why so many lines? Why not make a fancy function? Because we'd rather not brick devices!

rm -f /firmware/alipay.b00
rm -f /firmware/alipay.b01
rm -f /firmware/alipay.b02
rm -f /firmware/alipay.b03
rm -f /firmware/alipay.b04
rm -f /firmware/alipay.b05
rm -f /firmware/alipay.b06
rm -f /firmware/alipay.mdt
rm -f /firmware/image/alipay.b00
rm -f /firmware/image/alipay.b01
rm -f /firmware/image/alipay.b02
rm -f /firmware/image/alipay.b03
rm -f /firmware/image/alipay.b04
rm -f /firmware/image/alipay.b05
rm -f /firmware/image/alipay.b06
rm -f /firmware/image/alipay.mdt
echo "Removed Alibaba AliPay firmware"

rm -f /firmware/dxcprm.b00
rm -f /firmware/dxcprm.b01
rm -f /firmware/dxcprm.b02
rm -f /firmware/dxcprm.b03
rm -f /firmware/dxcprm.mdt
rm -f /firmware/image/dxcprm.b00
rm -f /firmware/image/dxcprm.b01
rm -f /firmware/image/dxcprm.b02
rm -f /firmware/image/dxcprm.b03
rm -f /firmware/image/dxcprm.mdt
echo "Removed Discretix DRM (old) firmware"

rm -f /firmware/dxhdcp2.b00
rm -f /firmware/dxhdcp2.b01
rm -f /firmware/dxhdcp2.b02
rm -f /firmware/dxhdcp2.b03
rm -f /firmware/dxhdcp2.mdt
rm -f /firmware/image/dxhdcp2.b00
rm -f /firmware/image/dxhdcp2.b01
rm -f /firmware/image/dxhdcp2.b02
rm -f /firmware/image/dxhdcp2.b03
rm -f /firmware/image/dxhdcp2.mdt
echo "Removed Discretix DRM (new) firmware"

rm -f /firmware/widevine.b00
rm -f /firmware/widevine.b01
rm -f /firmware/widevine.b02
rm -f /firmware/widevine.b03
rm -f /firmware/widevine.b04
rm -f /firmware/widevine.b05
rm -f /firmware/widevine.b06
rm -f /firmware/widevine.mdt
rm -f /firmware/image/widevine.b00
rm -f /firmware/image/widevine.b01
rm -f /firmware/image/widevine.b02
rm -f /firmware/image/widevine.b03
rm -f /firmware/image/widevine.b04
rm -f /firmware/image/widevine.b05
rm -f /firmware/image/widevine.b06
rm -f /firmware/image/widevine.mdt
echo "Removed Google Widevine DRM firmware"

rm -f /firmware/tzwidevine.b00
rm -f /firmware/tzwidevine.b01
rm -f /firmware/tzwidevine.b02
rm -f /firmware/tzwidevine.b03
rm -f /firmware/tzwidevine.mdt
rm -f /firmware/image/tzwidevine.b00
rm -f /firmware/image/tzwidevine.b01
rm -f /firmware/image/tzwidevine.b02
rm -f /firmware/image/tzwidevine.b03
rm -f /firmware/image/tzwidevine.mdt
echo "Removed Google Widevine DRM (alternate 1) firmware"

rm -f /firmware/tzwvcpybuf.b00
rm -f /firmware/tzwvcpybuf.b01
rm -f /firmware/tzwvcpybuf.b02
rm -f /firmware/tzwvcpybuf.b03
rm -f /firmware/tzwvcpybuf.mdt
rm -f /firmware/image/tzwvcpybuf.b00
rm -f /firmware/image/tzwvcpybuf.b01
rm -f /firmware/image/tzwvcpybuf.b02
rm -f /firmware/image/tzwvcpybuf.b03
rm -f /firmware/image/tzwvcpybuf.mdt
echo "Removed Google Widevine DRM (alternate 2) firmware"

rm -f /firmware/htc_drmprov.b00
rm -f /firmware/htc_drmprov.b01
rm -f /firmware/htc_drmprov.b02
rm -f /firmware/htc_drmprov.b03
rm -f /firmware/htc_drmprov.b04
rm -f /firmware/htc_drmprov.b05
rm -f /firmware/htc_drmprov.b06
rm -f /firmware/htc_drmprov.mdt
rm -f /firmware/image/htc_drmprov.b00
rm -f /firmware/image/htc_drmprov.b01
rm -f /firmware/image/htc_drmprov.b02
rm -f /firmware/image/htc_drmprov.b03
rm -f /firmware/image/htc_drmprov.b04
rm -f /firmware/image/htc_drmprov.b05
rm -f /firmware/image/htc_drmprov.b06
rm -f /firmware/image/htc_drmprov.mdt
echo "Removed HTC DRM firmware"

rm -f /firmware/playread.b00
rm -f /firmware/playread.b01
rm -f /firmware/playread.b02
rm -f /firmware/playread.b03
rm -f /firmware/playread.mdt
rm -f /firmware/image/playread.b00
rm -f /firmware/image/playread.b01
rm -f /firmware/image/playread.b02
rm -f /firmware/image/playread.b03
rm -f /firmware/image/playread.mdt
echo "Removed Microsoft PlayReady DRM firmware"

rm -f /firmware/hdcp1.b00
rm -f /firmware/hdcp1.b01
rm -f /firmware/hdcp1.b02
rm -f /firmware/hdcp1.b03
rm -f /firmware/hdcp1.b04
rm -f /firmware/hdcp1.b05
rm -f /firmware/hdcp1.b06
rm -f /firmware/hdcp1.mdt
rm -f /firmware/image/hdcp1.b00
rm -f /firmware/image/hdcp1.b01
rm -f /firmware/image/hdcp1.b02
rm -f /firmware/image/hdcp1.b03
rm -f /firmware/image/hdcp1.b04
rm -f /firmware/image/hdcp1.b05
rm -f /firmware/image/hdcp1.b06
rm -f /firmware/image/hdcp1.mdt
echo "Removed [Unknown 1] DRM firmware"

rm -f /firmware/tzhdcp.b00
rm -f /firmware/tzhdcp.b01
rm -f /firmware/tzhdcp.b02
rm -f /firmware/tzhdcp.b03
rm -f /firmware/tzhdcp.mdt
rm -f /firmware/image/tzhdcp.b00
rm -f /firmware/image/tzhdcp.b01
rm -f /firmware/image/tzhdcp.b02
rm -f /firmware/image/tzhdcp.b03
rm -f /firmware/image/tzhdcp.mdt
echo "Removed [Unknown 2] DRM firmware"
