#!/usr/bin/env python
"""Quick script which will convert image data from DICOM files into png and tiff
with rescaled data for easier viewing experience"""

from pathlib import Path

from imageio import imsave
from pydicom import dcmread
from skimage.exposure import rescale_intensity

if __name__ == '__main__':
    for file in Path('.').rglob('*dcm'):
        pixel_data = dcmread(file).pixel_array
        rescaled = rescale_intensity(pixel_data)
        # i often see images which are 12 bit in depth, so it will rescale to
        # full 16bit, so it easier to see in image viewers.
        imsave(file.with_suffix('.png'), rescaled)
        imsave(file.with_suffix('.tiff'), rescaled)
