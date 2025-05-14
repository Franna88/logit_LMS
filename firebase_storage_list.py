#!/usr/bin/env python3
import os
import firebase_admin
from firebase_admin import credentials, storage
import argparse

def list_firebase_storage(firebase_credentials_path):
    """
    List all files in Firebase Storage and get their download URLs
    
    Args:
        firebase_credentials_path (str): Path to Firebase credentials JSON file
    """
    try:
        # Initialize Firebase
        try:
            app = firebase_admin.get_app()
            print("Firebase already initialized")
        except ValueError:
            cred = credentials.Certificate(firebase_credentials_path)
            app = firebase_admin.initialize_app(cred, {
                'storageBucket': 'diving-app-8fa28.appspot.com'
            })
            print("Firebase initialized")
        
        # Get bucket
        bucket = storage.bucket(app=app)
        
        print("\n===== FILES IN FIREBASE STORAGE =====\n")
        
        # List all blobs/files
        blobs = list(bucket.list_blobs())
        if not blobs:
            print("No files found in storage.")
            return
        
        # Print all files with their download URLs
        for i, blob in enumerate(blobs):
            # Generate a signed URL that lasts for 1 hour
            url = blob.generate_signed_url(
                version="v4",
                expiration=60 * 60,  # 1 hour
                method="GET"
            )
            
            print(f"File {i+1}: {blob.name}")
            print(f"URL: {url}")
            print(f"Size: {blob.size/1024:.2f} KB")
            print(f"Content Type: {blob.content_type}")
            print("-" * 80)
            
            # For lesson files in specific, print a usage example
            if "lessons" in blob.name and (blob.name.endswith('.jpg') or 
                                          blob.name.endswith('.png') or 
                                          blob.name.endswith('.jpeg')):
                print(f"Example usage in Flutter:")
                print(f"""
'images': [
    {{'url': '{url}', 'description': 'Image from Firebase Storage'}}
]
                """)
                print("-" * 80)
    
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='List files in Firebase Storage')
    parser.add_argument('credentials', help='Path to Firebase credentials JSON file')
    
    args = parser.parse_args()
    
    list_firebase_storage(args.credentials)
    
    print("\nNOTE: The URLs generated are signed and will expire after 1 hour.")
    print("To use in your app, you need to handle authentication properly.") 