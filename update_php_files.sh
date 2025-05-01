#!/bin/bash

# Define source and destination directories
SOURCE_DIR="/home/kagz03/VS Code Projects /Flutter_work/my_spa/php"
DEST_DIR="/opt/lampp/htdocs/my_spa/php"

# Ensure the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Ensure the destination directory exists
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating destination directory: $DEST_DIR"
    sudo mkdir -p "$DEST_DIR"
fi

# Copy all PHP files from source to destination with sudo permissions
echo "Copying PHP files from workspace to XAMPP htdocs..."
sudo cp -v "$SOURCE_DIR"/*.php "$DEST_DIR"/

# Set appropriate permissions
echo "Setting appropriate permissions..."
sudo chmod 644 "$DEST_DIR"/*.php
sudo chown daemon:daemon "$DEST_DIR"/*.php

echo "Files successfully copied to $DEST_DIR"
echo "Remember to access http://localhost/my_spa/add_foreign_keys.php in your browser"
echo "to apply the foreign key constraints to your database."