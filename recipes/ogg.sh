function setup_cross {
  set_toolchain_bins
}

function build {
  ./autogen.sh
  build_autotools $1
}

function post {
  post_pkgconfig $@
}


