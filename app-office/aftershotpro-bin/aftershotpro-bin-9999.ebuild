# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm xdg-utils

DESCRIPTION="A commercial and proprietary raw image processing software by Corel, free trial"
HOMEPAGE="https://www.aftershotpro.com/en/"
SRC_URI="http://dwnld.aftershotpro.com/trials/3/AfterShotPro3.rpm"

LICENSE="Corel-EULA"
SLOT="0"
# https://security.gentoo.org/glsa/200612-15
KEYWORDS=""
IUSE=""
RESTRICT="mirror"

DEPEND=""
RDEPEND="=media-libs/gst-plugins-base-0.10*"

QA_PREBUILT="opt/* bin/*"

pkg_pretend()
{
	ewarn "This package has security errors!"
	ewarn "See https://security.gentoo.org/glsa/200612-15"
}

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	rpm_src_unpack "${A}"
}

src_install() {
	cd "${S}" || die
	mv * "${D}"
}

pkg_postinst() {
	xdg_desktop_database_update
}
