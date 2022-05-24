#!/bin/bash
set -xe

_VER="${3:-0.29.2}"
_PKG="pkg-config-$_VER"
_PREFIX="${1:-/usr/local}"
_SCRATCH_DIR="${2:-..}"
_NO_TESTS="$4"
_BREW_PC="$5"

if [[ ! -x "$_PREFIX/bin/pkg-config" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "http://fresh-center.net/linux/misc/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  pc_path="$(awk '0==x[$0]++' <<< "$_PREFIX/lib/pkgconfig
$_PREFIX/share/pkgconfig
/usr/local/lib/pkgconfig
/usr/lib/pkgconfig" | tr "\n" ':' | sed 's/:$//')"

  inc_path="$(find -L /Applications/Xcode.app/Contents/Developer \
    /Library/Developer/CommandLineTools -regex '.*/SDKs/MacOSX[^/]*\.sdk/usr/include' \
    2> /dev/null | tr "\n" ':')/usr/include"

  cd "$_PKG"
  ./configure --disable-dependency-tracking "--prefix=$_PREFIX" --disable-host-tool \
    "--with-pc-path=$pc_path" "--with-system-include-path=$inc_path" \
    --with-internal-glib --enable-debug=no "CFLAGS=${CFLAGS:+$CFLAGS }-O2"

  make -j2 V=1
  make install
  [[ "$_NO_TESTS" != 0 ]] || make check

  if [[ "$_BREW_PC" == 1 ]]; then
    cd ..
    [[ -s brew-master.tgz ]] || \
      curl -o brew-master.tgz -kfSL https://github.com/Homebrew/brew/archive/master.tar.gz

    mkdir -p "$_PREFIX/share/pkgconfig"
    tar -C "$_PREFIX/share/pkgconfig" -xvf brew-master.tgz --strip-components=7 \
      "brew-master/Library/Homebrew/os/mac/pkgconfig/$(sw_vers -productVersion | cut -d. -f1-2)"
  fi
fi
