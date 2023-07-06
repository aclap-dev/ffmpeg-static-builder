host_os=$(uname -s)
host_arch=$(uname -m)
cross_compiling=0

case $host_os in
  Linux)
    host_os="linux"
    ;;
  Darwin)
    host_os="mac"
    ;;
  MINGW*)
    host_os="windows"
    ;;
esac

host="${host_os}-${host_arch}"

if [ $# -eq 0 ]; then
  target_os=$host_os
  target_arch=$host_arch
else
  case $1 in
    linux-x86_64 | \
    linux-i686 | \
    windows-x86_64 | \
    windows-i686 | \
    mac-x86_64 | \
    mac-arm64)
        ;;
    *)
      echo "Unsupported target: $1"
      exit 1
      ;;
  esac

  target_os=$(echo $1 | cut -f1 -d-)
  target_arch=$(echo $1 | cut -f2 -d-)
fi

target="${target_os}-${target_arch}"

if [[ $target != $host ]]; then
  cross_compiling=1
else
  cross_compiling=0
fi

if [ $cross_compiling -eq 1 ]; then

  if [[ $host_os == "linux" && $target_os == "mac" ]]; then
    echo "Compiling for Mac on Linux is not supported."
    exit 1
  fi

  if [[ $host_os == "mac" && $target_os == "linux" ]]; then
    echo "Compiling for Linux on Mac is not supported."
    exit 1
  fi

  if [[ $host_os == "linux" && $target_os == "linux" ]]; then
    # FIXME
    echo "Not supported yet" # CC="gcc -m32"
    exit 1
  fi

  if [[ $host_os == "mac" && $target_os == "mac" ]]; then
    if [[ $host_arch == "arm64" && $target_arch == "x86_64" ]]; then
      # Re-run script with rosetta
      arch -x86_64 ./build.sh
      exit 0
    else
      echo "Compiling for Mac MX from Mac Intel is not supported"
      exit 1
    fi
  fi

  if [[ $target_os == "windows" ]]; then
    cross_toolchain_prefix="$target_arch-w64-mingw32"
    setup_toolchain
  fi

fi
