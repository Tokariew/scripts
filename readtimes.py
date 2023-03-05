from datetime import timedelta
from pathlib import Path

from mutagen.oggopus import OggOpus

# This script iterate over all opus file and return how long they are

total_time = timedelta()

for file in Path('.').rglob('*.opus'):
    opus = OggOpus(file)
    total_time += timedelta(seconds=opus.info.length)

print(f'Total time: {total_time}')
