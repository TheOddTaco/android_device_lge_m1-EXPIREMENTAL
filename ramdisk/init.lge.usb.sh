#!/system/bin/sh
# Copyright (c) 2012, Code Aurora Forum. All rights reserved.
# Copyright (c) 2012, LG Electronics Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Code Aurora Forum, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
chown -h root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
chmod -h 220 /sys/devices/platform/msm_hsusb/gadget/wakeup

target=`getprop ro.board.platform`
case $target in
    "msm8994" | "msm8992")
    echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
    echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8952" | "msm8976")
    echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
    # Increase RNDIS DL max aggregation size to 11K
    echo 11264 > /sys/module/g_android/parameters/rndis_dl_max_xfer_size
    echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "apq8084")
    echo qti,ether > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "apq8064")
    echo hsic,hsic > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8909")
    echo qti,bam > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    * )
    echo smd,bam > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
esac
echo 1  > /sys/class/android_usb/f_mass_storage/lun/nofua
echo 1  > /sys/class/android_usb/f_cdrom_storage/lun/nofua

#
# Allow USB enumeration with default PID/VID
#
usb_config=`getprop persist.sys.usb.config`
case "$usb_config" in
    "" | "pc_suite" | "mtp_only")
    setprop persist.sys.usb.config auto_conf
    ;;
    "adb" | "pc_suite,adb" | "mtp_only,adb")
    setprop persist.sys.usb.config auto_conf,adb
    ;;
    * ) ;; #USB persist config exists, do nothing
esac

# soc_ids for 8916/8939 differentiation
if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=`cat /sys/devices/soc0/soc_id`
else
    soc_id=`cat /sys/devices/system/soc/soc0/id`
fi

# enable rps cpus on msm8939/msm8909 target
setprop sys.usb.rps_mask 0
case "$soc_id" in
    "239" | "241" | "263")
        setprop sys.usb.rps_mask 10
    ;;
    "245" | "260" | "261" | "262"
        setprop sys.usb.rps_mask 2
    ;;
esac
