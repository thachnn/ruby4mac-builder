#!/bin/bash
set -xe

_VER="${3:-1.1.1l}"
_PKG="openssl-$_VER"
_PREFIX="$1"
_SCRATCH_DIR="$2"

if [[ ! -e "$_PREFIX/lib/libssl.dylib" ]]
then
  cd "$_SCRATCH_DIR"
  [[ -s "$_PKG.tar.gz" ]] || curl -OkfSL "https://ftp.openssl.org/source/$_PKG.tar.gz"
  rm -rf "$_PKG"
  tar -xf "$_PKG.tar.gz"

  cd "$_PKG"
  # Fix CommonRandom.h error on old macOS
  sed -i '' $'s|^\\(# *include <CommonCrypto/Common\\)Random.h>|\\1CryptoError.h>\\\n&|' \
    crypto/rand/rand_unix.c

  perl Configure darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 "--prefix=$_PREFIX" \
    "--openssldir=$_PREFIX/etc/openssl" shared enable-static-engine no-tests

  # Disable static libraries
  sed -i- -e 's/^\(LIBS *=\).*/\1/;s/^\(INSTALL_LIBS *=\).*/\1/' Makefile
  make -j2 install_dev install_engines

  rmdir "$_PREFIX"/lib/engines-*
fi
