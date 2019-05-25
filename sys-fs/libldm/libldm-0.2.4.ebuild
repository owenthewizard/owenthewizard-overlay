# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools linux-info systemd

DESCRIPTION="A tool to manage Windows dynamic disks"
HOMEPAGE="https://github.com/mdbooth/libldm"
SRC_URI="https://github.com/mdbooth/${PN}/archive/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"
RESTRICT="mirror"

# lvm2 fore device-mapper
RDEPEND="
	>=dev-libs/glib-2.26.0
	>=dev-libs/json-glib-0.14.0
	sys-libs/readline
	sys-libs/zlib
	sys-apps/util-linux
	>=sys-fs/lvm2-1.02
"

DEPEND="
	${RDEPEND}
	dev-util/gtk-doc
"

CONFIG_CHECK="~MD_LINEAR ~DM_RAID"
ERROR_MD_LINEAR="${PN} requires support for Linear (append) mode (MD_LINEAR) - this can be enabled in 'Device Drivers -> Multiple devices driver support (RAID and LVM) -> Linear (append) mode'"
ERROR_DM_RAID="${PN} requires support for RAID 1/4/5/6/10 target (DM_RAID) - this can be enabled in 'Device Drivers -> Multiple devices driver support (RAID and LVM) -> RAID 1/4/5/6/10 target'"

pkg_setup() {
	linux-info_pkg_setup
}

src_unpack() {
	unpack "${A}"
	mv "${PN}-${P}" "${P}"
}

PATCHES=(
	"${FILESDIR}/0001-Gentoo-ignore-tests.patch"
#	"${FILESDIR}/0002-Gentoo-fix-incompatible-libdevmapper.patch"
)

src_prepare() {
	#eapply "${FILESDIR}/0001-Gentoo-ignore-tests.patch" || die
	sed -i -e 's/-Werror//g' src/Makefile.am || die
	eautoreconf || die
	default
}

src_install() {
	if use systemd; then
		systemd_dounit "${FILESDIR}/ldmtool.service"
	fi
	default
}
