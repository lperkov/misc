#!/usr/bin/env sh
#
#  OpenWrt defconfig generation script
#
#  Copyright (C) 2014 Cisco Systems, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
#  Author: Luka Perkov <luka.perkov@sartura.hr>
#

openwrt_refresh_tmp_dir() {
	# our default build location
	cd /opt/openwrt/trunk/

	# delete tmp directory
	rm -rf tmp/

	rm -rf .config
	make defconfig

	rm -rf .config

	# go back to our original directory
	cd - > /dev/null
}

openwrt_append_lxc_defconfig() {
	cat >> $1 << EOF
CONFIG_PACKAGE_kmod-veth=y
CONFIG_PACKAGE_liblxc=y
CONFIG_PACKAGE_lxc=y
CONFIG_LXC_KERNEL_OPTIONS=y
CONFIG_LXC_BUSYBOX_OPTIONS=y
CONFIG_PACKAGE_lxc-common=y
CONFIG_PACKAGE_lxc-cgroup=y
CONFIG_PACKAGE_lxc-config=y
CONFIG_PACKAGE_lxc-configs=y
CONFIG_PACKAGE_lxc-console=y
CONFIG_PACKAGE_lxc-create=y
CONFIG_PACKAGE_lxc-destroy=y
CONFIG_PACKAGE_lxc-freeze=y
CONFIG_PACKAGE_lxc-hooks=y
CONFIG_PACKAGE_lxc-info=y
CONFIG_PACKAGE_lxc-ls=y
CONFIG_PACKAGE_lxc-start=y
CONFIG_PACKAGE_lxc-stop=y
CONFIG_PACKAGE_lxc-templates=y
CONFIG_PACKAGE_lxc-unfreeze=y
CONFIG_PACKAGE_rpcd-mod-lxc=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-app-lxc=y
EOF
}

openwrt_append_lxc_template_defconfig() {
return 0
	cat >> $1 << EOF
CONFIG_PACKAGE_liblxc=y
CONFIG_PACKAGE_lxc=y
CONFIG_PACKAGE_lxc-init=y
EOF
}

openwrt_generate_ar71xx_defconfigs() {
	# our default build location
	cd /opt/openwrt/trunk/

	local PROFILES=`awk 'BEGIN { FS = " |/"} /^Target: ar71xx\// { subtarget=$3; } /^Target-Profile: / { profile=$2; print subtarget "_" profile }' tmp/info/.targetinfo-ar71xx`

	# go back to our original directory
	cd - > /dev/null

	for PROFILE in $PROFILES; do
		SUBTARGET=`echo $PROFILE | awk -F_ '{ print $1 }'`
		cat > defconfigs/ar71xx_$PROFILE << EOF
CONFIG_DEVEL=y
CONFIG_CCACHE=y
CONFIG_TARGET_ar71xx=y
CONFIG_TARGET_ar71xx_$SUBTARGET=y
CONFIG_TARGET_ar71xx_$PROFILE=y
EOF
		openwrt_append_lxc_defconfig defconfigs/ar71xx_$PROFILE
	done
}

openwrt_generate_kirkwood_defconfigs() {
	# our default build location
	cd /opt/openwrt/trunk/

	local PROFILES=`awk '/^Target-Profile: / { print $2 }' tmp/info/.targetinfo-kirkwood`

	# go back to our original directory
	cd - > /dev/null

	for PROFILE in $PROFILES; do
		cat > defconfigs/kirkwood_$PROFILE << EOF
CONFIG_DEVEL=y
CONFIG_CCACHE=y
CONFIG_TARGET_kirkwood=y
CONFIG_TARGET_kirkwood_$PROFILE=y
CONFIG_TARGET_ROOTFS_INCLUDE_KERNEL=y
CONFIG_TARGET_ROOTFS_INCLUDE_UIMAGE=n
CONFIG_TARGET_ROOTFS_INCLUDE_ZIMAGE=y
CONFIG_TARGET_ROOTFS_INCLUDE_FIT=n
CONFIG_TARGET_ROOTFS_INCLUDE_DTB=y
EOF
		openwrt_append_lxc_defconfig defconfigs/kirkwood_$PROFILE
	done
}

openwrt_generate_x86_defconfigs() {
	# our default build location
	cd /opt/openwrt/trunk/

	local PROFILES=`awk 'BEGIN { FS = " |/"} /^Target: x86\// { subtarget=$3; } /^Target-Profile: / { profile=$2; print subtarget "_" profile }' tmp/info/.targetinfo-x86`

	# go back to our original directory
	cd - > /dev/null

	mkdir defconfigs 2> defconfigs
	for PROFILE in $PROFILES; do
		SUBTARGET=`echo $PROFILE | awk -F_ '{ print $1 }'`
		cat > defconfigs/x86_$PROFILE << EOF
CONFIG_DEVEL=y
CONFIG_CCACHE=y
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_$SUBTARGET=y
CONFIG_TARGET_x86_$PROFILE=y
EOF
		openwrt_append_lxc_defconfig defconfigs/x86_$PROFILE
	done
}

openwrt_refresh_tmp_dir

openwrt_generate_ar71xx_defconfigs
openwrt_generate_kirkwood_defconfigs
openwrt_generate_x86_defconfigs
