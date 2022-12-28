#!/bin/bash -e
#
# Normalize the volume of the spoken text.
# Requires ffmpeg-normalize (pip install ffmpeg-normalize) and ffmpeg (http://ffmpeg.org/download.html).

inputdir=output/speech
outputdir=output/result

ffmpeg-normalize $inputdir/*.wav --normalization-type peak --target-level 0 -of $outputdir -c:a libvorbis -b:a 100k -ar 16000 -ofmt ogg -ext ogg
