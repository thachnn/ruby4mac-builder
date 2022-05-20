#!/bin/bash
set -xe

_LIB="$1"
_RPATH="${2:-$(dirname "$_LIB")}"

install_name_tool -id "@rpath/$(otool -XD "$_LIB" | sed "s:$_RPATH/::")" "$_LIB"

_DEPS="$(otool -XL "$_LIB" | grep "$_RPATH/" | sed -e $'s/^[ \t]*//;s/ (.*)$//')"
for f in $_DEPS ; do
  install_name_tool -change "$f" "@rpath/$(basename "$f")" "$_LIB"
done

[[ -z "$_DEPS" ]] || install_name_tool -add_rpath '@loader_path' "$_LIB"

# Verifying
otool -l "$_LIB" | grep -i -A3 path
