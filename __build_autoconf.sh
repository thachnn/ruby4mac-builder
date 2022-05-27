#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_VER="${3:-2.71}"
_PKG="autoconf-$_VER"
_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-..}"
_NO_TESTS="$4"

if [[ ! -x "$_PREFIX/bin/autoconf" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/autoconf/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  # Apply patches
  [[ ! -s "$_SC_DIR/$_PKG.patch" ]] || patch -p1 -T -i "$_SC_DIR/$_PKG.patch"
  # Force autoreconf to look for and use our glibtoolize
  sed -i '' 's/libtoolize/glibtoolize/g' bin/autoreconf.in man/autoreconf.1

  ./configure "--prefix=$_PREFIX" "--with-lispdir=$_PREFIX/share/emacs/site-lisp/autoconf"
  make -j2 V=1 install
  [[ "$_NO_TESTS" != 0 ]] || make check || true

  rm -f "$_PREFIX/share/info/standards.info"
fi
