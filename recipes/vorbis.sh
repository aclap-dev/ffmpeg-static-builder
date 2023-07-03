function setup_cross {
  set_toolchain_bins
}

function build {
  ./autogen.sh
  PKG_CONFIG_PATH=$dist/ogg/lib/pkgconfig \
    build_autotools $1
}

function post {
  post_pkgconfig $@
}


