#!/bin/bash

if [ "$1" == "--genres" ]; then
	eyeD3 --plugin=genres
	exit 0
fi

TRACKS=$(ls | grep '^[0-9][0-9] - .*\.mp3' -c)
YEAR="$1"
COVER="$2"
GENRE="$3"
if [ $# -lt 3 ] || [ $# -gt 5 ]; then
	echo "Usage: $0 Year CoverPicture Genre [ARTIST] [ALBUM]"
	echo ''
	echo 'For a list of standard ID3 genre names/ids run with --genres'
	echo ''
	echo "The script should be ran in a directory populated by mp3 files"
	echo "from the same album that have the following naming scheme:"
	echo "04 - Song Name.mp3"
	echo ''
	echo "If an album name is not provided, then the name"
	echo "of the parent directory will be used."
	echo ''
	echo "Similarly, if an artist name is not provided, then the name"
	echo "of the parent's parent directory will be used."
	exit 1
fi

if [ $# -ge 4 ]; then
	ARTIST="$4"
else
	ARTIST="$(basename "$(dirname "$(pwd)")")"
	echo "Artist: $ARTIST"
fi

if [ $# -ge 5 ]; then
	ALBUM="$5"
else
	ALBUM="$(basename "$(pwd)")"
	echo "Album: $ALBUM"
fi

echo ''
for i in `seq -f %02g 1 $TRACKS`; do
	(FILE=`ls $i\ -\ *.mp3 2>/dev/null` && echo $FILE) || \
		(echo Song number $i not found; exit 1)
done
echo ''

read -p 'Do you wish to retag these files? (y/N) ' yn
if [ "$yn" != 'y' ] && [ "$yn" != 'Y' ]; then
	echo 'Aborting...'
	exit 0
fi


for i in `seq -f %02g 1 $TRACKS`; do
	FILE=`ls $i\ -\ *.mp3`
	TITLE=${FILE%.mp3}
	TITLE=${TITLE#[0-9][0-9] - }
	eyeD3 --remove-all "$FILE"
	eyeD3 -a "$ARTIST" -b "$ARTIST" -A "$ALBUM" -Y "$YEAR" --add-image "$COVER:FRONT_COVER" -G "$GENRE" -N "$TRACKS" -n $i -t "$TITLE" --to-v2.3 --to-v2.3 "$FILE"
	eyeD3 --to-v1.1 "$FILE"
done
