function setup_cross {
  set_toolchain_bins
}

function build {
  build_autotools $1
}

function post {
  post_cflags_from_pkgconfig vo-amrwbenc $@
}

