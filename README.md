FFMPEG BUILD SCRIPT
-------------------

- Trying to avoid dynamic library dependencies (see `recipes/ffmpeg.sh` for a list of allowed dynamic libraries).
- Dependencies are git submodules.

VERSION:
-------

Releases are tagged as such:

`ffmpeg-<ffmpeg-commit>-<ffmeg-date>-<build-number>`

IMPORTANT:
---------

Any changes in a submodule (`modules/*`) will be erased by the script (see `maybe_clean_module` function).

Usage:
-----

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

Test:
----

```
$ ./tests/test.sh
```

Execute a few tests to make sure basic features are properly supported.

`jq` and `dialog` necessary.

On Windows, the script must be run from MSYS2, and jq.exe should be in the path.
`dialog` can be installed via `pacman -S dialog`.

