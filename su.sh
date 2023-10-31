#!/bin/bash

#Usage:
#bash su.sh [/path/to/system/image]

#cleanups
umount d

set -ex

origin="$(readlink -f -- "$0")"
origin="$(dirname "$origin")"

if [ -f "$1" ];then
    srcFile="$1"
fi

if [ ! -f "$srcFile" ];then
	echo "Usage: sudo bash su.sh [/path/to/system.img]"
	exit 1
fi

"$origin"/simg2img "$srcFile" s-secure.img || cp "$srcFile" s-su.img

rm -rf d me.phh.superuser.apk su su.rc
wget https://f-droid.org/repo/me.phh.superuser_1033.apk -O me.phh.superuser.apk
wget https://github.com/phhusson/device_phh_treble/raw/android-12.0/su/su
wget https://github.com/phhusson/device_phh_treble/raw/android-12.0/su/su.rc

mkdir -p d
e2fsck -y -f s-su.img
resize2fs s-su.img 4000M
e2fsck -E unshare_blocks -y -f s-su.img
mount -o loop,rw s-su.img d

cp su d/system/bin/phh-su
chmod 755 d/system/bin/phh-su
chown root:2000 d/system/bin/phh-su
xattr -w security.selinux u:object_r:phhsu_exec:s0 d/system/bin/phh-su

mv su.rc d/system/etc/init/su.rc
chmod 644 d/system/etc/init/su.rc
chown root:root d/system/etc/init/su.rc
xattr -w security.selinux u:object_r:system_file:s0 d/system/etc/init/su.rc

mkdir -p d/system/xbin
chmod 755 d/system/xbin
chown root:root d/system/xbin
xattr -w security.selinux u:object_r:system_file:s0 d/system/xbin

mv su d/system/xbin/su
chmod 755 d/system/xbin/su
chown root:root d/system/xbin/su
xattr -w security.selinux u:object_r:system_file:s0 d/system/xbin/su

ln -sfn /system/xbin/su d/system/bin/su
chown -h root:2000 d/system/bin/su
xattr -sw security.selinux u:object_r:system_file:s0 d/system/bin/su

mkdir -p d/system/priv-app/me.phh.superuser
chmod 755 d/system/priv-app/me.phh.superuser
chown root:root d/system/priv-app/me.phh.superuser
xattr -w security.selinux u:object_r:system_file:s0 d/system/priv-app/me.phh.superuser

mv me.phh.superuser.apk d/system/priv-app/me.phh.superuser
chmod 644 d/system/priv-app/me.phh.superuser/me.phh.superuser.apk
chown root:root d/system/priv-app/me.phh.superuser/me.phh.superuser.apk
xattr -w security.selinux u:object_r:system_file:s0 d/system/priv-app/me.phh.superuser/me.phh.superuser.apk

sleep 1

umount d

e2fsck -f -y s-su.img || true
resize2fs -M s-su.img

rm -rf d me.phh.superuser.apk su su.rc
