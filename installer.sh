#!/usr/bin/env bash

script_magic="alias ds='source ~/.ds/ds_script.sh'"

echo "Installing ds..."

grep "$script_magic" ~/.bashrc 

if [ $? != 0 ]; then
	echo "$script_magic" >> ~/.bashrc	
	echo "~/.bashrc updated!"
else
	echo "~/.bashrc is already updated."
fi

# Create files:
echo "Creating files..."
mkdir -p ~/.ds
echo "Created the ~/.ds directory."
cp ds_engine.pl *.pm ds_script.sh ~/.ds
echo "Copied the code."

tag_file=$HOME"/.ds/tags"
touch "$tag_file"

add_tag_to_file () {
	if grep -q "^$1" $tag_file; then
		echo "Tag \"$1\" is already in the tag file."
	else 
		echo "$1 $2" >> $tag_file
		echo "Added tag \"$1\" to \"$2\""
	fi
}

# Populate the default 
echo "Populating the tag file with default tags..."

add_tag_to_file "docs" "~/Documents"
add_tag_to_file "down" "~/Downloads"
add_tag_to_file "root" "/"
add_tag_to_file "home" "~"
add_tag_to_file "ds"   "~/.ds"

echo "Done populating the tag file with default tags."
echo "Done! ds will be available for use in your next shell session. :-]"
echo ""
echo ""
