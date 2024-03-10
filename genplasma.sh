#!/bin/bash

basedir="$HOME/genkde/kf6"
version=6.0.0

cd "$basedir" || exit

curl -s "https://download.kde.org/stable/plasma/$version/" | grep "tar.xz" | cut -d">" -f9 | cut -d"<" -f1  | grep "tar.xz$" | sed "s|-$version.tar.xz||" > "$basedir/plasma.txt"

while read -r port; do
	mkdir "$port"
	cat <<- EOF > "$port/Pkgfile"
# Description: @DESC@
# URL: @URL@
# Maintainer: Tsaop, leeroy at cock dot li
# Depends on:

name=$port
version=$version
release=1
source=(https://download.kde.org/stable/plasma/\$version/\$name-\$version.tar.xz)

build() {
\tcd \$name-\$version
\tcmake -Bbuild \\
\t\t-DCMAKE_INSTALL_PREFIX=/usr \\
\t\t-DCMAKE_INSTALL_LIBDIR=lib \\
\t\t-DBUILD_TESTING=OFF \\
\t\t-DBUILD_EXAMPLES=OFF

\tcmake --build build
\tDESTDIR=\$PKG cmake --install build
}
EOF

done < "$basedir/plasma.txt"

while read -r port; do
	desc=$(curl -s -L https://invent.kde.org/plasma/"$port" | grep "og:description" | cut -d"\"" -f2)
	sed -e "s|@DESC@|$desc|" "$port/Pkgfile" \
		-e "s|@URL@|https://invent.kde.org/plasma/$port|" \
		-i "$port/Pkgfile"

	sed -i 's|\\t|	|g' "$port/Pkgfile"

	[[ ! "$desc" ]] && echo "$port is empty!!!"
done < "$basedir/plasma.txt"
