#!/bin/bash

cd $(dirname "$0")

set -euo pipefail

version=$(<VERSION)

docker build -t linux . -f ./Dockerfile.linux --progress=plain
docker build -t windows . -f ./Dockerfile.windows --progress=plain

mkdir dist

docker container create --name temp linux
docker container cp temp:/ffmpeg-static/dist/ffmpeg-$version-linux-x86_64.tar.bz2 dist
docker container rm temp
docker container create --name temp windows
docker container cp temp:/ffmpeg-static/dist/ffmpeg-$version-windows-x86_64.tar.bz2 dist
docker container cp temp:/ffmpeg-static/dist/ffmpeg-$version-windows-i686.tar.bz2 dist
docker container rm temp
docker image rm linux
docker image rm windows
