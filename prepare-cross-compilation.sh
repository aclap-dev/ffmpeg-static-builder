#!/bin/bash

autotools_options=""
ffmpeg_configure_options=""
openssl_options=""
vpx_options=""
x264_options=""
cmake_options=""
opus_cppflags=""

host_os=$(uname -s)
host_arch=$(uname -m)

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
    mac-arm64) ;;
    *)
      echo "Unsupported target: $1"
      exit 1
      ;;
  esac

  target_os=$(echo $1 | cut -f1 -d-)
  target_arch=$(echo $1 | cut -f2 -d-)
fi

target="${target_os}-${target_arch}"

case host_os in
  "linux")
    case target_os in
      "mac")
        ;;
    esac
    ;;
  "mac")
    ;;
esac

if [[ $host_os == "linux" && $target_os == "mac" ]]; then
  echo "Compiling for Mac on Linux is not supported."
  exit 1
fi

if [[ $host_os == "mac" && $target_os == "linux" ]]; then
  echo "Compiling for Linux on Mac is not supported."
  exit 1
fi

if [[ $target == "windows-x86_64" ]]; then


  CROSS_COMPILE=x86_64-w64-mingw32-

  export CC="${CROSS_COMPILE}gcc"
  export CXX="${CROSS_COMPILE}g++"
  export NM="${CROSS_COMPILE}nm"
  export STRIP="${CROSS_COMPILE}strip"
  export RANLIB="${CROSS_COMPILE}ranlib"
  export AR="${CROSS_COMPILE}ar"
  export LD="${CROSS_COMPILE}ld"
  # export PKG_CONFIG="${CROSS_COMPILE}pkg-config"
  # export PKG_CONFIG_PATH=$ARCHSRCDIR/deps/lib/pkgconfig
  # export PKG_CONFIG_LIB_DIR=$ARCHSRCDIR/deps/lib/pkgconfig
  export GCC_LIBDIR=$(ls -d /usr/lib/gcc/x86_64-w64-mingw32/*-posix)



  _prefix="x86_64-w64-mingw32"
  autotools_options="--host=$_prefix"
  # https://github.com/msys2/MINGW-packages/issues/5868
  opus_cppflags="-D_FORTIFY_SOURCE=0"
  # vpx_options="--target=x86_64-win64-gcc --as=yasm" # x86-win64-gcc
  vpx_options="--target=x86_64-win64-gcc"
  x264_options="--cross-prefix=$_prefix-"
  openssl_options="mingw64 --cross-compile-prefix=$_prefix-"
  cmake_options="\
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_FIND_ROOT_PATH=/usr/$_prefix \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_RC_COMPILER=$_prefix-windres \
    -DCMAKE_C_COMPILER=$_prefix-gcc \
    -DCMAKE_CXX_COMPILER=$_prefix-g++"
  ffmpeg_configure_options="\
    --arch=x86_64 \
    --target-os=mingw32 \
    --cross-prefix=$_prefix-"
fi

if [[ $target == "windows-i686" ]]; then
  _prefix="i686-w64-mingw32"
  echo fixme
  exit 1
fi

if [[ $host_os == "linux" ]]; then
  if [[ host_arch == "x86_64" && target_arch == "i686" ]]; then
    echo "fixme"
    # CC="gcc -m32"
  fi
fi
