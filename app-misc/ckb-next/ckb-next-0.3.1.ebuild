# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils kde5-functions linux-info systemd

DESCRIPTION="Open source driver for Corsair keyboards and mice"
HOMEPAGE="https://github.com/ckb-next/ckb-next"
SRC_URI="https://github.com/ckb-next/ckb-next/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

ANIMATIONS=( gradient heatmap rain random pinwheel ripple wave )
ANIMATIONS_USE=( ${ANIMATIONS[@]/#/animations_} )
IUSE="+animations +mviz +qt5 system-quazip ${ANIMATIONS_USE[@]/#/+}"
REQUIRED_USE="
	animations? ( qt5 )
	${ANIMATIONS_USE[@]/%/? ( animations )}
"
RESTRICT="mirror"

DOCS=( CHANGELOG.md README.md )

CONFIG_CHECK="~INPUT_UINPUT"
ERROR_INPUT_UINPUT="${PN}-daemon requires support for User level driver support (INPUT_UINPUT) - this can be enabled in 'Device Drivers -> Input device support -> Miscellaneous devices -> User level driver support'"

RDEPEND="
	!!app-misc/ckb
	qt5? (
		$(add_qt_dep qtwidgets)
		$(add_qt_dep qtnetwork)
	)
"
DEPEND="${RDEPEND}
	$(add_qt_dep qtcore)
	system-quazip? ( dev-libs/quazip )
"

pkg_setup() {
	linux-info_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/udev-dest.patch"
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_ANIMATIONS="$(usex animations)"
		-DWITH_MVIZ="$(usex mviz)"
		-DWITH_GUI="$(usex qt5)"
		-DWITH_SHIPPED_QUAZIP="$(usex system-quazip no yes)"
		-DWITH_GRADIENT="$(usex animations_gradient)"
		-DWITH_HEAT="$(usex animations_heatmap)"
		-DWITH_RAIN="$(usex animations_rain)"
		-DWITH_RANDOM="$(usex animations_random)"
		-DWITH_PINWHEEL="$(usex animations_pinwheel)"
		-DWITH_RIPPLE="$(usex animations_ripple)"
		-DWITH_WAVE="$(usex animations_wave)"
	)
	cmake-utils_src_configure
}
