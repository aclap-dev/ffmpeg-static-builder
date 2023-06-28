FFMPEG BUILD SCRIPT
-------------------

- Trying to avoid dynamic library dependencies.
- Dependencies are git submodules.

IMPORTANT:
---------

Any changes in a submodule (`modules/*`) will be
erased by the script (see `maybe_clean_module` function).

Usage:
-----

$ ./build.sh

Compilation result will be under the `dist/ffmpeg` directory.
To rebuild a dependency or ffmpeg itself, `rm -rf` the relevant
directory in `dist`.

Todo:
----
- Windows, Mac Intel
- test MP3 support (no lame?)
- remove dependency on libc++ (x265)
- no ffplay
- re-enable xvid: --enable-libxvid
- --enable-sdl2 --enable-ffplay

