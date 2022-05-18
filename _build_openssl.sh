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
  perl Configure darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 "--prefix=$_PREFIX" \
    "--openssldir=$_PREFIX/etc/openssl" shared enable-static-engine no-tests

  # Build lib only
  # TODO: sed -i- 's,^LIBS=apps/libapps\.a ,LIBS=,' Makefile
  make -j2 install_dev install_engines
fi
