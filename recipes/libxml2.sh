function setup_cross {
  set_toolchain_bins
}

function build {
  ./autogen.sh
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --without-lzma \
    --without-python
  make -$MJ
  make install
}

function post {
  post_pkgconfig $@
}
