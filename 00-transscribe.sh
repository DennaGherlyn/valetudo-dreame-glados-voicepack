#!/bin/bash
output_csv="transcriptions.csv"
echo "name,text" > "$output_csv"

for file in *.ogg; do
  whisper --model small --output_format txt --task transcribe "$file"
  txtfile="${file%.ogg}.txt"
  # Remove newlines and extra spaces from the transcription for clean CSV output
  transcription=$(tr '\n' ' ' < "$txtfile" | sed 's/  */ /g' | sed 's/"/""/g')
  # Output CSV line, quoting the transcription to handle commas
  echo "\"$file\",\"$transcription\"" >> "$output_csv"
done
