# GLaDOS voice pack builder

Give some personality to your Dreame vacuum by creating your own GLaDOS voice pack.

The script reads the text from the csv file in GLaDOS' voice and packages it for upload to your vacuum. It's been tested with a gen1 running [Valetudo](https://valetudo.cloud/) but should also work with other generations and with other ways of installing the voice pack. Especially combined with some [original samples](http://www.portal2sounds.com/#w=glados) it can lead to some cool results.

Want to hear what she sounds like first? Check out [GLaDOS voice generator](https://glados.c-net.org/).

These scripts are based on the work of [arner](https://github.com/arner/roborock-glados) and [mic-e](https://github.com/mic-e/valetudo-glados). I heavily modifed `01-speak.sh` to make it more flexible and added `00-transscribe.sh` for making the initial generation of the necessary voice lines for different vacuum models easier.

## I'm not creative, just give me a voice pack!

You're doing a great job of disappointing me. Go on, go to the [releases page](https://github.com/arner/roborock-glados/releases) and download a pre-created pack.

## Requirements

- curl to call the GLaDOS voice generator API.
- [ffmpeg](http://ffmpeg.org/) and ffmpeg-normalize (`pip install ffmpeg-normalize`) to normalize the volume of the voice files.
- [OpenAI Whisper](https://github.com/openai/whisper) for transcribing audio (optional, for 00-transscribe.sh).

## Usage

- `git clone` this repo
- **Either** change the lines in the csv file from the Dreame default to something you want GLaDOS to say 
- **Or** transcribe your robots voice lines with Whisper (or any other software). 
  - Some of those files you can find on [dgiese's Robot Overview](https://robotinfo.dev/).
  - Make sure you use the correct voice files for your robot, otherwise you might end up with a voice pack that doesn't have all necessary lines for your robot. E.g. `Dreame L10s Pro Ultra Heat` has 480 voice lines, `Dreame Bot L10S Pro` has only 137.

### Transcribe existing audio (optional)

You can transcribe your own audio files to CSV using Whisper:

```sh
./00-transscribe.sh [extension] [source_path] [output_csv]
```
- `extension`: File extension to filter for (default: ogg)
- `source_path`: Directory to search for audio files (default: .)
- `output_csv`: Output CSV file name (default: transcriptions.csv)

**Examples:**
- `./00-transscribe.sh`  
  Transcribes all `.ogg` files in current directory and writes to `transcriptions.csv`
- `./00-transscribe.sh wav ./audio myresults.csv`  
  Transcribes all `.wav` files in `./audio` and writes to `myresults.csv`

### Generate GLaDOS speech

```sh
./01-speak.sh [csvfile] [name_column_name] [text_column_name] [--no-header] [--dry-run] [--debug]
```
- `csvfile`: Input CSV file (default: audio_default.csv)
- `name_column_name`: Name or index of the column for output filenames (default: name)
- `text_column_name`: Name or index of the column for text to speak (default: text)
- `--no-header`: Use if your CSV does not have a header row
- `--dry-run`: Show what would be generated, but do not call the API
- `--debug`: Show debug output

**Examples:**
- `./01-speak.sh`
- `./01-speak.sh mylines.csv`
- `./01-speak.sh mylines.csv name text`
- `./01-speak.sh mylines.csv id sentence`
- `./01-speak.sh mylines.csv --no-header`
- `./01-speak.sh mylines.csv name text --dry-run --debug`
- `./01-speak.sh mylines.csv name text --no-header --dry-run --debug`

### Normalize and encode audio

```sh
./02-process.sh
```
Normalizes the volume and encodes the files for Dreame robots.

### Package for upload

```sh
./03-package.sh
```
Packages the ogg files for upload.

### Upload to your vacuum

- Visit Valetudo in your browser (the IP of your vacuum) and go to Settings -> Sound and voice.
- Upload the generated .pkg file from the output/result directory and press 'Upload Voice Pack'.
- Done!

If you created a custom csv file, please be so kind to share it back so others can benefit from it.

## Tips

### Original samples

You can't beat the actual GLaDOS with her expression and cynicism, so why not replace some of the wav files with original samples from the game?

- Find the right samples, for instance on [here](http://www.portal2sounds.com/#w=glados).
- Download (via 'direct link') and give them the appropriate filenames (see the csv file).
- Convert mp3 to wav like this: `for i in *.mp3; do ffmpeg -i "$i" "${i%.*}.wav"; done`.
- Replace the respective files in the `output/result` directory and run the package script.

### Speak when bumping into something

Now we have this great voice installed, wouldn't it be great if GLaDOS would speak a bit more? How about a custom voice pack and configuration for this: [roborock-oucher](https://github.com/porech/roborock-oucher)?

### Further automations

If you are using [Home Assistant](https://www.home-assistant.io/), you can combine the control of your vacuum with other automations. How about a [soundtrack](https://www.youtube.com/watch?v=Y6ljFaKRTrI) or some light effects? The only limit is your willingness to release your inner geek - you know you want to ;).

## Credits

- Thanks to the folks over at [DustCloud](https://github.com/dgiese/dustcloud) for freeing our vacuums (and [transcribing the default voice](https://github.com/dgiese/dustcloud/blob/master/devices/xiaomi.vacuum/audio_generator/language/audio_en.csv)).
- [Valetudo](https://valetudo.cloud/) for the great ux.
- [b01t](https://dhampir.no/) for providing an API to his [GLaDOS voice generator](https://glados.c-net.org/).
