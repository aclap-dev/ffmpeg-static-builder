options=""

function setup_cross {
  options="--target=x86_64-win64-gcc"
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
