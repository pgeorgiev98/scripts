#!/bin/bash

if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == '-h' ]; then
printf "Usage:
$0 -n 'Paste Name' -e X path_to_file

Where X is the expiration and can be any of the following values:
	N - Never
	10M - 10 Minutes
	1H - 1 Hour
	1D - 1 Day
	1W - 1 Week
	2W - 2 Weeks
	1M - 1 Month [Default]
"
exit 0
fi

dev_key_file="$HOME/.pastebin-dev-key"

if [ ! -f $dev_key_file ]; then
	echo "To use this pastebin script, you must enter your pastebin Developer API Key."
	echo "You must register to pastebin and visit https://pastebin.com/api"
	printf "Enter your Developer Key: "
	read key
	echo "This is your dev key:"
	echo "'$key'"
	printf "Correct? [y/n] "
	while true; do
		read ans
		if [ "$ans" == "y" ]; then break
		elif [ "$ans" == "n" ]; then exit 0
		else
			printf "Didn't quite catch that. [y/n] "
		fi
	done
	echo $key > $dev_key_file
	api_dev_key=$key
	echo "Key saved to $dev_key_file"
else
	api_dev_key=$(cat $dev_key_file)
fi

api_option='paste'
api_paste_name='Unnamed Paste'
api_paste_expire_date='1M'
url='https://pastebin.com/api/api_post.php'

file_name=''

i=1
while [ $i -le $# ]; do
	arg=${!i}
	case "$arg" in
	"-n")
		if [ $i -eq $(($# - 1)) ]; then
			echo "Expected name"
			exit 1
		fi
		i=$((i+1))
		api_paste_name=${!i}
		;;
	"-e")
		if [ $i -eq $# ]; then
			echo "Expected expiration"
			exit 1
		fi
		i=$((i+1))
		api_paste_expire_date=${!i}
		case $api_paste_expire_date in
			"N");;
			"10M");;
			"1H");;
			"1D");;
			"1W");;
			"2W");;
			"1M");;
			*)
				echo "Invalid expiration"
				exit 1
				;;
			esac
		;;
	*)
		if [ ! -z $file_name ]; then
			echo "'$arg' is garbage"
			exit 1
		fi
		file_name=$arg
	esac
	i=$((i+1))
done

if [ -z "$file_name" ]; then
	echo "Select a file"
	exit 1
fi

if [ ! -f "$file_name" ]; then
	echo "File '$file_name' not found"
	exit 1
fi

api_paste_code=$(cat "$file_name")

out=$(curl -X POST --data "\
api_dev_key=$api_dev_key&\
api_option=$api_option&\
api_paste_name=$api_paste_name&\
api_paste_expire_date=$api_paste_expire_date\
" --data-urlencode "api_paste_code=$api_paste_code" $url 2> /dev/null)
echo "$out"
if [ $? == 0 ] && [ ! -z $DISPLAY ]; then
	if which xclip &> /dev/null; then
		printf "$out" | xclip -selection clipboard
		echo "Copied to clipboard"
	fi
fi
