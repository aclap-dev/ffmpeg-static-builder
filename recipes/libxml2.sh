function setup_cross {
  set_toolchain_bins
}

function build {
  mkdir build
  cd build
  cmake \
    $cmake_options \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DLIBXML2_WITH_LZMA=OFF  \
    -DLIBXML2_WITH_ICONV=OFF \
    -DLIBXML2_WITH_PYTHON=OFF \
    -DLIBXML2_WITH_ZLIB=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release  \
    ..
  make install
}

function post {
  FFMPEG_CFLAGS+=" -I${dist}/libxml2/include"
  post_pkgconfig $@
}
