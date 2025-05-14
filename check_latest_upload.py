#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys

def check_latest_uploads():
    # Initialize Firebase
    try:
        app = firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        cred = credentials.Certificate('config/service_account.json')
        app = firebase_admin.initialize_app(cred, {'storageBucket': 'diving-app-8fa28.firebasestorage.app'})
    
    # Initialize Firestore and Storage
    db = firestore.client()
    bucket = storage.bucket()
    
    print("\n===== CHECKING LATEST LESSON UPLOADS IN FIREBASE =====\n")
    print(f"Using storage bucket: {bucket.name}")
    
    # Specific IDs from the last upload
    lesson_01_id = "LES_20250514005426_9db35c81-6661-4b90"
    lesson_02_id = "LES_20250514005500_90b1977f-fe0d-45df"
    
    # Check Lesson_01
    print(f"\nChecking Lesson_01 (ID: {lesson_01_id}):")
    
    # Get the lesson document
    lesson_01_doc = db.collection('lessons').document(lesson_01_id).get()
    
    if lesson_01_doc.exists:
        lesson_01_data = lesson_01_doc.to_dict()
        print(f"  - Title: {lesson_01_data.get('title')}")
        
        # Get slides for Lesson_01
        slides = db.collection('lessons').document(lesson_01_id).collection('slides').stream()
        slides_list = list(slides)
        print(f"  - Has {len(slides_list)} slides")
        
        image_count = 0
        images_in_storage = 0
        
        for slide in slides_list:
            slide_data = slide.to_dict()
            images = slide_data.get('images', [])
            
            for image in images:
                image_count += 1
                filename = image.get('filename', 'Unknown')
                url = image.get('url', 'No URL')
                storage_path = image.get('storagePath', 'No path')
                
                print(f"  - Slide {slide_data.get('slideNumber')}, Image: {filename}")
                print(f"    URL: {url}")
                
                # Verify if the image exists in storage
                blob = bucket.blob(storage_path)
                if blob.exists():
                    print(f"    Status: ✅ Image exists in Storage")
                    images_in_storage += 1
                else:
                    print(f"    Status: ❌ Image NOT found in Storage")
                
        print(f"\n  Summary for Lesson_01:")
        print(f"  - Total images: {image_count}")
        print(f"  - Images in storage: {images_in_storage}")
        print(f"  - Images missing: {image_count - images_in_storage}")
    else:
        print(f"  Lesson_01 with ID {lesson_01_id} not found")
    
    # Check Lesson_02
    print(f"\nChecking Lesson_02 (ID: {lesson_02_id}):")
    
    # Get the lesson document
    lesson_02_doc = db.collection('lessons').document(lesson_02_id).get()
    
    if lesson_02_doc.exists:
        lesson_02_data = lesson_02_doc.to_dict()
        print(f"  - Title: {lesson_02_data.get('title')}")
        
        # Get slides for Lesson_02
        slides = db.collection('lessons').document(lesson_02_id).collection('slides').stream()
        slides_list = list(slides)
        print(f"  - Has {len(slides_list)} slides")
        
        image_count = 0
        images_in_storage = 0
        
        for slide in slides_list:
            slide_data = slide.to_dict()
            images = slide_data.get('images', [])
            
            for image in images:
                image_count += 1
                filename = image.get('filename', 'Unknown')
                url = image.get('url', 'No URL')
                storage_path = image.get('storagePath', 'No path')
                
                print(f"  - Slide {slide_data.get('slideNumber')}, Image: {filename}")
                print(f"    URL: {url}")
                
                # Verify if the image exists in storage
                blob = bucket.blob(storage_path)
                if blob.exists():
                    print(f"    Status: ✅ Image exists in Storage")
                    images_in_storage += 1
                else:
                    print(f"    Status: ❌ Image NOT found in Storage")
                
        print(f"\n  Summary for Lesson_02:")
        print(f"  - Total images: {image_count}")
        print(f"  - Images in storage: {images_in_storage}")
        print(f"  - Images missing: {image_count - images_in_storage}")
    else:
        print(f"  Lesson_02 with ID {lesson_02_id} not found")
    
    print("\n====== END OF LESSON CHECK ======\n")

if __name__ == "__main__":
    check_latest_uploads() 