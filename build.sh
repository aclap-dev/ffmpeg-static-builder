#!/bin/bash

git_clean=1 # SEE README
MJ="j4" # For parallel compilation
dist_name="dist" # Where all binaries will be installed.
version=$(<VERSION)

cd $(dirname "$0")

set -euo pipefail

source ./recipes/functions.sh

FFMPEG_PKG_CONFIG_PATH=""
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""
FFMPEG_EXTRA_LIBS=""

autotools_options=""
cmake_options=""

source ./recipes/xcomp.sh

dist_relative_path=$dist_name/$target_os/$target_arch/
dist=${PWD}/$dist_relative_path
mkdir -p $dist

mods="zlib libxml2 xvid lame aom jpeg ocamr ogg openssl opus theora voamrwbenc vorbis vpx webp x264 x265 ffmpeg"

for mod in $mods; do

  source recipes/$mod.sh

  # If the submodule hasn't been pull, pull it.
  if test -n "$(find modules/$mod -maxdepth 0 -empty)" ; then
    echo "Pulling $mod …"
    git submodule update --init modules/$mod
  fi

  pushd modules/$mod > /dev/null

  if [ ! -d $dist/$mod ]; then
    maybe_clean_module
    if [ $cross_compiling -eq 1 ]; then
      setup_cross $mod
    fi
    echo "Compiling ${mod}… "
    build $mod
    # Cleanup some exports after modules
    unset_toolchain_bins
    # Ensure that no shared library are installed.
    rm_dll $mod
    maybe_clean_module
  else
    echo "$mod already built (rm -rf $dist_relative_path/$mod to rebuild). Skipped."
  fi

  post $mod

  popd > /dev/null

done

echo "Packaging…"

cd $dist_name
tmpdir=ffmpeg-$target
rm -rf $tmpdir
mkdir -p $tmpdir/presets
cp $dist/ffmpeg/bin/* $tmpdir
cp $dist/ffmpeg/share/ffmpeg/*.ffpreset $tmpdir/presets
tar -cjvf ffmpeg-$version-$target.tar.bz2 $tmpdir
rm -rf $tmpdir
cd ..
