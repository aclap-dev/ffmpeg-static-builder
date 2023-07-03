cppflags=""

function setup_cross {
  set_toolchain_bins
  # https://github.com/msys2/MINGW-packages/issues/5868
  if [[ $target_os == "windows" ]]; then
    cppflags="-D_FORTIFY_SOURCE=0"
  fi
}

function build {
  ./autogen.sh
  CPPFLAGS=$cppflags build_autotools $1
}

function post {
  post_pkgconfig $@
}

