#!/bin/bash

git_clean=1 # SEE README
MJ="j4" # For parallel compilation
dist_name="dist" # Where all binaries will be installed.

cd $(dirname "$0")

set -euo pipefail

source ./prepare-cross-compilation.sh

FFMPEG_PKG_CONFIG_PATH=""
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""

dist_relative_path=$dist_name/$target_os/$target_arch/

dist=${PWD}/$dist_relative_path

mkdir -p $dist



function maybe_clean_module {
  if [ $git_clean -eq 1 ]; then
    cd $(git rev-parse --show-toplevel)
    # git checkout -f && git clean -fdx are dangerous.
    # Let's double check we are indeed in a submodule.
    # .git is a file only in submodules.
    if [ -s .git ]; then
      git checkout -f > /dev/null
      git clean -fdx > /dev/null
    else
      echo "ERROR: CLEAN FUNCTION CALLED IN TOP LEVEL GIT"
      exit 1
    fi
  fi
}

# Ensure that no shared library are installed.
# Otherwise the ffmpeg build system will find them
# and might use them. Not sure how to avoid that:
# - not all libraries build system allow to only compile static libs
# - not sure how to force ffmpeg to prioritize static libs.
function rm_dll {
  echo rm_dll
  rm -f \
    $dist/$1/lib/*.dylib \
    $dist/$1/lib/*.dll \
    $dist/$1/bin/*.dll \
    $dist/$1/lib/*.so.* \
    $dist/$1/lib/*.so \
    $dist/$1/lib64/*.so \
    $dist/$1/lib64/*.so.*
}

function build {
  pushd modules/$1 > /dev/null
  # If the submodule hasn't been pull, pull it.
  if test -n "$(find ./ -maxdepth 0 -empty)" ; then
    echo "Pulling $1 …"
    git submodule update --init .
  fi
  echo "Compiling $1… "
  if [ ! -d $dist/$1 ]; then
    maybe_clean_module
    build_$1 $1
    rm_dll $1
    maybe_clean_module
  else
    echo "already built (rm -rf $dist_relative_path/$1 to rebuild). Skipped."
  fi
  post_build_$2 $1 ${3:-}
  popd > /dev/null
}

function post_build_pkgconfig {
  if [ -d $dist/$1/lib/pkgconfig ]; then
    FFMPEG_PKG_CONFIG_PATH+=":$dist/$1/lib/pkgconfig"
  elif [ -d $dist/$1/lib64/pkgconfig ]; then
    FFMPEG_PKG_CONFIG_PATH+=":$dist/$1/lib64/pkgconfig"
  else
    echo "Could not find pkgconfig in $dist_relative_path/$1"
    exit 1
  fi
}

function post_build_cflags_from_pkgconfig {
  export PKG_CONFIG_LIBDIR=
  export PKG_CONFIG_PATH=$dist/$1/lib/pkgconfig
  FFMPEG_CFLAGS+=" $(pkg-config --cflags --static $2)"
  FFMPEG_LDFLAGS+=" $(pkg-config --libs --static $2)"
  unset PKG_CONFIG_PATH
}

function post_build_cflags_dir {
  FFMPEG_CFLAGS+=" -I${dist}/$1/include"
  FFMPEG_LDFLAGS+=" -L${dist}/$1/lib"
}

function post_build_theora {
  export PKG_CONFIG_LIBDIR=
  export PKG_CONFIG_PATH=$dist/theora/lib/pkgconfig:$dist/ogg/lib/pkgconfig
  FFMPEG_CFLAGS+=" $(pkg-config --cflags --static theora)"
  FFMPEG_LDFLAGS+=" $(pkg-config --libs --static theora)"
  unset PKG_CONFIG_PATH
}

function post_build_ffmpeg {
  case "$(uname -s)" in
    Linux*)
      deps_count=9
      count=$(ldd $dist/ffmpeg/bin/ffmpeg | wc -l)
      ;;
    Darwin*)
      deps_count=6
      count=$(otool -L $dist/ffmpeg/bin/ffmpeg | wc -l | tr -d ' ')
      ;;
    *)
      ;;
  esac
  if [ ! $count -eq $deps_count ]; then
    echo "Warning: unexpected amount of dependencies."
  fi
  echo "Build is successful. See $dist/ffmpeg"
  exit 0
}

function build_default_autotools {
  ./configure --prefix=$dist/$1 --disable-shared $autotools_options
  make -$MJ
  make install
}

function build_sdl {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --disable-shared \
    --enable-static \
    --without-x
  make -$MJ
  make install
}

function build_x264 {
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    $x264_options \
    --enable-static \
    --disable-cli
  make -$MJ
  make install
}

function build_xvid {
  cd build/generic
  ./bootstrap.sh
  ./configure \
    $autotools_options \
    --prefix=$dist/$1 \
    --disable-assembly
  make -$MJ
  make install
}

function build_webp {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --disable-cli \
    --disable-shared \
    --enable-static \
    --enable-libwebpmux \
    --enable-libwebpdemux  \
    --enable-libwebpdecoder
  make -$MJ
  make install
}

function build_zlib {
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --static
  make -$MJ
  make install
}

function build_jpeg {
  export CFLAGS="-DPNG_ARM_NEON_OPT=0"
  cmake \
    $cmake_options \
    -DBUILD_THIRDPARTY=1 \
    -DBUILD_SHARED_LIBS=0 \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" .
  make install
  unset CFLAGS
}

function build_x265 {
  cmake \
    $cmake_options \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DENABLE_SHARED=OFF \
    -DENABLE_CLI=OFF \
    source
  make x265-static
  make install
}

function build_theora {
  export PKG_CONFIG_PATH=$dist/ogg/lib/pkgconfig
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --disable-shared \
    --disable-examples --disable-oggtest
  make -$MJ
  make install
  unset PKG_CONFIG_PATH
}

function build_aom {
  mkdir aom_build
  cd aom_build
  cmake \
    $cmake_options \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DBUILD_SHARED_LIBS=0 \
    -DENABLE_EXAMPLES=0 \
    -DENABLE_TESTS=0 \
    -DENABLE_TOOLS=0 \
    -DCMAKE_BUILD_TYPE=Release \
    ..
  make install
}

function build_vpx {
  ./configure \
    $vpx_options \
    --prefix=$dist/$1 \
    --disable-shared \
    --disable-examples \
    --disable-tools \
    --disable-docs \
    --disable-install-bins \
    --disable-install-srcs \
    --disable-unit-tests \
    --size-limit=16384x16384 \
    --enable-postproc \
    --enable-multi-res-encoding \
    --enable-vp8 \
    --enable-vp9 \
    --enable-temporal-denoising \
    --enable-vp9-temporal-denoising \
    --enable-vp9-postproc \
    --enable-vp9-highbitdepth
  make -$MJ
  make install
}

function build_openssl {
  ./Configure $openssl_options --prefix=$dist/$1
  make -$MJ
  make install_sw
}

function build_ocamr {
  build_default_autotools $1
}

function build_voamrwbenc {
  build_default_autotools $1
}

function build_ogg {
  ./autogen.sh
  build_default_autotools $1
}

function build_opus {
  ./autogen.sh
  CPPFLAGS=$opus_cppflags build_default_autotools $1
}

function build_vorbis {
  export PKG_CONFIG_PATH=$dist/ogg/lib/pkgconfig
  ./autogen.sh
  build_default_autotools $1
  unset PKG_CONFIG_PATH
}

function build_ffmpeg {
  # Do not allow any system libraries
  export PKG_CONFIG_LIBDIR=

  export PKG_CONFIG_PATH=$FFMPEG_PKG_CONFIG_PATH
  export CFLAGS=$FFMPEG_CFLAGS
  export LDFLAGS=$FFMPEG_LDFLAGS

  echo $CFLAGS
  echo $LDFLAGS

  ./configure \
    ${ffmpeg_configure_options} \
    --extra-ldexeflags="-Bstatic" \
    --pkg-config-flags="--static" \
    --disable-autodetect \
    --prefix=$dist/ffmpeg \
    --enable-version3 \
    --pkg-config=pkg-config \
    --enable-runtime-cpudetect \
    --enable-libtheora \
    --enable-libvpx \
    --enable-libvorbis \
    --disable-indev=sndio \
    --disable-outdev=sndio \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-gpl \
    --enable-openssl \
    --enable-libvo-amrwbenc \
    --enable-libopus \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libaom \
    --enable-libwebp \
    --enable-ffprobe \
    --enable-pic \
    --disable-doc

    # --enable-pthreads \
    # --enable-libopenjpeg \
    # --enable-zlib \

  make -$MJ
  make install
}

# build sdl pkgconfig
# build zlib pkgconfig
build openssl pkgconfig
build x264 pkgconfig
# build xvid cflags_dir
build webp pkgconfig
build jpeg pkgconfig
build x265 pkgconfig
build aom pkgconfig
build vpx pkgconfig
build ocamr cflags_from_pkgconfig opencore-amrnb
build voamrwbenc cflags_from_pkgconfig vo-amrwbenc
build ogg pkgconfig
build opus pkgconfig
build theora theora
build vorbis pkgconfig
build ffmpeg ffmpeg
