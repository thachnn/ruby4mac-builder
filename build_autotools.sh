#!/bin/bash
set -xe
_SC_DIR="$(dirname "$0")"

_PREFIX=/usr/local
_SCRATCH_DIR="$(cd "$_SC_DIR/.."; pwd)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --prefix=*)
    _PREFIX="${1#*=}"
    ;;
  --scratch-path=*)
    _SCRATCH_DIR="${1#*=}"
    ;;
  --with-m4=*)
    _M4="${1#*=}"
    ;;
  --with-autoconf=*)
    _AUTOCONF="${1#*=}"
    ;;
  --with-automake=*)
    _AUTOMAKE="${1#*=}"
    ;;
  --with-libtool=*)
    _LIBTOOL="${1#*=}"
    ;;
  --unit-test)
    _NO_TESTS=0
    ;;
  --with-brew-pc)
    _BREW_PC=1
    ;;
  *)
    echo "Usage: $0 [--prefix=$_PREFIX] [--scratch-path=$_SCRATCH_DIR]"
    echo "            [--with-autoconf=] [--with-automake=] [--with-libtool=]"
    exit
    ;;
  esac
  shift
done

[[ ":$PATH:" == *":$_PREFIX/bin:"* ]] || export PATH="$_PREFIX/bin:$PATH"
"$_SC_DIR/__build_pkgconfig.sh" "$_PREFIX" "$_SCRATCH_DIR" '' "$_NO_TESTS" "$_BREW_PC"

[[ -z "$_M4" ]] || "$_SC_DIR/__build_m4.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_M4" "$_NO_TESTS"
"$_SC_DIR/__build_autoconf.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_AUTOCONF" "$_NO_TESTS"
"$_SC_DIR/__build_automake.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_AUTOMAKE" "$_NO_TESTS"
"$_SC_DIR/__build_libtool.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_LIBTOOL" "$_NO_TESTS"
