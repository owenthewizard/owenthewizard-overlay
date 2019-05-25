# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson toolchain-funcs xdg-utils multilib-minimal

DESCRIPTION="Helper for enabling better Steam integration on Linux"
HOMEPAGE="https://github.com/clearlinux/linux-steam-integration"
SRC_URI="
	https://github.com/clearlinux/${PN}/releases/download/v${PV}/${P}.tar.xz
"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libressl +gtk patch +libintercept +libredirect"
RESTRICT="mirror"

DEPEND="
	gtk? ( x11-libs/gtk+:3[${MULTILIB_USEDEP}] )
"
RDEPEND="
	games-util/steam-launcher
	libintercept? ( media-libs/libsdl2[${MULTILIB_USEDEP}] )
"

DOCS=( README.md TECHNICAL.md )

multilib_src_configure() {
	use_new_libcxx() {
		if [[ $(gcc-major-version) -ge 6 ]]; then
			echo "true"
		else
			echo "false"
		fi
	}

	local emesonargs=(
		-Dwith-libressl-mode=$(usex libressl native none)
		-Dwith-shim=co-exist
		-Dwith-new-libcxx-abi=$(use_new_libcxx)
		$(meson_use gtk with-frontend)
		$(meson_use libintercept with-libintercept)
		$(meson_use libredirect with-libredirect)
		-Dwith-snap-support=false
		-Dwith-steam-binary="${EPREFIX}/usr/bin/steam" # should match steam-launcher from RDEPEND
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

src_install() {
	if use patch; then
		insinto /etc/portage/patches/sys-libs/glibc
		doins "${FILESDIR}/9999-Solus-audit-profiling-performance.patch"
	fi

	multilib_foreach_abi meson_src_install
}

pkg_postinst() {
	if use libintercept && ! use patch; then
		ewarn "There is a glibc bug that leads to a performance hit when using liblsi-intercept"
		ewarn "You may want to re-emerge this with +patch and then rebuild glibc"
		ewarn "For more info see https://github.com/clearlinux/linux-steam-integration/blob/master/TECHNICAL.md#common-issues"
	fi

	if use patch; then
		elog "9999-Solus-audit-profiling-performance.patch has been installed to /etc/portage/patches,"
		elog "You may want to rebuild glibc"
	fi

	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
