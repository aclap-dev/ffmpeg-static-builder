#!/bin/bash

set -euo pipefail
cd $(dirname $0)/

version=$(<VERSION)

files=(
  "dist/ffmpeg-linux-aarch64-$version.tar.bz2"
  "dist/ffmpeg-linux-i686-$version.tar.bz2"
  "dist/ffmpeg-linux-x86_64-$version.tar.bz2"
  "dist/ffmpeg-mac-arm64.tar-$version.bz2"
  "dist/ffmpeg-mac-x86_64.tar-$version.bz2"
  "dist/ffmpeg-windows-i686-$version.tar.bz2"
  "dist/ffmpeg-windows-x86_64-$version.tar.bz2"
}

gh release upload v$version "${files[@]}" --clobber
