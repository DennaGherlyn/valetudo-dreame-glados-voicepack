#!/bin/bash -e
#
# Normalize the volume of the spoken text.
# Requires ffmpeg-normalize (pip install ffmpeg-normalize) and ffmpeg (http://ffmpeg.org/download.html).

inputdir=output/speech
outputdir=output/result

# Check for required commands
if ! command -v ffmpeg-normalize &> /dev/null; then
  echo "Error: ffmpeg-normalize is not installed. Please install it with 'pip install ffmpeg-normalize'."
  exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed. Please install ffmpeg (http://ffmpeg.org/download.html)."
  exit 1
fi

# Required audio encoding for Dreame robots
ffmpeg-normalize $inputdir/*.wav --normalization-type peak --target-level 0 -of $outputdir -c:a libvorbis -b:a 100k -ar 16000 -ofmt ogg -ext ogg
