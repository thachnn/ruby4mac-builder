#!/bin/bash
set -xe

_LIB="$1"
_RPATH="${2:-$(dirname "$_LIB")}"
_LDPATH="${3:-@loader_path}"

# Library rpath ID
_FNAME="$(basename "$_LIB")"
[[ "$_FNAME" != *.* || -z "${_ID=$(otool -XD "$_LIB")}" ]] || \
  install_name_tool -id "@rpath/$(basename "$_ID")" "$_LIB"

# Change linked paths
_DEPS="$(otool -XL "$_LIB" | grep "$_RPATH/" | sed -e $'s/^[ \t]*//;s/ (.*)$//')"
for f in $_DEPS ; do
  install_name_tool -change "$f" "@rpath/$(basename "$f")" "$_LIB"
done

# Cleanup rpath
while [[ -n "$(otool -l "$_LIB" | grep -A5 LC_RPATH | grep "$_RPATH ")" ]]; do
  install_name_tool -delete_rpath "$_RPATH" "$_LIB"
done

# Add LC_RPATH
if [[ -n "$_DEPS" ]]; then
  if [[ "$_FNAME" == *.* ]]; then
    install_name_tool -add_rpath "$_LDPATH" "$_LIB"
  else
    install_name_tool -add_rpath '@executable_path/../lib' "$_LIB"
  fi
fi

# Verifying
otool -l "$_LIB" | grep -i -A3 path
