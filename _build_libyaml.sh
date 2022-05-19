#!/bin/bash
set -xe

_VER="${5:-0.2.5}"
_PKG="yaml-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_UNIVERSAL="$3"
_RPATH="$4"
_NO_TESTS="$6"

if [[ ! -e "$_PREFIX/lib/libyaml.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || \
    curl -OkfSL "https://github.com/yaml/libyaml/releases/download/$_VER/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  # Build options
  _CFLAGS=-O2
  [[ "$_UNIVERSAL" != 1 ]] || _CFLAGS="$_CFLAGS -arch i386 -arch x86_64"

  cd "$_PKG"
  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" --disable-static \
    "CFLAGS=$_CFLAGS"

  # Disable tests completely
  [[ "$_NO_TESTS" == 0 ]] || sed -i- 's/^\(SUBDIRS *=.*\) tests$/\1/' Makefile

  make -j2 V=1 install
  [[ "$_NO_TESTS" != 0 ]] || make check

  [[ "$_RPATH" != 1 ]] || install_name_tool -id \
    "$(otool -XD "$_PREFIX/lib/libyaml.dylib" | sed "s:$_PREFIX/lib/:@rpath/:")" \
    "$_PREFIX/lib/libyaml.dylib"
fi
