options=""

function setup_cross {
  set_toolchain_bins
  if [[ $target_os == "windows" ]]; then
    options="--host=$cross_toolchain_prefix --target=mingw32"
  fi
}

function build {
  ./configure \
    ${options} \
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

