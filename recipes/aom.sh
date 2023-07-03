function setup_cross {
  set_toolchain_bins
}

function build {
  mkdir aom_build
  cd aom_build
  cmake \
    $cmake_options \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DBUILD_SHARED_LIBS=0 \
    -DENABLE_EXAMPLES=0 \
    -DENABLE_TESTS=0 \
    -DENABLE_TOOLS=0 \
    -DCMAKE_BUILD_TYPE=Release \
    ..
  make install
}

function post {
  post_pkgconfig $@
}


