#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys

def check_images():
    # Initialize Firebase
    try:
        app = firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        cred = credentials.Certificate('config/service_account.json')
        app = firebase_admin.initialize_app(cred, {'storageBucket': 'logit-lms.appspot.com'})
    
    # Initialize Firestore and Storage
    db = firestore.client()
    bucket = storage.bucket()
    
    print("\n===== CHECKING FOR LESSON IMAGES IN FIREBASE =====\n")
    
    # Get the lesson documents
    lesson_01_query = db.collection('lessons').where('title', '==', 'Lesson_01').limit(1).stream()
    lesson_01_docs = list(lesson_01_query)
    
    lesson_02_query = db.collection('lessons').where('title', '==', 'Lesson_02').limit(1).stream()
    lesson_02_docs = list(lesson_02_query)
    
    # Check Lesson_01 images
    if lesson_01_docs:
        lesson_01_id = lesson_01_docs[0].id
        print(f"Checking images for Lesson_01 (ID: {lesson_01_id}):")
        
        # Get slides for Lesson_01
        slides = db.collection('lessons').document(lesson_01_id).collection('slides').stream()
        
        image_count = 0
        for slide in slides:
            slide_data = slide.to_dict()
            images = slide_data.get('images', [])
            
            for image in images:
                image_count += 1
                filename = image.get('filename', 'Unknown')
                url = image.get('url', 'No URL')
                storage_path = image.get('storagePath', 'No path')
                
                print(f"  - Slide {slide_data.get('slideNumber')}, Image: {filename}")
                print(f"    URL: {url}")
                print(f"    Storage Path: {storage_path}")
                
                # Verify if the image exists in storage
                blob = bucket.blob(storage_path)
                if blob.exists():
                    print(f"    Status: ✅ Image exists in Storage")
                else:
                    print(f"    Status: ❌ Image NOT found in Storage")
                
        if image_count == 0:
            print("  No images found for Lesson_01 slides")
    else:
        print("Lesson_01 not found")
    
    # Check Lesson_02 images
    if lesson_02_docs:
        lesson_02_id = lesson_02_docs[0].id
        print(f"\nChecking images for Lesson_02 (ID: {lesson_02_id}):")
        
        # Get slides for Lesson_02
        slides = db.collection('lessons').document(lesson_02_id).collection('slides').stream()
        
        image_count = 0
        for slide in slides:
            slide_data = slide.to_dict()
            images = slide_data.get('images', [])
            
            for image in images:
                image_count += 1
                filename = image.get('filename', 'Unknown')
                url = image.get('url', 'No URL')
                storage_path = image.get('storagePath', 'No path')
                
                print(f"  - Slide {slide_data.get('slideNumber')}, Image: {filename}")
                print(f"    URL: {url}")
                print(f"    Storage Path: {storage_path}")
                
                # Verify if the image exists in storage
                blob = bucket.blob(storage_path)
                if blob.exists():
                    print(f"    Status: ✅ Image exists in Storage")
                else:
                    print(f"    Status: ❌ Image NOT found in Storage")
                
        if image_count == 0:
            print("  No images found for Lesson_02 slides")
    else:
        print("Lesson_02 not found")
    
    print("\n====== END OF IMAGE CHECK ======\n")

if __name__ == "__main__":
    check_images() 