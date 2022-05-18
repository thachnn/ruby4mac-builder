#!/bin/bash
set -xe

_PKG=yaml-0.2.5
_PREFIX="$1"
_SCRATCH_DIR="$2"
_NO_TESTS="$3"

if [[ ! -e "$_PREFIX/lib/libyaml.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || \
    curl -OkfSL "https://github.com/yaml/libyaml/releases/download/${_PKG#*-}/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" --disable-static CFLAGS=-O2

  # Disable tests completely
  [[ "$_NO_TESTS" == 0 ]] || sed -i- 's/^\(SUBDIRS *=.*\) tests$/\1/' Makefile

  make -j2 V=1 install
  [[ "$_NO_TESTS" != 0 ]] || make check
fi
