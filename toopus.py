#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import shlex
import sys
from concurrent.futures import ProcessPoolExecutor
from itertools import repeat
from pathlib import Path
from subprocess import call

from slugify import slugify

# script to convert audio files into opus files. I use mainly for converting
# podcast/audiobooks into opus to reduce size.
# conversion to flac done because it way simpler to transfer metadata from
# other codecs

oenc = 'opusenc --quiet --bitrate {bitrate} --downmix-stereo --framesize 60'
ffmpeg = 'ffmpeg -hide_banner -loglevel panic -i {input} -vn -c:a flac -compression_level 0 -f flac -'


def progress(count, total, suffix=''):
    bar_len = 60
    filled_len = int(round(bar_len * count / float(total)))

    percents = round(100.0 * count / float(total), 1)
    sys.stdout.write(
        f'[{"="*filled_len:-<{bar_len}}] {percents}% … {suffix}\r')
    sys.stdout.flush()  # As suggested by Rom Ruben


def convert(file, bitrate):
    parts = file.parts
    parts = [slugify(part) for part in parts[:-1]]
    name = file.name
    suffix = file.suffix
    name = slugify(name[: name.find(suffix)]) + '.opus'
    parts.append(name)
    destiny = Path('/'.join(parts))
    destiny.parent.mkdir(parents=True, exist_ok=True)
    inp = shlex.quote(file.absolute().as_posix())
    if 'FLAC' in suffix.upper():
        w = call(
            oenc.format(bitrate=bitrate, input=inp, output=destiny), shell=True
        )
    else:
        w = call(
            f'{ffmpeg.format(input=inp)} | {oenc.format(bitrate=bitrate, input="-", output=destiny)}',
            shell=True
        )
    if w:
        print(f'problem with {file}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Convert to opus format')
    parser.add_argument(
        '--bitrate',
        metavar='n',
        default=32,
        type=int,
        nargs='?',
        help='Bitrate for conversion'
    )
    parser.add_argument(
        '--no-picture',
        action='store_true',
        help="Don't transfer pictures when transcoding"
    )

    bitrate = parser.parse_args().bitrate
    if parser.parse_args().no_picture:
        oenc = " ".join((oenc, '--discard-pictures'))
    oenc = " ".join((oenc, '{input} {output}'))
    files = [
        file for file in Path('.').glob('**/*')
        if file.is_file() and 'opus' not in file.suffix
    ]

    len_files = len(files)

    print(len_files)

    with ProcessPoolExecutor(max_workers=12) as executor:
        for i, info in enumerate(executor.map(convert, files, repeat(bitrate))):
            progress(i + 1, len_files, f"Converting {len_files} files")
    print('\n')
