#!/bin/bash
set -xe

_VER="${3:-1.16.5}"
_PKG="automake-$_VER"
_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-..}"
_NO_TESTS="$4"

if [[ ! -x "$_PREFIX/bin/automake" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.xz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/automake/$_PKG.tar.xz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.xz"

  cd "$_PKG"
  ./configure "--prefix=$_PREFIX"

  make -j2 V=1 install
  [[ "$_NO_TESTS" != 0 ]] || make check

  # Our aclocal must go first
  echo "$_PREFIX/share/aclocal
/usr/local/share/aclocal
/usr/share/aclocal" | uniq > "$_PREFIX/share/aclocal/dirlist"

  cd "$_PREFIX/bin" && rm -f automake aclocal && \
    ln -s automake-* automake && ln -s aclocal-* aclocal
fi
