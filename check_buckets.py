#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, storage
import json
import argparse

def check_firebase_connection(firebase_credentials_path):
    """
    Check Firebase connection and list available storage buckets
    
    Args:
        firebase_credentials_path (str): Path to Firebase credentials JSON file
    """
    # Load credentials
    print(f"Loading credentials from {firebase_credentials_path}")
    cred = credentials.Certificate(firebase_credentials_path)
    
    # Get project ID from credentials
    with open(firebase_credentials_path, 'r') as f:
        cred_data = json.load(f)
        project_id = cred_data.get('project_id')
        print(f"Project ID: {project_id}")
    
    # Initialize Firebase without specifying bucket
    try:
        firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        firebase_admin.initialize_app(cred)
    
    print("Firebase initialized successfully")
    
    # Try to access default bucket
    try:
        bucket = storage.bucket()
        print(f"Default bucket name: {bucket.name}")
        print(f"Testing bucket exists: {bucket.exists()}")
    except Exception as e:
        print(f"Error accessing default bucket: {e}")
    
    # Try alternative bucket names
    alternative_buckets = [
        f"{project_id}.appspot.com",
        project_id,
        f"gs://{project_id}.appspot.com",
        f"gs://{project_id}"
    ]
    
    print("\nTrying alternative bucket names:")
    for bucket_name in alternative_buckets:
        try:
            bucket = storage.bucket(bucket_name)
            exists = bucket.exists()
            print(f"Bucket '{bucket_name}': {'Exists' if exists else 'Does not exist'}")
        except Exception as e:
            print(f"Error accessing bucket '{bucket_name}': {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check Firebase connection and storage')
    parser.add_argument('firebase_credentials', help='Path to Firebase credentials JSON file')
    
    args = parser.parse_args()
    check_firebase_connection(args.firebase_credentials) 