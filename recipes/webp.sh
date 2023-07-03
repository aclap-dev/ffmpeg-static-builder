function setup_cross {
  true
}

function build {
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

function post {
  post_pkgconfig $@
}


