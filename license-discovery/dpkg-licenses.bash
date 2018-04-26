#!/usr/bin/env bash

# credit: https://github.com/daald/dpkg-licenses
# license: GPL 3

set -e

case "$1" in
  --help|-h)
    cat >&2 <<.e
Lists all installed packages (dpkg -l similar format) and prints their licenses

Usage: $0
.e
    exit 1
esac

SCRIPTLIB=$(dirname $(readlink -f "$0"))/lib/
test -d "$SCRIPTLIB"

format='%-2s\t  %-30s\t %-30s\t %-6s\t %-60s\t %s\t %s\t %s\n'
printf "$format" "St" "Name" "Version" "Arch" "Description" "HomePage" "Licenses" "LicenseText"
printf "$format" "--" "----" "-------" "----" "-----------" "--------" "--------" "-----------"

COLUMNS=2000 dpkg -l | grep '^.[iufhwt]' | while read pState package pVer pArch pDesc; do
  license=
  for method in "$SCRIPTLIB"/reader*; do
    [ -f "$method" ] || continue
    license=$("$method" "$package")
    [ $? -eq 0 ] || exit 1
    package_name=$( echo $package | sed  's/:.*//g')
    licensetext=$(cat /usr/share/doc/$package_name/copyright | tr -d '\n' | tr -d '"' | tr -d '\t' )
    [ -n "$license" ] || continue
    [ -n "$licensetext" ] || continue
    # remove line breaks and spaces
    license=$(echo "$license" | tr '\n' ' ' | sed -r -e 's/ +/ /g' -e 's/^ +//' -e 's/ +$//')
    #licensetext=$(echo "$licensetext" | tr '\r' ' ' | tr '\n' ' ' | sed -r -e 's/ +/ /g' -e 's/^ +//' -e 's/ +$//')
    [ -z "$license" ] || break
    [ -z "$licensetext" ] || break
  done
  [ -n "$license" ] || license='unknown'
  homepage=$(apt show $package 2>/dev/null | grep Homepage | awk '{ print $2 }')
  [ -n "$homepage" ] || homepage='unknown'
  printf "$format" "$pState" "${package:0:30}" "${pVer:0:30}" "${pArch:0:6}" "${pDesc:0:60}" "$homepage" "$license" "$licensetext"
done
