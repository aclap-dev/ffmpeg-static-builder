function setup_cross {
  set_toolchain_bins
}

function build {
  export PKG_CONFIG_PATH=$dist/ogg/lib/pkgconfig
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --disable-shared \
    --disable-examples \
    --disable-oggtest
  make -$MJ
  make install
  unset PKG_CONFIG_PATH
}

function post {
  export PKG_CONFIG_LIBDIR=
  export PKG_CONFIG_PATH=$dist/theora/lib/pkgconfig:$dist/ogg/lib/pkgconfig
  FFMPEG_CFLAGS+=" $(pkg-config --cflags --static theora)"
  FFMPEG_LDFLAGS+=" $(pkg-config --libs --static theora)"
  unset PKG_CONFIG_PATH
}


