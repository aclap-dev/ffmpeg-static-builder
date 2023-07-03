function setup_cross {
  true
}

function build {
  build_autotools $1
}

function post {
  post_cflags_from_pkgconfig opencore-amrnb $@
}

