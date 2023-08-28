FFMPEG BUILD SCRIPT
-------------------

- Trying to avoid dynamic library dependencies (see `recipes/ffmpeg.sh` for a list of allowed dynamic libraries).
- Dependencies are git submodules.

Releases are tagged as such:

`ffmpeg-<ffmpeg-commit>-<ffmpeg-date>-<build-number>`

For example release [`ffmpeg-285c7f6f6b-2023-06-26-001`](https://github.com/aclap-dev/ffmpeg-static-builder/releases/tag/ffmpeg-285c7f6f6b-2023-06-26-001) is the first build of [ffmpeg commit 285c7f6f6b](https://github.com/FFmpeg/FFmpeg/commit/285c7f6f6b) which was commited on 2023-06-26.

**Important**: Any changes in a submodule (`modules/*`) will be erased by the script (see `maybe_clean_module` function).

Building with docker:
--------------------

This is optional:

```bash
# Linux builds
docker build -t linux . -f ./Dockerfile.linux
docker cp linux:/ffmpeg-static/dist/ffmpeg-linux-x86_64.tar.bz2 .

# Windows builds (cross compiled)
docker build -t windows . -f ./Dockerfile.windows
docker cp windows:/ffmpeg-static/dist/ffmpeg-windows-x86_64.tar.bz2 .
docker cp windows:/ffmpeg-static/dist/ffmpeg-windows-i686.tar.bz2 .
```

Mac dependencies:
----------------

```
brew install \
  autoconf@2.13 autoconf \
  automake \
  libtool \
  pkg-config \
  yasm nasm \
  cmake
```

Linux & Windows dependencies:
----------------------------

See Docker files.

Usage:
-----

```
$ ./build.sh
```

Cross-compilation:

```
$ ./build.sh <target>
```

Targets:

- `linux-x86_64`
- `linux-i686`
- `windows-x86_64`
- `windows-i686`
- `mac-x86_64`
- `mac-arm64`

Compilation result will be under the `dist/` directory.
To rebuild a dependency or ffmpeg itself, `rm -rf` the relevant
directory in `dist/<os>/<target>/`.

Test:
----

```
$ ./tests/test.sh
```

Execute a few tests to make sure basic features are properly supported.

`jq` and `dialog` necessary.

On Windows, the script must be run from MSYS2, and jq.exe should be in the path.
`dialog` can be installed via `pacman -S dialog`.

