options=""

function setup_cross {
  if [[ $target == "windows-x86_64" ]]; then
    options="mingw64 --cross-compile-prefix=$cross_toolchain_prefix-"
  fi
  if [[ $target == "windows-i686" ]]; then
    options="mingw --cross-compile-prefix=$cross_toolchain_prefix-"
  fi
}

function build {
  if [[ $target == "mac-x86_64" ]]; then
    options="darwin64-x86_64-cc"
  fi
  ./Configure $options --prefix=$dist/$1
  make -$MJ
  make install_sw
}

function post {
  post_pkgconfig $@
}


