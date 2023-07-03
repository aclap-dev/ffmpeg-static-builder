#!/bin/bash

git_clean=1 # SEE README
MJ="j4" # For parallel compilation
dist_name="dist" # Where all binaries will be installed.

cd $(dirname "$0")

set -euo pipefail

source ./utils.sh

FFMPEG_PKG_CONFIG_PATH=""
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""

host_os=$(uname -s)
host_arch=$(uname -m)
cross_compiling=0
autotools_options=""
cmake_options=""

case $host_os in
  Linux)
    host_os="linux"
    ;;
  Darwin)
    host_os="mac"
    ;;
esac

host="${host_os}-${host_arch}"

case $host in
  "linux-x86_64" | "mac-x86_64" | "mac-arm64")
    ;;
  *)
    echo "Unsupported build platform"
    exit 1
    ;;
esac

if [ $# -eq 0 ]; then
  target_os=$host_os
  target_arch=$host_arch
else
  case $1 in
    linux-x86_64 | \
    linux-i686 | \
    windows-x86_64 | \
    windows-i686 | \
    mac-x86_64 | \
    mac-arm64)
    cross_compiling=1
        ;;
    *)
      echo "Unsupported target: $1"
      exit 1
      ;;
  esac

  target_os=$(echo $1 | cut -f1 -d-)
  target_arch=$(echo $1 | cut -f2 -d-)
fi

if [[ $host_os == "linux" && $target_os == "mac" ]]; then
  echo "Compiling for Mac on Linux is not supported."
  exit 1
fi

if [[ $host_os == "mac" && $target_os == "linux" ]]; then
  echo "Compiling for Linux on Mac is not supported."
  exit 1
fi

target="${target_os}-${target_arch}"

if [[ $host_os == "linux" ]]; then
  if [[ host_arch == "x86_64" && target_arch == "i686" ]]; then
    # FIXME
    echo "Not supported yet" # CC="gcc -m32"
    exit 1
  fi
fi

if [[ $target == "windows-x86_64" ]]; then
  cross_toolchain_prefix="x86_64-w64-mingw32"
  setup_mingw
fi

if [[ $target == "windows-i686" ]]; then
  cross_toolchain_prefix="i686-w64-mingw32"
  setup_mingw
fi

dist_relative_path=$dist_name/$target_os/$target_arch/
dist=${PWD}/$dist_relative_path
mkdir -p $dist

mods="aom jpeg ocamr ogg openssl opus sdl theora voamrwbenc vorbis vpx webp x264 x265 xvid zlib ffmpeg"

for mod in $mods; do

  source recipes/$mod.sh

  pushd modules/$mod > /dev/null

  # If the submodule hasn't been pull, pull it.
  if test -n "$(find ./ -maxdepth 0 -empty)" ; then
    echo "Pulling $mod …"
    git submodule update --init .
  fi

  if [ $cross_compiling -eq 1 ]; then
    setup_cross $mod
  fi

  if [ ! -d $dist/$mod ]; then
    maybe_clean_module
    echo "Compiling ${mod}… "
    build $mod
    rm_dll $mod
    maybe_clean_module
  else
    echo "already built (rm -rf $dist_relative_path/$mod to rebuild). Skipped."
  fi

  post $mod

  popd > /dev/null

done
