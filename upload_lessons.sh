#!/bin/bash

# Create and activate virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Created new virtual environment"
fi

source venv/bin/activate

# Install required packages
pip install firebase-admin

# Get project_id from the service account JSON
PROJECT_ID=$(grep -o '"project_id": "[^"]*' config/service_account.json | cut -d'"' -f4)
STORAGE_BUCKET="${PROJECT_ID}.appspot.com"

echo "Using Firebase project: $PROJECT_ID"
echo "Using storage bucket: $STORAGE_BUCKET"

# Upload Lesson_01
echo "Uploading Lesson_01..."
python3 firebase_uploader.py output/Lesson_01.json lib/assets/images config/service_account.json --storage-bucket $STORAGE_BUCKET

# Upload Lesson_02
echo "Uploading Lesson_02..."
python3 firebase_uploader.py output/Lesson_02.json lib/assets/images config/service_account.json --storage-bucket $STORAGE_BUCKET

echo "Upload complete. Run check_images.py to verify." 