options=""

function setup_cross {
  set_toolchain_bins
  if [[ $target == "windows-x86_64" ]]; then
    options="--target=x86_64-win64-gcc"
  fi
  if [[ $target == "windows-i686" ]]; then
    options="--target=x86-win32-gcc"
  fi
}

function build {
  ./configure \
    $options \
    --prefix=$dist/$1 \
    --disable-shared \
    --disable-examples \
    --disable-tools \
    --disable-docs \
    --disable-install-bins \
    --disable-install-srcs \
    --disable-unit-tests \
    --size-limit=16384x16384 \
    --enable-postproc \
    --enable-multi-res-encoding \
    --enable-vp8 \
    --enable-vp9 \
    --enable-temporal-denoising \
    --enable-vp9-temporal-denoising \
    --enable-vp9-postproc \
    --enable-vp9-highbitdepth
  make -$MJ
  make install
}

function post {
  post_pkgconfig $@
}
