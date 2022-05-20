#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_VER="${5:-8.1.2}"
_PKG="readline-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_UNIVERSAL="$3"
_RPATH="$4"

if [[ ! -e "$_PREFIX/lib/libreadline.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/readline/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  # Build options
  [[ "$_UNIVERSAL" != 1 ]] || _FLAGS='-arch i386 -arch x86_64'

  cd "$_PKG"
  ./configure "--prefix=$_PREFIX" --disable-static --disable-install-examples \
    "CFLAGS=-O2 $_FLAGS" "LDFLAGS=$_FLAGS"

  # There is no termcap.pc in the base system
  sed -i- 's/^Requires\.private:/# &/' readline.pc

  # Disable documents & `history` library
  sed -i- -e 's/ install-doc / /;/(man3dir) .*(docdir)/d' Makefile
  sed -i- -e '/mkdirs .*(bindir)/d;/shlib-install .*(SHARED_HISTORY)$/d' \
    -e 's/^\(SHARED_LIBS *=.*\) \$(SHARED_HISTORY)/\1/' shlib/Makefile

  make -j2 V=1 install

  [[ "$_RPATH" != 1 ]] || "$_SC_DIR/change_to_rpath.sh" "$_PREFIX/lib/libreadline.dylib"
fi
