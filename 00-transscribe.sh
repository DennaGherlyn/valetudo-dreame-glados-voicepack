#!/bin/bash
#
# This script transcribes all audio files with a given extension in the given directory using OpenAI Whisper.
# The results are written to a CSV file with columns "name" and "text".
#
# Usage:
#   ./00-transscribe.sh [extension] [source_path] [output_csv]
#
# Arguments:
#   extension   File extension to filter for (default: ogg)
#   source_path Directory to search for audio files (default: .)
#   output_csv  Output CSV file name (default: transcriptions.csv)
#
# Examples:
#   ./00-transscribe.sh
#     # Transcribes all .ogg files in current directory and writes to transcriptions.csv
#
#   ./00-transscribe.sh wav ./audio myresults.csv
#     # Transcribes all .wav files in ./audio and writes to myresults.csv
#
# Requirements:
#   - The 'whisper' command must be installed and available in PATH.
#   - Audio files must be present in the source directory.
#
ext="${1:-ogg}"
src_path="${2:-.}"
output_csv="${3:-transcriptions.csv}"

# Check if whisper is available
if ! command -v whisper &> /dev/null; then
  echo "Error: 'whisper' command not found. Please install whisper before running this script."
  exit 1
fi

echo "name,text" > "$output_csv"

shopt -s nullglob
for file in "$src_path"/*."$ext"; do
  whisper --model small --output_format txt --task transcribe "$file"
  txtfile="${file%.*}.txt"
  # Remove newlines and extra spaces from the transcription for clean CSV output
  transcription=$(tr '\n' ' ' < "$txtfile" | sed 's/  */ /g' | sed 's/"/""/g')
  # Output CSV line, quoting the transcription to handle commas
  echo "\"$(basename "$file")\",\"$transcription\"" >> "$output_csv"
done
shopt -u nullglob
