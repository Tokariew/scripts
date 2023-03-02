#!/bin/bash

#Some cbz/cbr archived are not optimized for size. I use this tool to compress
#images inside the folder with unpacked cbz/cbr and compress it again into cbz
#And finally change extensions of images to proper, to many times it lying about
#being pngs, when it is jpg
#Requirments:
#jpegoptim -- to optimize the size of jpegs
#pngout -- for pngs
#optipng -- for pngs
#cwebp -- convert png to webp it will probably get smaller size with it
#fd -- don't use find, use fd for multithreaded operations

compress_jpg() {
	fd jpg$ --exec jpegoptim -pPt --all-normal {}
	fd jpg$ --exec jpegoptim -pPt --all-progressive {}
}

declare -A extension=(
	[image / jpeg]="jpg"
	[image / webp]="webp"
	[image / png]="png"
	[image / gif]="gif"
)

rename_to_extension() {
	mime="$(file -b --mime-type "$1")"
	fbname="${1%.*}"
	ext=${extension[$mime]}
	mv "$1" "$fbname.$ext"
}

compress_png() {
	fd png$ --type f | xargs -P12 -I {} sh -c 'pngout -f5 {}; pngout -f0 {}; optipng -o7 {}'
	fd png$ --type f --exec cwebp {} -o {.}.webp -z 9
	for file in *.png; do
		size_png=$(du -b "$file" | awk '{print $1}')
		size_webp=$(du -b "${file%.*}".webp | awk '{print $1}')
		if [ "$size_png" -gt "$size_webp" ]; then
			rm "$file"
			echo "removing png"
		else
			rm "${file%.*}".webp
			echo "removing webp"
		fi
	done
}

folder="${1#./}"
cd "$1" || exit
for file in *; do
	rename_to_extension "$file"
done
compress_jpg
compress_png
zip -r -9 - * >../"$folder".cbz
cd ..
rm -rf "$1"
