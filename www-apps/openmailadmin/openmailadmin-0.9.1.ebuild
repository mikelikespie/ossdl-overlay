# Copyright 2006 Ossdl.de, Hurrikane Systems
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils webapp

DESCRIPTION="Administration interface for mailservers based on Cyrus and any MTA."
SRC_URI="http://static.openmailadmin.org/downloads/openmailadmin-20060109-0.9.1.tbz2"
HOMEPAGE="http://www.openmailadmin.org/"
RESTRICT=primaryuri,mirror

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="mysql mysqli sqlite sqlite3 postgres pam"

DEPEND="
        pam? ( || (
                mysql?          ( >=sys-auth/pam_mysql-0.5 )
                mysqli?         ( >=sys-auth/pam_mysql-0.5 )
                postgres?       ( >=sys-auth/libnss-pgsql-1.0.0 )
        ))
        "
RDEPEND="${DEPEND}
	virtual/httpd-php
	>=dev-lang/php-4.3.0
	dev-php/adodb
	virtual/mta
	<net-mail/cyrus-imapd-2.3.0
	|| (
		mysqli?		( >=dev-db/mysql-4.1.14 )
		mysql?		( >=dev-db/mysql-4.1.0 )
		postgres?	( dev-db/postgresql )
		sqlite3?	( =dev-db/sqlite-3* )
		sqlite?		( =dev-db/sqlite-2* )
	)
	pam?		( sys-auth/pam_pwdfile )
	!www-apps/web-cyradm
	"

src_install() {
	webapp_srv_preinst

	cp -R * ${D}/${MY_HTDOCSDIR}
	dodoc INSTALL
	dosbin samples/oma_mail.daimon.php
	webapp_serverowned inc
	
	webapp_postinst_txt en ${FILESDIR}/postinstall-en.txt
	webapp_src_install	
}