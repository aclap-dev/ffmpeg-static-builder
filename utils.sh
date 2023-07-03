function setup_mingw {

  # General binary setup

  export CC="${cross_toolchain_prefix}-gcc"
  export CXX="${cross_toolchain_prefix}-g++"
  export NM="${cross_toolchain_prefix}-nm"
  export STRIP="${cross_toolchain_prefix}-strip"
  export RANLIB="${cross_toolchain_prefix}-ranlib"
  export AR="${cross_toolchain_prefix}-ar"
  export LD="${cross_toolchain_prefix}-ld"
  # FIXME: is that necessary?
  export GCC_LIBDIR=$(ls -d /usr/lib/gcc/${cross_toolchain_prefix}/*-posix)

  # Autotools options

  autotools_options="--host=${cross_toolchain_prefix}"

  # CMake options

  cmake_options="\
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_FIND_ROOT_PATH=/usr/${cross_toolchain_prefix} \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_RC_COMPILER=${cross_toolchain_prefix}-windres \
    -DCMAKE_C_COMPILER=${cross_toolchain_prefix}-gcc \
    -DCMAKE_CXX_COMPILER=${cross_toolchain_prefix}-g++"
}

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

function post_pkgconfig {
  if [ -d $dist/$1/lib/pkgconfig ]; then
    FFMPEG_PKG_CONFIG_PATH+=":$dist/$1/lib/pkgconfig"
  elif [ -d $dist/$1/lib64/pkgconfig ]; then
    FFMPEG_PKG_CONFIG_PATH+=":$dist/$1/lib64/pkgconfig"
  else
    echo "Could not find pkgconfig in $dist_relative_path/$1"
    exit 1
  fi
}

function post_cflags_from_pkgconfig {
  export PKG_CONFIG_LIBDIR=
  export PKG_CONFIG_PATH=$dist/$2/lib/pkgconfig
  FFMPEG_CFLAGS+=" $(pkg-config --cflags --static $1)"
  FFMPEG_LDFLAGS+=" $(pkg-config --libs --static $1)"
  unset PKG_CONFIG_PATH
}

function post_cflags_dir {
  FFMPEG_CFLAGS+=" -I${dist}/$1/include"
  FFMPEG_LDFLAGS+=" -L${dist}/$1/lib"
}

function build_autotools {
  ./configure --prefix=$dist/$1 --disable-shared $autotools_options
  make -$MJ
  make install
}
