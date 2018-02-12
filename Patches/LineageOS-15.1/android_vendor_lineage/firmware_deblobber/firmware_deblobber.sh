#!/sbin/sh
#Maintain "safe" parity with Deblob.sh
#Why so many lines? Why not make a fancy function? Because we'd rather not brick devices!

deleteBlob() {
	rm -f /firmware/$1;
	rm -f /firmware/image/$1;
}

deleteBlob alipay.b00
deleteBlob alipay.b01
deleteBlob alipay.b02
deleteBlob alipay.b03
deleteBlob alipay.b04
deleteBlob alipay.b05
deleteBlob alipay.b06
deleteBlob alipay.mdt
echo "Removed Alibaba AliPay firmware"

deleteBlob dxcprm.b00
deleteBlob dxcprm.b01
deleteBlob dxcprm.b02
deleteBlob dxcprm.b03
deleteBlob dxcprm.mdt
echo "Removed Discretix DRM (old) firmware"

deleteBlob dxhdcp2.b00
deleteBlob dxhdcp2.b01
deleteBlob dxhdcp2.b02
deleteBlob dxhdcp2.b03
deleteBlob dxhdcp2.mdt
echo "Removed Discretix DRM (new) firmware"

deleteBlob widevine.b00
deleteBlob widevine.b01
deleteBlob widevine.b02
deleteBlob widevine.b03
deleteBlob widevine.b04
deleteBlob widevine.b05
deleteBlob widevine.b06
deleteBlob widevine.mdt
echo "Removed Google Widevine DRM firmware"

deleteBlob tzwidevine.b00
deleteBlob tzwidevine.b01
deleteBlob tzwidevine.b02
deleteBlob tzwidevine.b03
deleteBlob tzwidevine.mdt
echo "Removed Google Widevine DRM (alternate 1) firmware"

deleteBlob tzwvcpybuf.b00
deleteBlob tzwvcpybuf.b01
deleteBlob tzwvcpybuf.b02
deleteBlob tzwvcpybuf.b03
deleteBlob tzwvcpybuf.mdt
echo "Removed Google Widevine DRM (alternate 2) firmware"

deleteBlob htc_drmprov.b00
deleteBlob htc_drmprov.b01
deleteBlob htc_drmprov.b02
deleteBlob htc_drmprov.b03
deleteBlob htc_drmprov.b04
deleteBlob htc_drmprov.b05
deleteBlob htc_drmprov.b06
deleteBlob htc_drmprov.mdt
echo "Removed HTC DRM firmware"

deleteBlob playread.b00
deleteBlob playread.b01
deleteBlob playread.b02
deleteBlob playread.b03
deleteBlob playread.mdt
echo "Removed Microsoft PlayReady DRM firmware"

deleteBlob hdcp1.b00
deleteBlob hdcp1.b01
deleteBlob hdcp1.b02
deleteBlob hdcp1.b03
deleteBlob hdcp1.b04
deleteBlob hdcp1.b05
deleteBlob hdcp1.b06
deleteBlob hdcp1.mdt
echo "Removed [Unknown 1] DRM firmware"

deleteBlob tzhdcp.b00
deleteBlob tzhdcp.b01
deleteBlob tzhdcp.b02
deleteBlob tzhdcp.b03
deleteBlob tzhdcp.mdt
echo "Removed [Unknown 2] DRM firmware"
