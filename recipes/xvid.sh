options=""

function setup_cross {
  set_toolchain_bins

  if [[ $target_os == "windows" ]]; then
    options="--target=mingw32"
  fi

}

function build {
  cd build/generic
  sed -i -e '/SPECIFIC_CFLAGS="-mno-cygwin"/d' configure.in
  ./bootstrap.sh
  ./configure \
    $autotools_options \
    $options \
    --prefix=$dist/$1 \
    --disable-assembly
  make -$MJ
  make install
  if [[ -f $dist/$1/lib/xvidcore.a ]]; then
    # xvid on Windows doesn't prefix the filename proper
    cp $dist/$1/lib/xvidcore.a $dist/$1/lib/libxvidcore.a
  fi
}

function post {
  if [[ $target == "linux-aarch64" ]] || [[ $target == "linux-x86_64" ]]; then
    FFMPEG_EXTRA_LIBS+=" -lm"
  fi
  post_cflags_dir $@
}

