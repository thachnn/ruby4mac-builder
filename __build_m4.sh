#!/bin/bash
set -xe

[[ "${3:-1}" == 1 ]] && _VER=1.4.19 || _VER="$3"
_PKG="m4-$_VER"
_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-..}"
_NO_TESTS="$4"

if [[ ! -x "$_PREFIX/bin/m4" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.xz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/m4/$_PKG.tar.xz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.xz"

  cd "$_PKG"
  # Patch tests
  [[ "$USER" == root ]] || mv -f checks/198.sysval checks/198-sysval

  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" \
    "CFLAGS=${CFLAGS:+$CFLAGS }-O2"

  # Disable examples
  sed -i- 's/^\(SUBDIRS *=.*\) examples/\1/' Makefile
  [[ "$_NO_TESTS" == 0 ]] || \
    sed -i '' 's/\(SUBDIRS *=.*\) checks\(.*\) tests$/\1\2/' Makefile

  make -j2 V=1
  make install
  [[ "$_NO_TESTS" != 0 ]] || make check
fi
