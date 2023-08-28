#!/bin/bash

cd $(dirname "$0")

set -euo pipefail

docker build -t linux . -f ./Dockerfile.linux
docker build -t windows . -f ./Dockerfile.windows

mkdir dist

docker container create --name temp linux
docker container cp temp:/ffmpeg-static/dist/ffmpeg-linux-x86_64.tar.bz2 dist
docker container rm temp
docker container create --name temp windows
docker container cp temp:/ffmpeg-static/dist/ffmpeg-windows-x86_64.tar.bz2 dist
docker container cp temp:/ffmpeg-static/dist/ffmpeg-windows-i686.tar.bz2 dist
docker container rm temp
