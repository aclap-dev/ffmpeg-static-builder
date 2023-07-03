function setup_cross {
  true
}

function build {
  ./autogen.sh
  build_autotools $1
}

function post {
  post_pkgconfig $@
}


