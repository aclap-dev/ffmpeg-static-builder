#!/bin/bash

git_clean=1 # SEE README
MJ="j4" # For parallel compilation
dist_name="dist"

cd $(dirname "$0")

set -euo pipefail

FFMPEG_PKG_CONFIG_PATH=""
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""

dist=${PWD}/$dist_name

function maybe_clean_module {
  if [ $git_clean -eq 1 ]; then
    cd $(git rev-parse --show-toplevel)
    # git checkout -f && git clean -fdx are dangerous.
    # Let's double check we are indeed in a submodule.
    # .git is a file only in submodules.
    if [ -s .git ]; then
      git checkout -f
      git clean -fdx
    else
      echo "ERROR: CLEAN FUNCTION CALLED IN TOP LEVEL GIT"
      exit 1
    fi
  fi
}

function build {
  pushd modules/$1 > /dev/null
  # FIXME: git submodule update --init .
  echo -n "Compiling $1… "
  if [ ! -d $dist/$1 ]; then
    maybe_clean_module
    mkdir -p $dist/$1
    build_$1 $1 2> $dist/$1/build.log.stderr > $dist/$1/build.log.stdout
    if [ ! $? -eq 0 ]; then
      echo "failed."
      echo "Building $1 failed. See $dist_name/$1 for logs"
      exit 1
    else
      echo "success."
    fi
  else
    echo "already built (rm -rf $dist_name/$1 to rebuild). Skipped."
  fi
  post_build_$2 $1 ${3:-}
  popd > /dev/null
}

function post_build_pkgconfig {
  FFMPEG_PKG_CONFIG_PATH+=":$dist/$1/lib/pkgconfig"
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
  FFMLEG_LDFLAGS+=" -L${dist}/$1/lib"
}

function post_build_theora {
  export PKG_CONFIG_LIBDIR=
  export PKG_CONFIG_PATH=$dist/theora/lib/pkgconfig:$dist/ogg/lib/pkgconfig
  FFMPEG_CFLAGS+=" $(pkg-config --cflags --static theora)"
  FFMPEG_LDFLAGS+=" $(pkg-config --libs --static theora)"
  unset PKG_CONFIG_PATH
}

function post_build_ffmpeg {
  deps_count=6
  count=$(otool -L $dist/ffmpeg/bin/ffmpeg | wc -l | tr -d ' ')
  if [ ! $count -eq $deps_count ]; then
    echo "Unexpected amount of dependencies:"
    otool -L $dist/ffmpeg/bin/ffmpeg
    exit 1
  fi
  echo "Build is successful. See $dist/ffmpeg"
  exit 0
}

function build_default_autotools {
  ./configure --prefix=$dist/$1 --disable-shared
  make -$MJ
  make install
}

function build_sdl {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    --disable-shared \
    --enable-static \
    --without-x
  make -$MJ
  make install
  # Remove dynamic libraries because some dylib are still generated
  rm -f $dist/$1/lib/*.dylib $dist/$1/lib/*.so $dist/$1/lib/*.dll
}

function build_x264 {
  ./configure --prefix=$dist/$1 --enable-static --disable-cli
  make -$MJ
  make install
}

function build_xvid {
	cd build/generic
	./bootstrap.sh
  ./configure --prefix=$dist/$1 --disable-assembly
	make -$MJ
	make install
  rm -f $dist/$1/lib/*.dylib $dist/$1/lib/*.so $dist/$1/lib/*.dll
}

function build_webp {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
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
  ./configure --prefix=$dist/$1 --static
  make -$MJ
  make install
}

function build_jpeg {
  export CFLAGS="-DPNG_ARM_NEON_OPT=0"
  cmake \
    -DBUILD_THIRDPARTY=1 \
    -DBUILD_SHARED_LIBS:bool=off \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" .
  make install
  unset CFLAGS
}

function build_x265 {
  cmake -DCMAKE_INSTALL_PREFIX="$dist/$1" \
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
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DBUILD_SHARED_LIBS=0 \
    -DENABLE_EXAMPLES=0 \
    -DENABLE_TESTS=0 \
    -DENABLE_TOOLS=0 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_BUILD_TYPE=Release \
    ..
  make install
}

function build_vpx {
  ./configure \
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
    --enable-temporal-denoising \
    --enable-vp9-temporal-denoising \
    --enable-vp9-postproc \
    --enable-vp9-highbitdepth
	make -$MJ
	make install
}

function build_openssl {
  # -static option doesn't work
  ./Configure --prefix=$dist/$1
  make -$MJ
  make install_sw
  # Remove dynamic libraries because -static doesn't work
  rm -f $dist/$1/lib/*.dylib $dist/$1/lib/*.so $dist/$1/lib/*.dll
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
  build_default_autotools $1
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
    --extra-ldexeflags="-Bstatic" \
    --pkg-config-flags="--static" \
    --disable-autodetect \
    --prefix=$dist/ffmpeg \
    --enable-libtheora \
    --enable-libxvid \
    --enable-libvo-amrwbenc \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-gpl \
    --enable-runtime-cpudetect \
    --enable-pthreads \
    --enable-version3 \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libaom \
    --disable-indev=sndio \
    --disable-outdev=sndio \
    --enable-libvpx \
    --enable-libwebp \
    --enable-zlib \
    --enable-libopenjpeg \
    --enable-ffprobe \
    --enable-pic \
    --enable-openssl \
    --disable-doc

    # --enable-sdl2 \
    # --enable-ffplay \

  make -$MJ
  make install
}

# build sdl pkgconfig
build zlib pkgconfig
build openssl pkgconfig
build x264 pkgconfig
build xvid cflags_dir
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
