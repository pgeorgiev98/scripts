# mrename.sh

A script that allows the user to rename files with the use of a standard editor.
The script uses the editor pointed by the VISUAL environment variable or uses
nano if the variable is not set.

For example, to rename the files 'foo', 'bar' and 'baz':

	mrename.sh foo bar baz

The editor will open with each of the filenames on a seperate line. The user
can then edit the filenames in the editor and save the file. The changed
entities will be renamed in the shown order.
