# music-tag.sh

A script I use to tag all music (mp3) files from a particular album at once.

It uses eyeD3, so you must have it installed

Usage:

	music-tag.sh Year CoverPicture Genre [ARTIST] [ALBUM]

For a list of standard ID3 genre names/ids run with '--genres'

The script should be ran in a directory populated by mp3 files
from the same album that have the following naming scheme:

	04 - Song Name.mp3

If an album name is not provided, then the name
of the parent directory will be used.

Similarly, if an artist name is not provided, then the name
of the parent's parent directory will be used.
