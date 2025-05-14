#!/usr/bin/env python3
import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
import argparse
import uuid
import datetime

def upload_to_firebase(json_path, images_dir, firebase_credentials_path, course_id=None, module_id=None, school_code="DMT"):
    """
    Upload extracted PowerPoint content to Firebase Firestore (skipping image uploads)
    
    Args:
        json_path (str): Path to the JSON file with slide content
        images_dir (str): Directory containing the images (not used for upload)
        firebase_credentials_path (str): Path to Firebase credentials JSON file
        course_id (str): Course ID to attach this lesson to (optional)
        module_id (str): Module ID to attach this lesson to (optional)
        school_code (str): School code to identify the content source
    """
    # Initialize Firebase
    cred = credentials.Certificate(firebase_credentials_path)
    
    # Check if Firebase app is already initialized
    try:
        firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        firebase_admin.initialize_app(cred)
    
    # Initialize Firestore
    db = firestore.client()
    
    print(f"Connected to Firebase Firestore")
    
    # Load course data from JSON
    with open(json_path, 'r', encoding='utf-8') as f:
        course_data = json.load(f)
    
    # Extract title from the course data
    title = course_data["title"]
    
    # Generate a timestamp for the ID
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    
    # Generate a unique ID for the lesson
    lesson_id = f"LES_{timestamp}_{str(uuid.uuid4())[:18]}"
    
    # Prepare lesson data to match existing structure
    lesson_data = {
        "id": lesson_id,
        "title": title,
        "code": f"{school_code}_{title}",
        "sortcode": 0,
        "is_lesson_material": True,
        "is_case_study": False,
        "is_additional_material": False
    }
    
    # If module_id is provided, link this lesson to that module
    if module_id:
        lesson_data["module_id"] = module_id
    
    # Create a slides subcollection
    slides_data = []
    
    # Process each slide
    for i, slide in enumerate(course_data["slides"]):
        # Create a slide document
        slide_data = {
            "slideNumber": slide["slideNumber"],
            "title": slide["title"],
            "content": slide["content"],
            "images": []
        }
        
        # Just record the image filenames without uploading
        for image_data in slide["images"]:
            local_image_path = os.path.join(images_dir, image_data["filename"])
            
            if os.path.exists(local_image_path):
                # Just create placeholder data
                slide_data["images"].append({
                    "filename": image_data["filename"],
                    "url": f"PLACEHOLDER_URL_FOR_{image_data['filename']}",
                    "storagePath": f"schools/{school_code}/lessons/{lesson_id}/images/{image_data['filename']}"
                })
                print(f"Added reference to image: {image_data['filename']} (not uploaded)")
        
        # Add slide to slides collection
        slides_data.append(slide_data)
    
    # Store the lesson data in Firestore
    lesson_ref = db.collection("lessons").document(lesson_id)
    lesson_ref.set(lesson_data)
    
    # Store slides as a subcollection of the lesson
    for slide_data in slides_data:
        slide_id = f"SLIDE_{slide_data['slideNumber']}"
        lesson_ref.collection("slides").document(slide_id).set(slide_data)
    
    print(f"Lesson '{title}' uploaded successfully to Firebase Firestore (without images)")
    print(f"Lesson ID: {lesson_id}")
    
    # If course_id is provided, update the course to include this lesson
    if course_id and module_id:
        print(f"Linking lesson to course: {course_id}, module: {module_id}")
        
        # Get the module
        module_ref = db.collection("modules").document(module_id)
        module = module_ref.get()
        
        if module.exists:
            # Create a lessons array if it doesn't exist
            module_data = module.to_dict()
            if "lessons" not in module_data:
                module_data["lessons"] = []
            
            # Add this lesson to the module's lessons
            module_data["lessons"].append(lesson_id)
            
            # Update the module
            module_ref.update({"lessons": module_data["lessons"]})
            print(f"Module {module_id} updated with new lesson")
        else:
            print(f"Warning: Module {module_id} not found")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Upload extracted PowerPoint content to Firebase Firestore (skipping image uploads)')
    parser.add_argument('json_path', help='Path to the JSON file with slide content')
    parser.add_argument('images_dir', help='Directory containing the images (not used for upload)')
    parser.add_argument('firebase_credentials', help='Path to Firebase credentials JSON file')
    parser.add_argument('--course-id', help='Course ID to attach this lesson to')
    parser.add_argument('--module-id', help='Module ID to attach this lesson to')
    parser.add_argument('--school-code', default='DMT', help='School code to identify the content source')
    
    args = parser.parse_args()
    
    upload_to_firebase(
        args.json_path,
        args.images_dir,
        args.firebase_credentials,
        args.course_id,
        args.module_id,
        args.school_code
    ) 