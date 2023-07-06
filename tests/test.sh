#!/bin/bash

# dependencies: jq and dialog

cd $(dirname "$0")/..

set -euo pipefail

err_report() {
  echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

source ./recipes/xcomp.sh

dist=dist/tests
rm -rf $dist
mkdir -p $dist
cd $dist

tar -xf ../ffmpeg-$host.tar.bz2

mv ffmpeg-$host/ffmpeg .
mv ffmpeg-$host/ffprobe .

gargs="-progress pipe:1 -hide_banner -loglevel error -y"

################# Test 0 - hls ffprobe

url='https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8'

./ffprobe -print_format json -show_format -show_streams "$url" > out0.json

nb_stream_out0=$(jq '.format.nb_streams' ./out0.json)
nb_programs_out0=$(jq '.format.nb_programs' ./out0.json)

[ $nb_stream_out0 -eq 11 ]
[ $nb_programs_out0 -eq 5 ]

rm out0.json

################# Test 1 - hls ffmpeg

./ffmpeg $gargs -i "$url" -map 0:5 -map 0:9 out1.mp4
./ffprobe -print_format json -show_format -show_streams ./out1.mp4 > out1.json
nb_stream_out1=$(jq '.format.nb_streams' ./out1.json)
[ $nb_stream_out1 -eq 2 ]

rm out1.json

################# Test 2 - overlays

./ffmpeg $gargs -i ./out1.mp4 -i ../../tests/ffmpeg-icon.png \
  -filter_complex "[0:v][1:v] overlay=7:7 [m]" \
  -c:v h264 -c:a copy -map 0:a -map [m] \
  out2.mp4
./ffprobe -print_format json -show_format -show_streams ./out2.mp4 > out2.json
nb_stream_out2=$(jq '.format.nb_streams' ./out2.json)
[ $nb_stream_out2 -eq 2 ]

set +e
dialog --keep-tite --title "Please check video $dist/out2.mp4" \
  --backtitle "FFMpeg tests" \
  --yesno "Does $dist/out2.mp4 include a ffmpeg icon as an overlay?" 7 60
if [ ! $? -eq 0 ]; then
  echo "no overlay error"
  exit 1
fi
set -e

################# Test 3 - codecs

./ffmpeg $gargs -i out1.mp4 -vn out3.mp3
./ffmpeg $gargs -i out1.mp4 -c:v libx265 -c:a copy out4.mp4
./ffmpeg $gargs -i out4.mp4 -vcodec libx264 -acodec aac out5.mp4
./ffmpeg $gargs -i out1.mp4 -c:v mpeg4 -vtag xvid out6.avi

# Cleanup
cd ../..
rm -rf $dist
echo "All tests passed"
