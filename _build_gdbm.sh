#!/bin/bash
set -xe

_VER="${3:-1.22}"
_PKG="gdbm-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libgdbm.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/gdbm/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" --disable-static \
    --without-readline --disable-libgdbm-compat CFLAGS=-O2

  # Install lib only
  sed -i- 's/^\(SUBDIRS *=\).*/\1 src/' Makefile
  make -j2 V=1 install
fi
