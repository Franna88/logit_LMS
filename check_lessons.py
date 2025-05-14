#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys

def check_lessons():
    # Initialize Firebase
    try:
        app = firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        cred = credentials.Certificate('config/service_account.json')
        app = firebase_admin.initialize_app(cred)
    
    # Initialize Firestore
    db = firestore.client()
    
    # Get all lessons
    lessons = db.collection('lessons').stream()
    
    found_lesson_01 = False
    found_lesson_02 = False
    
    print("\n===== CHECKING FOR LESSONS IN FIREBASE =====\n")
    
    # List all lessons
    print("All lessons in the database:")
    for lesson in lessons:
        lesson_data = lesson.to_dict()
        title = lesson_data.get('title')
        print(f"  - Lesson ID: {lesson.id}, Title: {title}")
        
        if title == "Lesson_01":
            found_lesson_01 = True
        elif title == "Lesson_02":
            found_lesson_02 = True
    
    print("\nSearching for specific lessons:")
    print(f"Lesson_01: {'Found ✅' if found_lesson_01 else 'Not Found ❌'}")
    print(f"Lesson_02: {'Found ✅' if found_lesson_02 else 'Not Found ❌'}")
    
    # Check if we can query specifically
    print("\nTrying direct query for Lesson_01 and Lesson_02:")
    
    lesson_01_query = db.collection('lessons').where('title', '==', 'Lesson_01').limit(1).stream()
    lesson_01_docs = list(lesson_01_query)
    if lesson_01_docs:
        print(f"Lesson_01 found via query: {lesson_01_docs[0].id}")
        
        # Check if it has slides
        slides = db.collection('lessons').document(lesson_01_docs[0].id).collection('slides').stream()
        slides_list = list(slides)
        print(f"  - Has {len(slides_list)} slides")
    else:
        print("Lesson_01 not found via direct query")
    
    lesson_02_query = db.collection('lessons').where('title', '==', 'Lesson_02').limit(1).stream()
    lesson_02_docs = list(lesson_02_query)
    if lesson_02_docs:
        print(f"Lesson_02 found via query: {lesson_02_docs[0].id}")
        
        # Check if it has slides
        slides = db.collection('lessons').document(lesson_02_docs[0].id).collection('slides').stream()
        slides_list = list(slides)
        print(f"  - Has {len(slides_list)} slides")
    else:
        print("Lesson_02 not found via direct query")
    
    print("\n====== END OF LESSON CHECK ======\n")

if __name__ == "__main__":
    check_lessons() 