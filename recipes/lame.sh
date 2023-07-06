function setup_cross {
  set_toolchain_bins
}

function build {
  ./configure \
    --prefix=$dist/$1 \
    --disable-dependency-tracking \
    --disable-debug \
    --enable-nasm
  make -$MJ
  make install
}

function post {
  post_cflags_dir $@
}

