#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

[[ "${5:-1}" == 1 ]] && _VER=1.22 || _VER="$5"
_PKG="gdbm-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_UNIVERSAL="$3"
_RPATH="$4"
_NO_TESTS="$6"

if [[ ! -e "$_PREFIX/lib/libgdbm.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/gdbm/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  _CFLAGS=-O2
  [[ "$_UNIVERSAL" != 1 ]] || _CFLAGS="$_CFLAGS -arch i386 -arch x86_64"

  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" --disable-static \
    --without-readline --disable-libgdbm-compat "CFLAGS=$_CFLAGS"

  # Disable bin tools
  sed -i- 's/^\(bin_PROGRAMS *=\).*/\1/' src/Makefile
  sed -i- 's/\(SUBDIRS *=\).* src .* tests$/\1 src tests/' Makefile
  sed -i- 's/^gdbmtool /exit 77 || &/' tests/testsuite
  find tests -name Makefile -exec sed -i- 's/^\([A-Z_]* *=\) *gdbmtool/\1/' {} +

  [[ "$_NO_TESTS" == 0 ]] || sed -i '' 's/\(SUBDIRS *=.*\) tests$/\1/' Makefile
  make -j2 V=1 install
  [[ "$_NO_TESTS" != 0 ]] || make check

  [[ "$_RPATH" != 1 ]] || "$_SC_DIR/change_to_rpath.sh" "$_PREFIX/lib/libgdbm.dylib"
fi
