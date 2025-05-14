#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys

def check_all_lessons():
    # Initialize Firebase
    try:
        app = firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        cred = credentials.Certificate('config/service_account.json')
        app = firebase_admin.initialize_app(cred, {'storageBucket': 'diving-app-8fa28.appspot.com'})
    
    # Initialize Firestore and Storage
    db = firestore.client()
    bucket = storage.bucket()
    
    print("\n===== CHECKING ALL LESSON_01 AND LESSON_02 IN FIREBASE =====\n")
    
    # Search for all lessons with the title "Lesson_01"
    lesson_01_query = db.collection('lessons').where('title', '==', 'Lesson_01').stream()
    lesson_01_docs = list(lesson_01_query)
    
    print(f"Found {len(lesson_01_docs)} documents with title 'Lesson_01'")
    
    # Search for all lessons with the title "Lesson_02"
    lesson_02_query = db.collection('lessons').where('title', '==', 'Lesson_02').stream()
    lesson_02_docs = list(lesson_02_query)
    
    print(f"Found {len(lesson_02_docs)} documents with title 'Lesson_02'")
    
    # Check all Lesson_01 documents
    for doc in lesson_01_docs:
        lesson_id = doc.id
        print(f"\nChecking Lesson_01 with ID: {lesson_id}")
        
        # Get slides for this lesson
        slides = db.collection('lessons').document(lesson_id).collection('slides').stream()
        slides_list = list(slides)
        print(f"  - Has {len(slides_list)} slides")
        
        # Check each slide for images
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
                
                # Verify if the image exists in storage
                blob = bucket.blob(storage_path)
                exists = blob.exists()
                if exists:
                    images_in_storage += 1
                
                status = "✅ Found in Storage" if exists else "❌ NOT found in Storage"
                print(f"  - Slide {slide_data.get('slideNumber')}, Image: {filename}")
                print(f"    URL: {url}")
                print(f"    Status: {status}")
        
        print(f"  - Total images: {image_count}")
        print(f"  - Images in storage: {images_in_storage}")
        print(f"  - Images missing: {image_count - images_in_storage}")
    
    # Check all Lesson_02 documents
    for doc in lesson_02_docs:
        lesson_id = doc.id
        print(f"\nChecking Lesson_02 with ID: {lesson_id}")
        
        # Get slides for this lesson
        slides = db.collection('lessons').document(lesson_id).collection('slides').stream()
        slides_list = list(slides)
        print(f"  - Has {len(slides_list)} slides")
        
        # Check each slide for images
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
                
                # Verify if the image exists in storage
                blob = bucket.blob(storage_path)
                exists = blob.exists()
                if exists:
                    images_in_storage += 1
                
                status = "✅ Found in Storage" if exists else "❌ NOT found in Storage"
                print(f"  - Slide {slide_data.get('slideNumber')}, Image: {filename}")
                print(f"    URL: {url}")
                print(f"    Status: {status}")
        
        print(f"  - Total images: {image_count}")
        print(f"  - Images in storage: {images_in_storage}")
        print(f"  - Images missing: {image_count - images_in_storage}")
    
    print("\n====== END OF ALL LESSONS CHECK ======\n")

if __name__ == "__main__":
    check_all_lessons() 