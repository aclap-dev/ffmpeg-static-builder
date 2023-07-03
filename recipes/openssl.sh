options=""

function setup_cross {
  if [[ $target_os == "windows" ]]; then
    options="mingw64 --cross-compile-prefix=$cross_toolchain_prefix-"
  fi
}

function build {
  ./Configure $options --prefix=$dist/$1
  make -$MJ
  make install_sw
}

function post {
  post_pkgconfig $@
}


