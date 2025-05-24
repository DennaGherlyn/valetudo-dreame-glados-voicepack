#!/bin/bash -e
#
# Run this script to generate wav files in GLaDOS' voice based on the lines in the input csv.
# Existing files are not overwritten. Requires curl.
#
# Make sure that the input CSV file is UTF-8 encoded, uses commas as delimiters and all cells are quoted, to prevent bad behaviour.
#
# Usage: ./01-speak.sh [csvfile] [name_column_name] [text_column_name] [--no-header] [--dry-run] [--debug]
#
# Examples:
#
#   ./01-speak.sh custom_lines.csv
#     # Uses custom_lines.csv, columns "name" and "text" with header
#
#   ./01-speak.sh custom_lines.csv name text
#     # Uses custom_lines.csv, columns "name" and "text" with header
#
#   ./01-speak.sh custom_lines.csv id sentence
#     # Uses custom_lines.csv, columns "id" and "sentence" with header
#
#   ./01-speak.sh custom_lines.csv --no-header
#     # Uses custom_lines.csv, no header row
#
#   ./01-speak.sh custom_lines.csv name text --dry-run --debug
#     # Shows what would be generated, with debug output
#
#   ./01-speak.sh custom_lines.csv name text --no-header --dry-run --debug
#     # No header, dry run, debug output
#

if [[ -z "$1" ]]; then
  echo "Usage: $0 [csvfile] [name_column_name] [text_column_name] [--no-header] [--dry-run] [--debug]"
  echo "Error: csvfile argument is required."
  exit 1
fi

inputfile="$1"
namecol=${2:-name}
textcol=${3:-text}
noheader=0
dryrun=0
debug=0
outputdir=output/speech

# Parse extra arguments
for arg in "$@"; do
  case "$arg" in
    --no-header) noheader=1 ;;
    --dry-run) dryrun=1 ;;
    --debug) debug=1 ;;
  esac
done

mkdir -p "$outputdir"

log_debug() {
  if [[ $debug -eq 1 ]]; then
    echo "[DEBUG] $*"
  fi
}

process_row() {
  local name="$1"
  local text="$2"
  # Skip rows with empty text
  if [[ -z "$text" ]]; then
    log_debug "Skipping row with empty text (name='$name')"
    return
  fi
  # Strip extension from name if present and always use .wav
  local basename="${name%.*}"
  local filename="$outputdir/$basename.wav"
  log_debug "name='$name' text='$text' filename='$filename'"
  echo "Processing: $text"
  if [ ! -f "$filename" ]; then
    if [[ $dryrun -eq 1 ]]; then
      echo "[DRY RUN] Would generate: $filename for text: $text"
    else
      curl -Ls --retry 30 --get --fail \
        --data-urlencode "text=$text" \
        -o "$filename" \
        'https://glados.c-net.org/generate'
    fi
  fi
}

csv_extract() {
  # $1: inputfile, $2: name_idx, $3: text_idx
  awk -v name_idx="$2" -v text_idx="$3" '
    function strip_quotes(s) {
      gsub(/^"/, "", s); gsub(/"$/, "", s); gsub(/""/, "\"", s);
      return s
    }
    {
      n = 0
      field = ""
      in_quotes = 0
      for (i = 1; i <= length($0); i++) {
        c = substr($0, i, 1)
        if (c == "\"") {
          if (in_quotes && substr($0, i+1, 1) == "\"") {
            field = field "\""
            i++
          } else {
            in_quotes = !in_quotes
          }
        } else if (c == "," && !in_quotes) {
          n++
          arr[n] = field
          field = ""
        } else {
          field = field c
        }
      }
      n++
      arr[n] = field

      name = arr[name_idx+1]
      text = arr[text_idx+1]
      name = strip_quotes(name)
      text = strip_quotes(text)
      printf "%s\t%s\n", name, text
    }
  ' "$1"
}

if [[ $noheader -eq 1 ]]; then
  # Assume name is column 0, text is column 1 by default
  name_idx=0
  text_idx=1
  if [[ "$namecol" =~ ^[0-9]+$ ]]; then name_idx=$namecol; fi
  if [[ "$textcol" =~ ^[0-9]+$ ]]; then text_idx=$textcol; fi

  csv_extract "$inputfile" "$name_idx" "$text_idx" | while IFS=$'\t' read -r name text; do
    process_row "$name" "$text"
  done
else
  # Read header and determine column indices
  IFS=, read -r -a headers < "$inputfile"
  name_idx=-1
  text_idx=-1
  for i in "${!headers[@]}"; do
    h="${headers[$i]//\"/}"
    if [[ "$h" == "$namecol" ]]; then name_idx=$i; fi
    if [[ "$h" == "$textcol" ]]; then text_idx=$i; fi
  done
  if [[ $name_idx -lt 0 || $text_idx -lt 0 ]]; then
    echo "Could not find required columns: $namecol and $textcol"
    exit 1
  fi

  tail -n +2 "$inputfile" | csv_extract /dev/stdin "$name_idx" "$text_idx" | while IFS=$'\t' read -r name text; do
    process_row "$name" "$text"
  done
fi

test -e custom || exit

cd custom

for f in *.mp3; do
  ffmpeg -i "$f" ../"$outputdir"/"${f%.*}.wav"
done
