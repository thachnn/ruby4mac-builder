#!/bin/bash
set -xe

: "${_PREFIX:=$1}"
: "${_SCRATCH_DIR:=$2}"
: "${_UNIVERSAL:=$3}"

if [[ ! -e "$_PREFIX/lib/libssl.dylib" ]]
then
  # Use the latest OpenSSL/LibreSSL
  mkdir -p "$_PREFIX/lib"
  for i in crypto ssl ; do
    ln -s "$(ls -1 "/usr/lib/lib$i".*.dylib | tail -1)" "$_PREFIX/lib/lib$i.dylib"
  done

  _VER="$(strings "$_PREFIX/lib/libssl.dylib" | grep LibreSSL | sed 's/^[^0-9]*//')"
  if [[ -z "$_VER" ]]
  then
    test -n "$(find /Library/Developer/CommandLineTools -path '*/openssl/crypto.h' \
      -print -quit)"
  else
    _PKG="libressl-$_VER"

    # Install LibreSSL headers
    cd "$_SCRATCH_DIR"
    [[ -s "$_PKG.tar.gz" ]] || \
      curl -OkfSL "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/$_PKG.tar.gz"

    tar -C "$_PREFIX" -xf "$_PKG.tar.gz" --strip-components=1 --exclude='*Makefile.*' \
      "$_PKG/include/openssl"

    # Patch for universal arch
    if [[ "$_UNIVERSAL" == 1 ]]; then
      sed -i '' "s/ THIRTY_TWO_BIT$/&\\
#if defined(__i386__) || defined(__i386)\\
# define BN_LLONG\\
# undef SIXTY_FOUR_BIT_LONG\\
# undef SIXTY_FOUR_BIT\\
# define THIRTY_TWO_BIT\\
#endif/" "$_PREFIX/include/openssl/opensslconf.h"
    fi
  fi
fi
