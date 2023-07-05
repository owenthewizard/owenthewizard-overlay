# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake linux-info

DESCRIPTION="Open source driver for Corsair keyboards and mice"
HOMEPAGE="https://github.com/ckb-next/ckb-next"
SRC_URI="https://github.com/ckb-next/ckb-next/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+animations +mviz +qt5"
REQUIRED_USE="
	animations? ( qt5 )
"
RESTRICT="mirror"

DOCS=( CHANGELOG.md README.md )

CONFIG_CHECK="~INPUT_UINPUT"
ERROR_INPUT_UINPUT="${PN}-daemon requires support for User level driver support (INPUT_UINPUT) - this can be enabled in 'Device Drivers -> Input device support -> Miscellaneous devices -> User level driver support'"

RDEPEND="
	qt5? (
		dev-libs/libdbusmenu-qt
		>=dev-libs/quazip-1.0
		>=dev-qt/linguist-tools-5.5.1
		>=dev-qt/qtcore-5.5.1
		>=dev-qt/qtdbus-5.5.1
		>=dev-qt/qtgui-5.5.1
		>=dev-qt/qtnetwork-5.5.1
		>=dev-qt/qtwidgets-5.5.1
		>=dev-qt/qtx11extras-5.5.1
		media-libs/libpulse
		x11-libs/libxcb
		x11-libs/xcb-util-wm
	)
	virtual/udev
"

DEPEND="${RDEPEND}"

pkg_setup() {
	linux-info_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DDISABLE_UPDATER=1
		-DWITH_ANIMATIONS="$(usex animations)"
		-DWITH_MVIZ="$(usex mviz)"
		-DWITH_GUI="$(usex qt5)"
		-DWITH_GRADIENT="$(usex animations)"
		-DWITH_HEAT="$(usex animations)"
		-DWITH_RAIN="$(usex animations)"
		-DWITH_RANDOM="$(usex animations)"
		-DWITH_PINWHEEL="$(usex animations)"
		-DWITH_PIPE="$(usex animations)"
		-DWITH_RIPPLE="$(usex animations)"
		-DWITH_SNAKE="$(usex animations)"
		-DWITH_WAVE="$(usex animations)"
		-DWITH_INVADERS="$(usex animations)"
		-DWITH_LIFE="$(usex animations)"
	)
	cmake_src_configure
}

pkg_postinst() {
	local rVer
	for rVer in ${REPLACING_VERSIONS}; do
		if ver_test "$rVer" -lt 0.3.2; then
			ewarn "<app-misc/ckb-next-0.3.2 has a regression that may require reflashing mouse firmware"
			ewarn "For more information, see https://github.com/ckb-next/ckb-next/blob/master/CHANGELOG.md#v032-2018-10-07"
		fi
	done
}
