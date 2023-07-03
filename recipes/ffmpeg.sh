ffmpeg_configure_options="--enable-pthreads"

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
    case "$(uname -s)" in
      Linux*)
        deps_count=9
        count=$(ldd $dist/ffmpeg/bin/ffmpeg | wc -l)
        ;;
      Darwin*)
        deps_count=6
        count=$(otool -L $dist/ffmpeg/bin/ffmpeg | wc -l | tr -d ' ')
        ;;
      *)
        ;;
    esac
    if [ ! $count -eq $deps_count ]; then
      echo "Warning: unexpected amount of dependencies."
    fi
    echo "Build is successful. See $dist/ffmpeg"
    exit 0
  }
