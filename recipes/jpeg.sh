function setup_cross {
  set_toolchain_bins
}

function build {
  export CFLAGS="-DPNG_ARM_NEON_OPT=0"
  cmake \
    $cmake_options \
    -DBUILD_THIRDPARTY=1 \
    -DBUILD_SHARED_LIBS=0 \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" .
  make install
  unset CFLAGS
}

function post {
  post_pkgconfig $@
}


