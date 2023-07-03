function setup_cross {
  true
}

function build {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --disable-shared \
    --enable-static \
    --without-x
  make -$MJ
  make install
}

function post {
  post_pkgconfig $@
}


