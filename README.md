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

Compilation result will be under the `dist/` directory.
To rebuild a dependency or ffmpeg itself, `rm -rf` the relevant
directory in `dist/<os>/<target>/`.
