#!/bin/bash

autotools_options=""
ffmpeg_configure_options=""

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
  autotools_options="--host=x86_64-w64-mingw32"
  ffmpeg_configure_options="\
    --arch=x86_64 \
    --target-os=mingw32 \
    --cross-prefix=x86_64-w64-mingw32-"
fi

if [[ $target == "windows-i686" ]]; then
  autotools_options="--host=i686-w64-mingw32"
  ffmpeg_configure_options="\
    --arch=i686 \
    --target-os=mingw32 \
    --cross-prefix=i686-w64-mingw32-"
fi

if [[ $host_os == "linux" ]]; then
  if [[ host_arch == "x86_64" && target_arch == "i686" ]]; then
    echo "fixme"
    # CC="gcc -m32"
  fi
fi
