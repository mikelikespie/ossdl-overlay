# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdrtools/cdrtools-2.01.01_alpha11.ebuild,v 1.2 2006/09/05 16:45:43 metalgod Exp $

inherit eutils gnuconfig toolchain-funcs flag-o-matic

MY_CRYPT_VERS="${PV/_alpha/a}-encrypt-1.0"

DESCRIPTION="A set of tools for CD/DVD reading and recording, including cdrecord"
HOMEPAGE="http://cdrecord.berlios.de/"
SRC_URI="ftp://ftp.berlios.de/pub/cdrecord/alpha/${P/_alpha/a}.tar.bz2
	on-the-fly-crypt? ( http://burbon04.gmxhome.de/linux/files/${PN}-${MY_CRYPT_VERS}.diff.gz )"

LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="on-the-fly-crypt unicode"

DEPEND="virtual/libc
	!app-cdr/dvdrtools
	!app-cdr/cdrkit"

PROVIDE="virtual/cdrtools"

S=${WORKDIR}/${PN}-2.01.01

src_unpack() {
	unpack ${A}
	cd "${S}"

	# CAN-2004-0806 - Bug 63187
	epatch "${FILESDIR}"/${PN}-2.01-scsi-remote.patch
	epatch "${FILESDIR}"/${PN}-2.01a27-writemode.patch
	epatch "${FILESDIR}"/${PN}-2.01.01a03-warnings.patch
	epatch "${FILESDIR}"/${PN}-2.01.01a01-scanbus.patch
	epatch "${FILESDIR}"/${PN}-2.01.01a03-rezero.patch

	# Add support for On-The-Fly AES encryption
	# http://burbon04.gmxhome.de/linux/CDREncryption.html
	if use on-the-fly-crypt; then
		epatch ${DISTDIR}/${PN}-${MY_CRYPT_VERS}.diff.gz || die "Can't apply encryption patch"
	fi

	# ppc-macos support
	cd "${S}"/DEFAULTS
	use ppc-macos && MYARCH="mac-os10" || MYARCH="linux"

	sed -i "s:/opt/schily:/usr:g" Defaults.${MYARCH}
	sed -i "s:/usr/src/linux/include::g" Defaults.${MYARCH}

	cd "${S}"/librscg
	sed -i "s:/opt/schily:/usr:g" scsi-remote.c

	cd "${S}"/RULES
	ln -sf i386-linux-cc.rul x86_64-linux-cc.rul
	ln -sf i386-linux-gcc.rul x86_64-linux-gcc.rul
	ln -sf ppc-linux-cc.rul ppc64-linux-cc.rul
	ln -sf mips-linux-cc.rul mips64-linux-cc.rul
	ln -sf i586-linux-cc.rul sh4-linux-cc.rul
}

src_compile() {
	gnuconfig_update

	if use unicode; then
		local flags="$(test-flags -finput-charset=ISO-8859-1 -fexec-charset=UTF-8)"
		if [[ -n ${flags} ]]; then
			append-flags ${flags}
		else
			ewarn "Your compiler does not support the options required to build"
			ewarn "cdrtools with unicode in USE. unicode flag will be ignored."
		fi
	fi
	emake CC="$(tc-getCC) -D__attribute_const__=const" COPTX="${CFLAGS}" CPPOPTX="${CPPFLAGS}" LDOPTX="${LDFLAGS}" || die
}

src_install() {
	dobin cdda2wav/OBJ/*-*-cc/cdda2wav || die "cdda2wav"
	dobin cdrecord/OBJ/*-*-cc/cdrecord  || die "cdrecord"
	dobin mkisofs/OBJ/*-*-cc/mkisofs || die "mkisofs"
	dobin readcd/OBJ/*-*-cc/readcd || die "readcd"
	dosbin rscsi/OBJ/*-*-cc/rscsi || die "rscsi"

	insinto /usr/include
	doins incs/*-*-cc/align.h incs/*-*-cc/avoffset.h incs/*-*-cc/xconfig.h || die "include"

	cd mkisofs/diag/OBJ/*-*-cc
	dobin devdump isodump isoinfo isovfy || die "dobin"

	cd "${S}"
	insinto /etc/default
	doins rscsi/rscsi.dfl
	doins cdrecord/cdrecord.dfl

	cd "${S}"/libs/*-*-cc
	dolib.a *.a || die "dolib failed"

	cd "${S}"
	insinto /usr/include/scsilib
	doins include/*.h
	insinto /usr/include/scsilib/scg
	doins include/scg/*.h

	cd "${S}"
	dodoc ABOUT Changelog README README.{ATAPI,audio,cdplus,cdrw,cdtext,clone,copy,DiskT@2,linux-shm,multi,parallel,raw,rscsi,sony,verify} START READMEs/README.linux
	doman */*.1
	doman */*.8

	cd "${S}"/doc
	docinto print
	dodoc *.ps
}

pkg_postinst() {
	if use ppc-macos ; then
		einfo
		einfo "Darwin/OS X use the following device names:"
		einfo
		einfo "CD burners: (probably) ./cdrecord dev=IOCompactDiscServices"
		einfo
		einfo "DVD burners: (probably) ./cdrecord dev=IODVDServices"
		einfo
	else
	echo
	einfo "The command line option 'dev=/dev/hdX' (X is the name of your drive)"
	einfo "should be used for IDE CD writers.  And make sure that the permissions"
	einfo "on this device are set properly and your user is in the correct group."
	fi
}
