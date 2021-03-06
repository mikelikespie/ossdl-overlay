# Copyright 2010-2011 W-Mark Kubacki
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PYTHON_DEPEND="2:2.6:2.7"
EAPI=3

inherit distutils eutils

DESCRIPTION="A Python-Powered Static Site Generator"
HOMEPAGE="http://mark.ossdl.de/tags/thot"
SRC_URI="http://github.com/downloads/wmark/${PN}/${P}.tar.gz"
RESTRICT="primaryuri"

LICENSE="RPL-1.5"
SLOT="0"
KEYWORDS="amd64 x86 arm ppc hpa sparc"
IUSE=""

GITHUB_NAME="wmark-${PN}-4430cb4"
S="${WORKDIR}/${GITHUB_NAME}"

RDEPEND="dev-python/markdown
	dev-python/docutils
	dev-python/pygments
	>=dev-python/python-dateutil-1.5
	dev-python/pytz
	dev-python/pyyaml
	dev-python/murmur
	|| ( >=dev-python/mako-0.4.0 dev-python/jinja )"
DEPEND="${DEPEND}
	dev-python/setuptools
	"

src_prepare() {
	cd "${S}"
	sed -i -e 's:    data_files:#   data_files:g' setup.py
}

src_install() {
	distutils_src_install
	insinto "$(python_get_sitedir)"
	doins -r src/quickstart || die
}

pkg_postinst() {
	python_mod_optimize thot
}
