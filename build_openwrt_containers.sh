#!/usr/bin/env sh
#
#  OpenWrt lxc container build automation script
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

if [ `id -u` -ne 0 ]; then
	echo "run this script as root"
	exit 1
fi

HOSTNAME="vwrt"
DIR_CONAINER_WORKING="./rootfs"

DIR_OPENWRT_TRUNK="/opt/openwrt/trunk/"
DIR_THIS_FILE=`pwd`

openwrt_container_configure_inittab() {
	cat > etc/inittab << EOF 
::sysinit:/etc/init.d/rcS S boot
::shutdown:/etc/init.d/rcS K shutdown
console::askfirst:/bin/ash --login
tty1::askfirst:/bin/ash --login
tty2::askfirst:/bin/ash --login
tty3::askfirst:/bin/ash --login
tty4::askfirst:/bin/ash --login
EOF
}

openwrt_container_configure_network() {
	cat > etc/config/network << EOF
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config interface 'wan'
	option ifname 'eth0'
	option proto 'dhcp'
EOF
}

openwrt_container_configure_system() {
	cat > etc/config/system << EOF
config system
	option timezone 'UTC'

config timeserver 'ntp'
	list server '0.openwrt.pool.ntp.org'
	list server '1.openwrt.pool.ntp.org'
	list server '2.openwrt.pool.ntp.org'
	list server '3.openwrt.pool.ntp.org'
	option enable_server '0'
EOF
}

openwrt_container_cleanup_rootfs() {
	rm -rf lib/modules/*
}


openwrt_generate_x86_container() {
	cd "$DIR_OPENWRT_TRUNK"/bin/x86

	rm -rf $DIR_CONAINER_WORKING 2>/dev/null
	mkdir $DIR_CONAINER_WORKING

	cd $DIR_CONAINER_WORKING

	tar axf "../openwrt-x86-generic-Generic-rootfs.tar.gz"
	
	openwrt_container_configure_inittab
	openwrt_container_configure_network
	openwrt_container_configure_system
	openwrt_container_cleanup_rootfs

	cd ..

	cp $DIR_THIS_FILE/lxc/template_config config
	tar cf openwrt-x86-lxc-rootfs.tar $DIR_CONAINER_WORKING config
	rm config
}

openwrt_generate_ar71xx_container() {
	cd "$DIR_OPENWRT_TRUNK"/bin/ar71xx

	rm -rf $DIR_CONAINER_WORKING 2>/dev/null
	mkdir $DIR_CONAINER_WORKING

	cd $DIR_CONAINER_WORKING

	tar axf "../openwrt-ar71xx-generic-Default-rootfs.tar.gz"
	
	openwrt_container_configure_inittab
	openwrt_container_configure_network
	openwrt_container_configure_system
	openwrt_container_cleanup_rootfs

	cd ..

	cp $DIR_THIS_FILE/lxc/template_config config
	tar cf openwrt-ar71xx-lxc-rootfs.tar $DIR_CONAINER_WORKING config
	rm config
}

openwrt_generate_x86_container
openwrt_generate_ar71xx_container
