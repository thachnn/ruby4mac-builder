#!/bin/bash
set -xe

_VER="${3:-2.7.5}"
_PKG="ruby-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_EXTRA_ARGS="$4"
_NO_TESTS="$5"

cd "$_SCRATCH_DIR"
[[ -s "$_PKG.tar.xz" ]] || \
  curl -OkfSL "https://cache.ruby-lang.org/pub/ruby/${_VER%.*}/$_PKG.tar.xz"
rm -rf "$_PKG"
tar -xf "$_PKG.tar.xz"

cd "$_PKG"
./configure "--prefix=$_PREFIX" --enable-shared "--with-opt-dir=$_PREFIX" \
  $_EXTRA_ARGS CFLAGS=-O2

# TODO: sed -i- "s: -L$_PREFIX/lib\$: -L\${libdir}:" *.pc

make -j2 V=1
make install

# Cleanup the built
