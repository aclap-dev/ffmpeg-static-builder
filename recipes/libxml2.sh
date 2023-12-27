function setup_cross {
  set_toolchain_bins
}

function build {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --enable-static \
    --without-iconv \
    --without-lzma \
    --without-python
  make -$MJ
  make install
}

function post {
  FFMPEG_CFLAGS+=" -I${dist}/libxml2/include"
  post_pkgconfig $@
}
