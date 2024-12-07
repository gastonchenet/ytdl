#!/usr/bin/env bash

# Navigate to the parent directory of the script's location.
cd $(dirname $0)/..

# Initializing variables
ytdl_root=YTDL_INSTALL
ytdl_root=${!ytdl_root:-$HOME/.ytdl}
ytdl_path=$ytdl_root/ytdl.zip

file_name=ytdl-lin-x64
url=https://github.com/gastonchenet/ytdl/releases/latest/download/$file_name.zip

# Rebuilding the path to the executable
if [ -f $ytdl_root ]; then rm -rf $ytdl_root; fi
mkdir -p $ytdl_root/bin ||
  error "Failed to create directory \"$ytdl_root\""

# Downloading the executable with curl
curl --fail --location --progress-bar -o $ytdl_path $url ||
  error "Failed to download YTDL from \"$url\""

# Extracting the executable from the archive
command -v unzip > /dev/null ||
  error "Unzip is not installed. Please install it and try again."

unzip -q $ytdl_path -d $ytdl_root ||
  error "Failed to extract YTDL to \"$ytdl_root\""

# Renaming the executable
mv $ytdl_root/$file_name $ytdl_root/bin/ytdl ||
  error "Failed to rename YTDL executable" 

# Removing the archive
rm $ytdl_path ||
  error "Failed to remove YTDL archive"

# Setting permissions on the executable
chmod +x $ytdl_root/bin/ytdl ||
  error "Failed to set permissions on YTDL executable"

echo "YTDL succesfully installed!"

# Adding the executable to the PATH
if ! grep -q $ytdl_root/bin <<< $PATH; then
  export PATH="$PATH:$ytdl_root/bin"

  echo "" >> "$HOME/.bashrc"
  echo "# YTDL" >> "$HOME/.bashrc"
  echo "export PATH=\"\$PATH:$ytdl_root/bin\"" >> "$HOME/.bashrc"

  echo ""
  echo "Please restart your terminal or run \"source ~/.bashrc\" to be able to use the command 'ytdl'"
fi