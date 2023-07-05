ffmpeg_configure_options=""

function setup_cross {
  if [[ $target_os == "windows" ]]; then
    ffmpeg_configure_options="\
      --arch=$target_arch \
      --target-os=mingw32 \
      --cross-prefix=$cross_toolchain_prefix-"

    FFMPEG_CFLAGS+=" -I/usr/$cross_toolchain_prefix/include/"
    FFMPEG_LDFLAGS+=" -L/usr/$cross_toolchain_prefix/lib/"

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
    --extra-ldflags="-static -static-libgcc -static-libstdc++" \
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
        # Allowed and expected system libraries:
        # ADVAPI32.dll
        # bcrypt.dll
        # GDI32.dll
        # KERNEL32.dll
        # msvcrt.dll
        # ole32.dll
        # OLEAUT32.dll
        # PSAPI.DLL
        # SHELL32.dll
        # SHLWAPI.dll
        # USER32.dll
        # AVICAP32.dll
        # WS2_32.dll
        deps_count=13
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
