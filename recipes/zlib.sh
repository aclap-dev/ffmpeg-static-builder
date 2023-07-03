make_options=""

function setup_cross {
  set_toolchain_bins
  if [[ $target_os == "windows" ]]; then
    make_options="-f win32/Makefile.gcc"
    sed -i "s/PREFIX =/PREFIX = $cross_toolchain_prefix-/" win32/Makefile.gcc
  fi
}

function build {
  ./configure --prefix=$dist/$1 \
    --static
  make $make_options -$MJ
  make install
}

function post {
  post_pkgconfig $@
}


