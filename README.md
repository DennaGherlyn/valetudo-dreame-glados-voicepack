# GLaDOS voice pack builder

Give some personality to your Dreame vacuum by creating your own GLaDOS voice pack.

The script reads the text from the CSV file in GLaDOS' voice and packages it for upload to your vacuum. It's been tested with a `Dreame L10s Pro Ultra Heat` running [Valetudo](https://valetudo.cloud/), but it should also work with other generations and other methods of installing the voice pack. Especially when combined with some [original samples](http://www.portal2sounds.com/#w=glados), it can lead to some cool results.

Want to hear what she sounds like first? Check out the [GLaDOS voice generator](https://glados.c-net.org/).

These scripts are based on the work of [arner](https://github.com/arner/roborock-glados) and [mic-e](https://github.com/mic-e/valetudo-glados). I heavily modified `01-speak.sh` to make it more flexible and added `00-transscribe.sh` to make the initial generation of the necessary voice lines for different vacuum models easier. I also tweaked some minor things in the other script files.

## I'm not creative, just give me a voice pack!

You're doing a great job of disappointing me. Go on, go to the [releases page](https://github.com/DennaGherlyn/valetudo-dreame-glados-voicepack/releases) and download a pre-created pack.

## Requirements

- curl to call the GLaDOS voice generator API.
- [ffmpeg](http://ffmpeg.org/) and ffmpeg-normalize (`pip install ffmpeg-normalize`) to normalize the volume of the voice files.
- [OpenAI Whisper](https://github.com/openai/whisper) for transcribing audio (optional, for 00-transscribe.sh).

## Usage

- `git clone` this repo
- **Either** change the lines in the CSV file from the Dreame default to something you want GLaDOS to say 
- **Or** transcribe your robot's voice lines with Whisper (or any other software). 
  - Some of those files you can find on [dgiese's Robot Overview](https://robotinfo.dev/).
  - Make sure you use the correct voice files for your robot, otherwise you might end up with a voice pack that doesn't have all the necessary lines for your robot. For example, the `Dreame L10s Pro Ultra Heat` has 480 voice lines, while the `Dreame Bot Z10 Pro` has only 107.

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
  Transcribes all `.ogg` files in the current directory and writes to `transcriptions.csv`
- `./00-transscribe.sh wav ./audio myresults.csv`  
  Transcribes all `.wav` files in `./audio` and writes to `myresults.csv`

### Generate GLaDOS speech

```sh
./01-speak.sh [csvfile] [name_column_name] [text_column_name] [--no-header] [--dry-run] [--debug]
```
- `csvfile`: Input CSV file (required)
- `name_column_name`: Name or index of the column for output filenames (default: name)
- `text_column_name`: Name or index of the column for text to speak (default: text)
- `--no-header`: Use if your CSV does not have a header row
- `--dry-run`: Show what would be generated, but do not call the API
- `--debug`: Show debug output

**Examples:**
- `./01-speak.sh`
- `./01-speak.sh custom_lines.csv`
- `./01-speak.sh custom_lines.csv name text`
- `./01-speak.sh custom_lines.csv id sentence`
- `./01-speak.sh custom_lines.csv --no-header`
- `./01-speak.sh custom_lines.csv name text --dry-run --debug`
- `./01-speak.sh custom_lines.csv name text --no-header --dry-run --debug`

The files in `example_csv` are named after the Model ID to lessen the pain of the weird robot naming patterns. For example, `Dreame L10s Pro Ultra Heat` equals `dreame.vacuum.r2338a`. For a full list of Model IDs, see the [Vacuum Robot Overview](https://robotinfo.dev/) from Dennis Giese.

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

If you don't intend to replace the sound effect files, please make sure you add the original sound effect files to the `output/result` folder before packaging; otherwise, the startup, shutdown, or other sound effects won't play.

For the `Dreame L10s Pro Ultra Heat`, the sound effect files are:

| Filename | Usage          |
|---------:|:---------------|
| 0.ogg    | Startup sound  |
| 200.ogg  | Shutdown sound |
| 274.ogg  | Ding sound     |
| 436.ogg  | Sound effect   |
| 488.ogg  | Sound effect   |

As far as I can tell, Dreame names their audio files the same for all models. So a voice pack for the `Dreame Bot Z10 Pro` would work with the `Dreame L10s Pro Ultra Heat`; there would just be files missing, or vice versa. However, you might not have enough disk space to install all 480 voice lines if you only need 107.

Make of that what you will.

### Upload to your vacuum

- Host the file with `python3 -m http.server`
- Visit the Valetudo web interface
- Select Hamburger menu / Robot settings / Misc Settings
- Enter the hosted voice pack URL, GLaDOS language code, and MD5 hash
- Click `Set voice pack`
- Done!

If you created a custom CSV file, please be so kind as to share it back so others can benefit from it.

## Tips

### `Dreame L10s Pro Ultra Heat` has too many sound files

The sound files for the `Dreame L10s Pro Ultra Heat` from Dennis Giese's website include 480 sound files. Many voice lines are related to mounting or unmounting the mop pads, which the `Dreame L10s Pro Ultra Heat` can't do. This is odd, so it might have voice lines for other models as well.

### Original samples

You can't beat the actual GLaDOS with her expression and cynicism, so why not replace some of the WAV files with original samples from the game?

- Find the right samples, for instance [here](http://www.portal2sounds.com/#w=glados).
- Download them (via 'direct link') and give them the appropriate filenames (see the CSV file).
- Convert MP3 to WAV like this: `for i in *.mp3; do ffmpeg -i "$i" "${i%.*}.wav"; done`.
- Replace the respective files in the `output/speech` directory and run the process and package scripts.

### Further automations

If you are using [Home Assistant](https://www.home-assistant.io/), you can combine the control of your vacuum with other automations. How about a [soundtrack](https://www.youtube.com/watch?v=Y6ljFaKRTrI) or some light effects? The only limit is your willingness to release your inner geek—you know you want to ;).

## Credits

- Thanks to the folks over at [DustCloud](https://github.com/dgiese/dustcloud) for freeing our vacuums (and [transcribing the default voice](https://github.com/dgiese/dustcloud/blob/master/devices/xiaomi.vacuum/audio_generator/language/audio_en.csv)).
- [Valetudo](https://valetudo.cloud/) for the great UX.
- [b01t](https://dhampir.no/) for providing an API to his [GLaDOS voice generator](https://glados.c-net.org/).
