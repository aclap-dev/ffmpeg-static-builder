#!/bin/bash

set -euo pipefail
cd $(dirname $0)/

version=$(<VERSION)

files=(
  "dist/ffmpeg-$version-linux-aarch64.tar.bz2"
  "dist/ffmpeg-$version-linux-i686.tar.bz2"
  "dist/ffmpeg-$version-linux-x86_64.tar.bz2"
  "dist/ffmpeg-$version-mac-arm64.tar.bz2"
  "dist/ffmpeg-$version-mac-x86_64.tar.bz2"
  "dist/ffmpeg-$version-windows-i686.tar.bz2"
  "dist/ffmpeg-$version-windows-x86_64.tar.bz2"
)

gh release upload v$version "${files[@]}" --clobber
