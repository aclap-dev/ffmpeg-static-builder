function setup_cross {
  set_toolchain_bins
}

function build {
  cmake \
    $cmake_options \
    -DCMAKE_INSTALL_PREFIX="$dist/$1" \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DENABLE_SHARED=OFF \
    -DENABLE_CLI=OFF \
    source
  make x265-static
  make install
  if [[ $target_os == "windows" ]]; then
    # This is a little of a mystery. Linking gcc_s.a will add
    # a dynamic dependency on libgcc_s_seh.dll.
    # Removing gcc_s seems to produce a working executable.
    patch $dist/x265/lib/pkgconfig/x265.pc << 'EOF'
10c10
< Libs.private: -lstdc++ -lgcc_s -lgcc -lgcc_s -lgcc
---
> Libs.private: -lstdc++
EOF
  fi
}

function post {
  post_pkgconfig $@
}


