#!/bin/bash

find . -name Pkgfile | while read -r port; do
	deps=$(grep "Depends" "$port" | cut -d":" -f2)
	for i in $deps; do
		err=$(prt-get info "$i" 2>&1 | grep "not found")
		[[ $err ]] && echo -e "$err -> $port"
	done
done
