function setup_cross {
  true
}

function build {
  cd build/generic
  ./bootstrap.sh
  ./configure \
    $autotools_options \
    --prefix=$dist/$1 \
    --disable-assembly
  make -$MJ
  make install
}

function post {
  post_cflags_dir $@
}

