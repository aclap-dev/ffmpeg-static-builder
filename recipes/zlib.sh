function setup_cross {
  true
}

function build {
  ./configure --prefix=$dist/$1 \
    $autotools_options \
    --static
  make -$MJ
  make install
}

function post {
  post_pkgconfig $@
}


