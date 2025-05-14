#!/bin/bash

# Create and activate virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Created new virtual environment"
fi

source venv/bin/activate

# Install required packages
pip install firebase-admin

# The correct storage bucket from the screenshot
STORAGE_BUCKET="diving-app-8fa28.firebasestorage.app"

echo "Using storage bucket: $STORAGE_BUCKET"

# Upload Lesson_01
echo "Uploading Lesson_01..."
python3 firebase_uploader.py output/Lesson_01.json lib/assets/images config/service_account.json --storage-bucket $STORAGE_BUCKET

# Upload Lesson_02
echo "Uploading Lesson_02..."
python3 firebase_uploader.py output/Lesson_02.json lib/assets/images config/service_account.json --storage-bucket $STORAGE_BUCKET

echo "Upload complete. Run check_images.py to verify." 