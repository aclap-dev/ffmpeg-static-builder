ffmpeg_configure_options=""

function setup_cross {
  if [[ $target_os == "windows" ]]; then
    ffmpeg_configure_options="\
      --arch=$target_arch \
      --target-os=mingw32 \
      --cross-prefix=$cross_toolchain_prefix-"
  fi

}

function build {
  # Do not allow any system libraries
  export PKG_CONFIG_LIBDIR=

  export PKG_CONFIG_PATH=$FFMPEG_PKG_CONFIG_PATH
  export CFLAGS=$FFMPEG_CFLAGS
  export LDFLAGS=$FFMPEG_LDFLAGS

  ./configure \
    ${ffmpeg_configure_options} \
    --extra-ldexeflags="-Bstatic" \
    --pkg-config-flags="--static" \
    --disable-autodetect \
    --prefix=$dist/ffmpeg \
    --enable-version3 \
    --pkg-config=pkg-config \
    --enable-runtime-cpudetect \
    --enable-pthreads \
    --disable-w32threads \
    --enable-libtheora \
    --enable-libvpx \
    --enable-libvorbis \
    --disable-indev=sndio \
    --disable-outdev=sndio \
    --enable-libopenjpeg \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-gpl \
    --enable-openssl \
    --enable-libvo-amrwbenc \
    --enable-libopus \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libaom \
    --enable-libwebp \
    --enable-zlib \
    --enable-ffprobe \
    --enable-pic \
    --disable-doc

    make -$MJ
    make install
  }

  function post {
    case $target_os in
      linux)
        deps_count=7
        count=$(ldd $dist/ffmpeg/bin/ffmpeg | wc -l)
        ;;
      mac)
        deps_count=6
        count=$(otool -L $dist/ffmpeg/bin/ffmpeg | wc -l | tr -d ' ')
        ;;
      windows)
        deps_count=17
        count=$(objdump -p  $dist/ffmpeg/bin/ffmpeg.exe | grep "DLL Name" | wc -l)
        ;;
      *)
        ;;
    esac
    if [[ ! $count -eq $deps_count ]]; then
      echo "Error: unexpected amount of dependencies."
      exit 1
    fi
  }
