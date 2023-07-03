config_args=""

function setup_cross {
  config_args="--cross-prefix=$cross_toolchain_prefix-"
}

function build {
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    $config_args \
    --enable-static \
    --disable-cli
  make -$MJ
  make install
}

function post {
  post_pkgconfig $@
}
