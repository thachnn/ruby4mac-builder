#!/bin/bash
set -xe
_SC_DIR="$(dirname "$0")"

_PREFIX=/usr/local
_SCRATCH_DIR="$(cd "$_SC_DIR/.."; pwd)"
_EXTRA_ARGS='--without-gmp --disable-install-rdoc'

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --prefix=*)
    _PREFIX="${1#*=}"
    ;;
  --scratch-path=*)
    _SCRATCH_DIR="${1#*=}"
    ;;
  --version=*)
    _VERSION="${1#*=}"
    ;;
  --with-openssl=*)
    _OPENSSL="${1#*=}"
    ;;
  --without-openssl)
    _OPENSSL=0
    ;;
  --with-readline=*)
    _READLINE="${1#*=}"
    ;;
  --without-readline)
    _READLINE=0
    ;;
  --with-gdbm=*)
    _GDBM="${1#*=}"
    ;;
  --extra-opts=*)
    _EXTRA_ARGS="$_EXTRA_ARGS ${1#*=}"
    ;;
  --unit-test)
    _NO_TESTS=0
    ;;
  *)
    echo "Usage: $0 [--version=] [--prefix=$_PREFIX] [--with-openssl=|--without-openssl]"
    echo "            [--with-readline=|--without-readline] [--with-gdbm=] [--unit-test]"
    exit
    ;;
  esac
  shift
done

# Build dependencies
"$_SC_DIR/_build_openssl.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_OPENSSL"
"$_SC_DIR/_build_libyaml.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_NO_TESTS"
"$_SC_DIR/_build_readline.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_READLINE"

[[ -z "$_GDBM" ]] && _EXTRA_ARGS="$_EXTRA_ARGS --without-gdbm" || \
  "$_SC_DIR/_build_gdbm.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_GDBM"


"$_SC_DIR/_build_ruby.sh" "$_PREFIX" "$_SCRATCH_DIR" "$_VERSION" "$_EXTRA_ARGS" "$_NO_TESTS"
