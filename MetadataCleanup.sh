#!/bin/bash

# Check if jq is installed (on Arch: pacman -S jq)
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Install it with: sudo pacman -S jq"
    exit 1
fi

echo "Starting SMB-optimized cleanup..."

# Recursively search for .info.json files
find . -type f -name "*.info.json" | while read -r file; do
    # Skip backups
    if [[ "$file" == *.old ]]; then
        continue
    fi

    echo "Processing network file: $file"
    
    # 1. Create a backup
    backup_file="${file}.old"
    cp "$file" "$backup_file"
    
    # 2. Create a temporary file DIRECTLY in the same SMB folder (prevents cross-filesystem errors)
    dir_name=$(dirname "$file")
    tmp_file=$(mktemp -p "$dir_name" tmp.XXXXXXXXXX)
    
    # 3. Process JSON
    jq '.formats = [] | .automatic_captions = {} | .thumbnails = [] | .heatmap = [] | del(.epoch) | del(._version)' "$file" > "$tmp_file"
    
    # If jq succeeded, we overwrite the content (preserves SMB permissions)
    if [ $? -eq 0 ]; then
        cat "$tmp_file" > "$file"
        rm -f "$tmp_file"
    else
        echo "Error in: $file (network backup remains intact)"
        rm -f "$tmp_file"
    fi
done

echo "Done! All files on the SMB share were safely anonymized."
