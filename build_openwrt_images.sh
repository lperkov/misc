#!/usr/bin/env sh
#
#  OpenWrt build automation script
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

DIR_OPENWRT_TRUNK="/opt/openwrt/trunk/"
DIR_THIS_FILE=`pwd`

openwrt_update() {
	cd $DIR_OPENWRT_TRUNK

	# get the latest OpenWrt source
	git pull

	# update and install packages from feeds
	perl scripts/feeds update -a
	perl scripts/feeds install -a

	cd $DIR_THIS_FILE
}

openwrt_build() {
	cd $DIR_OPENWRT_TRUNK

	rm -rf .config
	make defconfig
	make -j9

	cd $DIR_THIS_FILE
}

openwrt_update

# build images for all predifined defconfigs
for f in defconfigs/* ; do
	ln -sf "`pwd`/$f" ~/.openwrt/defconfig
	echo "building image for $f"
	openwrt_build
done 
