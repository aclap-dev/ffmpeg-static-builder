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

To do a non-cross-compile build:

```
$ ./build.sh
```

To cross compile:

2 supported host

- linux: can compile all targets but mac-*
- mac: can compile all targets but linux-*

5 supported targets:

- `linux-x86_64`
- `linux-i686`
- `windows-x86_64`
- `windows-i686`
- `mac-x86_64`
- `mac-arm64`

```
$ ./build.sh <target>
```

Compilation result will be under the `dist/<os>/<arch>/ffmpeg` directory.
To rebuild a dependency or ffmpeg itself, `rm -rf` the relevant
directory in `dist`.

Todo:
----
- Windows, Mac Intel
- build for linux on mac
- test MP3 support (no lame?)
- remove dependency on libc++ (x265)
- no ffplay
- re-enable xvid: --enable-libxvid
- --enable-sdl2 --enable-ffplay

