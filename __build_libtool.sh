#!/bin/bash
set -xe

_VER="${3:-2.4.7}"
_PKG="libtool-$_VER"
_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-..}"
_NO_TESTS="$4"

if [[ ! -x "$_PREFIX/bin/glibtool" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.xz" ]] || curl -OkfSL "https://ftp.gnu.org/gnu/libtool/$_PKG.tar.xz"
  rm -rf "$_PKG"
  COPYFILE_DISABLE=1 tar -xf "$_PKG.tar.xz"

  cd "$_PKG"
  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" --enable-ltdl-install \
    --program-prefix=g "CFLAGS=${CFLAGS:+$CFLAGS }-O2"

  make -j2 V=1 install
  [[ "$_NO_TESTS" != 0 ]] || make check || true

  mkdir -p "$_PREFIX/libexec"/{gnubin,gnuman/man1}
  for prog in libtool libtoolize; do
    ln -s "../../bin/g$prog" "$_PREFIX/libexec/gnubin/$prog"
    ln -s "../../../share/man/man1/g$prog.1" "$_PREFIX/libexec/gnuman/man1/$prog.1"
  done
  ln -sfh gnuman "$_PREFIX/libexec/man"
fi
