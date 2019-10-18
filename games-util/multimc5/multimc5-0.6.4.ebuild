# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils kde5-functions

DESCRIPTION="An advanced open-source launcher for Minecraft written in Qt5"
HOMEPAGE="https://multimc.org/"
# upstream versioning is yuckers
LIBNBTXX_PN="libnbtplusplus"
LIBNBTXX_PV="multimc-0.6.1"
LIBNBTXX_P="${LIBNBTXX_PN}-${LIBNBTXX_PV}"
QUAZIP_PN="quazip"
QUAZIP_PV="multimc-3"
QUAZIP_P="${QUAZIP_PN}-${QUAZIP_PV}"
SRC_URI="
	https://github.com/MultiMC/MultiMC5/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/MultiMC/libnbtplusplus/archive/${LIBNBTXX_PV}.tar.gz -> ${LIBNBTXX_P}.tar.gz
	https://github.com/MultiMC/quazip/archive/${QUAZIP_PV}.tar.gz -> ${QUAZIP_P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

DOCS=( changelog.md README.md )

COMMON_DEPEND="
	$(add_qt_dep qtconcurrent)
	$(add_qt_dep qtcore)
	$(add_qt_dep qtgui)[png]
	$(add_qt_dep qtnetwork)
	$(add_qt_dep qttest)
	$(add_qt_dep qtwidgets)[png]
	$(add_qt_dep qtxml)
"
DEPEND="
	${COMMON_DEPEND}
	virtual/jdk
"
RDEPEND="
	${COMMON_DEPEND}
	virtual/jre
	virtual/opengl
"

src_unpack() {
	mkdir -p "${S}" || die
	tar -C "${S}" -x --strip-components 1 -f "${DISTDIR}/${P}.tar.gz" || die
	tar -C "${S}/libraries/libnbtplusplus" -x --strip-components 1 -f "${DISTDIR}/${LIBNBTXX_P}.tar.gz" || die
	tar -C "${S}/libraries/quazip" -x --strip-components 1 -f "${DISTDIR}/${QUAZIP_P}.tar.gz" || die
}

src_prepare() {
	#epatch "${FILESDIR}/fortify-fix.patch"
	#epatch "${FILESDIR}/fix-qt11.patch"
	cd "${S}/libraries/quazip" || die
	epatch "${FILESDIR}/fix-qt11-quazip.patch"
	cd -
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DMultiMC_LAYOUT=lin-system
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${D}/usr/share/pixmaps" "${D}/usr/share/applications" || die
	cp "${S}/application/resources/multimc/scalable/multimc.svg" "${D}/usr/share/pixmaps/multimc5.svg" || die
	cp "${FILESDIR}/multimc5.desktop" "${D}/usr/share/applications/multimc5.desktop" || die
}
