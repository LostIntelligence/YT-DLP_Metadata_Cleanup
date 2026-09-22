# Metadata Cleanup

This project contains a Bash script that cleans `.info.json` files produced by `yt-dlp` so they are better suited for use with the Jellyfin yt-dlp metadata plugin.

For the related Jellyfin plugin, see: https://github.com/ankenyr/jellyfin-youtube-metadata-plugin

## Why this exists

`yt-dlp` can generate large `.info.json` files containing metadata (like your public IP) that is useful for local processing, but not always needed by Jellyfin metadata readers. This script strips unnecessary fields to reduce file size and avoid carrying over metadata that can cause clutter or compatibility issues in media libraries.

## What it does

The script:

- checks whether `jq` is installed
- searches recursively for files named `*.info.json`
- skips backup files ending in `.old`
- creates a backup copy of each file before modifying it
- removes selected fields from the JSON document using `jq`
- writes the cleaned result back to the original file

## Fields removed

The script removes the following JSON keys from each file:

- `formats`
- `automatic_captions`
- `thumbnails`
- `heatmap`
- `epoch`
- `_version`

These are typically redundant for Jellyfin metadata consumption and are removed to keep the exported info JSON lean.

## Usage

1. Open a terminal in the project directory.
2. Make the script executable if needed:

   ```bash
   chmod +x MetadataCleanup.sh
   ```

3. Run it:

   ```bash
   ./MetadataCleanup.sh
   ```

## Notes

- A backup is created for each processed file as `filename.info.json.old`.
- The script is designed for use on SMB-mounted or network-shared directories.
- It writes temporary files into the same folder as the original file to avoid cross-filesystem issues.
- This is intended for `.info.json` metadata files created by `yt-dlp`, especially when preparing them for Jellyfin integration.

## Requirements

- Bash
- `jq`

Install `jq` on Arch Linux with:

```bash
sudo pacman -S jq
```
