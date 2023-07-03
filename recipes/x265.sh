function setup_cross {
  set_toolchain_bins
}

function build {
  cmake \
    $cmake_options \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DENABLE_SHARED=OFF \
    -DENABLE_CLI=OFF \
    source
  make x265-static
  make install
}

function post {
  post_pkgconfig $@
}


