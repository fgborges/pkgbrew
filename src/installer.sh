#!/bin/sh

set -xe

#?include src/config.sh
#?include src/download.sh

main(){
    
    if [ -d "${PKGHOME}" ]; then
	echo pkgbrew already installed
	exit 1
    fi
	
    workdir=`mktemp -d`

    download "${PKGHOST}" "-" | tar xz --directory "${workdir}"

    prev="${SH}"
    export SH="/bin/bash"
    ${workdir}/pkgsrc-trunk/bootstrap/bootstrap        \
	--ignore-user-check                            \
	--workdir="${workdir}/work"                    \
	--make-jobs=`grep -c ^processor /proc/cpuinfo` \
	--prefix="${PKGHOME}" | awk "
#?include src/filter.awk
"
    export SH="${prev}"

    mv "${workdir}/pkgsrc-trunk" "${PKGSRC}"

    download "${PKGBREW}" "${PKGHOME}/bin/pkgbrew"
    chmod +x "${PKGHOME}/bin/pkgbrew"

    cat<<EOF > "${PKGHOME}/etc/mk.conf"
#?include src/mk.conf.tpl
EOF
}

main
