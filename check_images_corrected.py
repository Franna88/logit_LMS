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
        app = firebase_admin.initialize_app(cred, {'storageBucket': 'diving-app-8fa28.firebasestorage.app'})
    
    # Initialize Firestore and Storage
    db = firestore.client()
    bucket = storage.bucket()
    
    print("\n===== CHECKING FOR LESSON IMAGES IN FIREBASE =====\n")
    print(f"Using storage bucket: {bucket.name}")
    
    # Get the most recent lesson documents
    lesson_01_query = db.collection('lessons').where('title', '==', 'Lesson_01').stream()
    lesson_01_docs = list(lesson_01_query)
    
    lesson_02_query = db.collection('lessons').where('title', '==', 'Lesson_02').stream()
    lesson_02_docs = list(lesson_02_query)
    
    print(f"Found {len(lesson_01_docs)} Lesson_01 documents")
    print(f"Found {len(lesson_02_docs)} Lesson_02 documents")
    
    # Find the most recent Lesson_01
    if lesson_01_docs:
        most_recent_lesson_01 = max(lesson_01_docs, key=lambda doc: doc.id)
        lesson_01_id = most_recent_lesson_01.id
        print(f"\nChecking images for most recent Lesson_01 (ID: {lesson_01_id}):")
        
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
                print(f"    Storage Path: {storage_path}")
                
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
        print("Lesson_01 not found")
    
    # Find the most recent Lesson_02
    if lesson_02_docs:
        most_recent_lesson_02 = max(lesson_02_docs, key=lambda doc: doc.id)
        lesson_02_id = most_recent_lesson_02.id
        print(f"\nChecking images for most recent Lesson_02 (ID: {lesson_02_id}):")
        
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
                print(f"    Storage Path: {storage_path}")
                
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
        print("Lesson_02 not found")
    
    print("\n====== END OF IMAGE CHECK ======\n")

if __name__ == "__main__":
    check_images() 