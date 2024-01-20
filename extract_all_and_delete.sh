#!/bin/bash

# Global variable for overwrite mode
overwrite=""

# Function to extract and delete archive files
extract_and_delete() {
    for file in "$1"/*; do
        if [ -d "$file" ]; then
            # If the item is a directory and recursion is enabled
            [ "$recursive" == "yes" ] && extract_and_delete "$file"
        elif [ -f "$file" ]; then
            # Check the file type and extract accordingly
            case $file in
                *.tar.bz2|*.tar.gz|*.tar|*.tbz2|*.tgz|*.zip|*.7z)
                    decide_overwrite "$file" "$1"
                    ;;
                *.bz2|*.rar|*.gz|*.Z)
                    # These formats are extracted directly in the current directory
                    decide_overwrite "$file" ""
                    ;;
                *) 
                    echo "$file is not supported" ;;
            esac
        fi
    done
}

# Function to decide whether to overwrite a file
decide_overwrite() {
    destination="$2"
    case $overwrite in
        all) 
            extract "$1" "$destination" "-o" ;;
        none)
            extract "$1" "$destination" "-n" ;;
        *)
            echo "Overwrite $1? (y/n/all/none)"
            read response
            case $response in
                y) 
                    extract "$1" "$destination" "-o" ;;
                n) 
                    ;;
                all)
                    overwrite="all"
                    extract "$1" "$destination" "-o" ;;
                none)
                    overwrite="none"
                    ;;
            esac
    esac
}

# Function to extract files with given options and delete the archive
extract() {
    case $1 in
        *.tar.bz2) tar xjf "$1" -C "$2" $3 && rm "$1" ;;
        *.tar.gz)  tar xzf "$1" -C "$2" $3 && rm "$1" ;;
        *.tar)     tar xf "$1" -C "$2" $3 && rm "$1" ;;
        *.tbz2)    tar xjf "$1" -C "$2" $3 && rm "$1" ;;
        *.tgz)     tar xzf "$1" -C "$2" $3 && rm "$1" ;;
        *.zip)     unzip "$1" -d "$2" $3 && rm "$1" ;;
        *.7z)      7z x "$1" -o"$2" $3 && rm "$1" ;;
    esac
}

# Function to change the owner of the extracted files and the parent directory
change_owner() {
    echo "Do you want to change the owner of the extracted files and the parent directory? (y/n)"
    read response
    if [ "$response" == "y" ]; then
        sudo chown -R $USER:$USER "$1"
        sudo chown $USER:$USER "$1"
    fi
}

# Check if a directory path was passed as an argument
if [ -z "$1" ]; then
    echo "Please provide a directory."
    exit 1
fi

# Check if the recursive mode should be enabled
recursive="no"
if [ ! -z "$2" ]; then
    if [ "$2" == "-r" ]; then
        recursive="yes"
    fi
fi

# Start the extraction and deletion
extract_and_delete "$1"

# Change the owner of the extracted files and the parent directory
change_owner "$1"

