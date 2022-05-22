#!/bin/bash
set -xe
_SC_DIR="$(cd "`dirname "$0"`"; pwd)"

_VER="${5:-1.1.1l}"
_PKG="openssl-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"
_UNIVERSAL="$3"
_RPATH="$4"

if [[ "$_VER" == 0 ]]
then
  . "$_SC_DIR/_use_libressl.sh"
elif [[ ! -e "$_PREFIX/lib/libssl.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "https://ftp.openssl.org/source/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  # Fix CommonRandom.h error on old macOS
  sed -i '' $'s|^\\(# *include <CommonCrypto/Common\\)Random.h>|\\1CryptoError.h>\\\n&|' \
    crypto/rand/rand_unix.c

  # Disable static libraries
  sed -i- -e 's/^\(INSTALL_LIBS *=\).*/\1/;s/mv -f Makefile\.new Makefile/& || true/' \
    Configurations/unix-Makefile.tmpl

  [[ "$_RPATH" == 1 ]] && _SSLDIR=/etc/ssl || _SSLDIR="$_PREFIX/etc/openssl"
  # enable-ec_nistp_64_gcc_128
  perl Configure "--prefix=$_PREFIX" "--openssldir=$_SSLDIR" enable-static-engine \
    shared darwin64-x86_64-cc
  make -j2 install_dev install_engines

  rmdir "$_PREFIX"/lib/engines-*

  if [[ "$_UNIVERSAL" == 1 ]]; then
    make clean

    perl Configure "--prefix=$_PREFIX" "--openssldir=$_SSLDIR" enable-static-engine \
      shared darwin-i386-cc
    make -j2 install_dev install_engines "DESTDIR=$_PREFIX/tmp"

    # Patch headers for universal arch
    sed -i '' "s/ THIRTY_TWO_BIT$/&\\
#if defined(__i386__) || defined(__i386)\\
$(grep -e ' BN_LLONG\| SIXTY_FOUR_BIT\| THIRTY_TWO_BIT' \
    "$_PREFIX/tmp$_PREFIX/include/openssl/opensslconf.h" | sed 's/$/\\/')
#endif/" "$_PREFIX/include/openssl/opensslconf.h"

    # Merge libraries
    for f in "$_PREFIX"/lib/lib{crypto,ssl}.*.dylib ; do
      lipo -create "$_PREFIX/tmp$f" "$f" -output "$f"
    done

    diff -u "$_PREFIX/include/openssl" "$_PREFIX/tmp$_PREFIX/include/openssl" || true
    rm -rf "$_PREFIX/tmp"
  fi

  if [[ "$_RPATH" == 1 ]]; then
    "$_SC_DIR/change_to_rpath.sh" "$_PREFIX/lib/libcrypto.dylib"
    "$_SC_DIR/change_to_rpath.sh" "$_PREFIX/lib/libssl.dylib"
  fi
fi
