#!/usr/bin/env bash

# Navigate to the parent directory of the script's location.
cd $(dirname $0)/..

# Initializing variables
ytdl_root=YTDL_INSTALL
ytdl_root=${!ytdl_root:-$HOME/.ytdl}
ytdl_path=$ytdl_root/ytdl

file_name=ytdl-lin-x64
url=https://github.com/gastonchenet/ytdl/releases/latest/download/$file_name

# Rebuilding the path to the executable
if [ -f $ytdl_root ]; then rm -rf $ytdl_root; fi
mkdir -p $ytdl_root/bin ||
  error "Failed to create directory \"$ytdl_root\""

# Downloading the executable with curl
curl --fail --location --progress-bar -o $ytdl_path $url ||
  error "Failed to download YTDL from \"$url\""

# Setting permissions on the executable
chmod +x $ytdl_root/ytdl ||
  error "Failed to set permissions on YTDL executable"

echo "YTDL succesfully installed!"

# Adding the executable to the PATH
if ! grep -q $ytdl_root <<< $PATH; then
  export PATH="$PATH:$ytdl_root"

  echo "" >> "$HOME/.bashrc"
  echo "# YTDL" >> "$HOME/.bashrc"
  echo "export PATH=\"\$PATH:$ytdl_root\"" >> "$HOME/.bashrc"

  echo ""
  echo "Please restart your terminal or run \"source ~/.bashrc\" to be able to use the command 'ytdl'"
fi