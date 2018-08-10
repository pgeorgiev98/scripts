#!/bin/bash

# Open the editor preferred by the user (use nano as fallback)
function edit() {
	if [ -z "$VISUAL" ]; then
		nano $@
	else
		$VISUAL $@
	fi
}

# Print the help message
if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echo "Usage: $0 file0 file1 file2 ..."
	echo ''
	echo 'You must have your VISUAL environment variable set'
	echo 'to your editor of choice (nano will be used otherwise)'
	echo ''
	if [ -z "$VISUAL" ]; then
		echo 'It is currently not set, so nano will be used'
	else
		echo "It is currently set to $VISUAL"
	fi
	echo ''
	echo 'For example, you can also force the script to use vim with:'
	echo ''
	echo "VISUAL=vim $0 file0 file1 file2 ..."
	echo ''
	exit 0
fi

# Write all the filenames to a temporary file
tmp=$(mktemp)
for i in `seq 1 $#`; do
	filename=${!i}

	# Check if the file exists
	if [ ! -e "$filename" ]; then
		echo "File $filename does not exist"
		rm -f $tmp
		exit 1
	fi

	echo "$filename" >> $tmp
done

# Allow the user to edit the filenames
edit $tmp

# Show the rename operations that will be performed
files_to_rename=0
i=1
while IFS= read -r new_filename; do
	filename=${!i}
	if [ "$filename" != "$new_filename" ]; then
		printf "\e[31m$filename \e[39m-> \e[32m$new_filename\n"
		files_to_rename=$((files_to_rename + 1))
	fi
	i=$((i + 1))
done < $tmp
printf '\e[39m'

# Quit if no files are to be renamed
if [ $files_to_rename -eq 0 ]; then
	echo 'Nothing to do'
	rm -f $tmp
	exit 0
fi

# Ask the user for confirmation
echo ''
read -p 'Do you wish to rename these files? (y/N) ' yn
if [ "$yn" != 'y' ] && [ "$yn" != 'Y' ]; then
	echo 'Aborting...'
	rm -f $tmp
	exit 0
fi

# Rename the files

echo ''
echo 'Renaming...'
echo ''

renamed_files=0
i=1
while IFS= read -r new_filename; do
	filename=${!i}
	if [ "$filename" != "$new_filename" ]; then
		mv "$filename" "$new_filename" && renamed_files=$((renamed_files + 1))
	fi
	i=$((i + 1))
done < $tmp

# Show the count of the renamed files
if [ $renamed_files -eq 1 ]; then
	echo "$renamed_files file renamed"
else
	echo "$renamed_files files renamed"
fi

# Cleanup
rm -f $tmp
