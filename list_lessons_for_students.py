#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys
import json
from datetime import datetime

def list_lessons_for_students():
    """
    Generate a student-friendly list of lessons with direct access URLs
    """
    # Initialize Firebase
    try:
        app = firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        cred = credentials.Certificate('config/service_account.json')
        app = firebase_admin.initialize_app(cred, {'storageBucket': 'diving-app-8fa28.firebasestorage.app'})
    
    # Initialize Firestore
    db = firestore.client()
    
    # Get all lessons
    lessons = db.collection('lessons').stream()
    lesson_docs = list(lessons)
    
    # Sort lessons by ID (which contains timestamp)
    sorted_lessons = sorted(lesson_docs, key=lambda doc: doc.id, reverse=True)
    
    # HTML output
    html_output = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Logit LMS - Available Lessons</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
            h1 { color: #2c3e50; }
            .lesson { border: 1px solid #ddd; margin-bottom: 20px; padding: 15px; border-radius: 5px; }
            .lesson-title { font-size: 1.5em; font-weight: bold; margin-bottom: 10px; color: #3498db; }
            .slide { margin-bottom: 5px; padding: 5px; background-color: #f9f9f9; }
            .images { display: flex; flex-wrap: wrap; margin-top: 10px; }
            .image-container { margin: 5px; text-align: center; }
            img { max-width: 200px; max-height: 150px; border: 1px solid #ddd; border-radius: 3px; }
            .timestamp { font-size: 0.8em; color: #7f8c8d; margin-top: 5px; }
        </style>
    </head>
    <body>
        <h1>Logit LMS - Available Lessons</h1>
        <p>Generated on: """ + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + """</p>
    """
    
    # Only display the 10 most recent lessons
    for lesson_doc in sorted_lessons[:10]:
        lesson_data = lesson_doc.to_dict()
        lesson_id = lesson_doc.id
        
        # Extract timestamp from lesson ID
        timestamp_part = lesson_id.split('_')[1] if '_' in lesson_id else ""
        formatted_date = ""
        if timestamp_part and len(timestamp_part) >= 8:
            try:
                year = timestamp_part[:4]
                month = timestamp_part[4:6]
                day = timestamp_part[6:8]
                formatted_date = f"{year}-{month}-{day}"
            except:
                formatted_date = "Unknown date"
        
        html_output += f"""
        <div class="lesson">
            <div class="lesson-title">{lesson_data.get('title', 'Unnamed Lesson')}</div>
            <div>ID: {lesson_id}</div>
            <div class="timestamp">Uploaded: {formatted_date}</div>
        """
        
        # Get slides for this lesson
        slides = db.collection('lessons').document(lesson_id).collection('slides').stream()
        slides_list = list(slides)
        
        # Sort slides by slide number
        slides_list = sorted(slides_list, key=lambda slide: slide.to_dict().get('slideNumber', 0))
        
        html_output += f"<p>Contains {len(slides_list)} slides</p>"
        
        # Display first few slides
        display_slides = slides_list[:3] if len(slides_list) > 3 else slides_list
        
        html_output += "<h3>Preview:</h3>"
        
        for slide in display_slides:
            slide_data = slide.to_dict()
            slide_number = slide_data.get('slideNumber', 'Unknown')
            slide_title = slide_data.get('title', 'No title')
            
            # Truncate title if too long
            if len(slide_title) > 100:
                slide_title = slide_title[:100] + "..."
            
            html_output += f"""
            <div class="slide">
                <strong>Slide {slide_number}</strong>: {slide_title}
            </div>
            """
            
            # Display images in this slide
            images = slide_data.get('images', [])
            if images:
                html_output += '<div class="images">'
                
                for image in images:
                    url = image.get('url', '#')
                    filename = image.get('filename', 'image')
                    
                    html_output += f"""
                    <div class="image-container">
                        <img src="{url}" alt="{filename}">
                        <div>{filename}</div>
                    </div>
                    """
                
                html_output += '</div>'
        
        html_output += "</div>"
    
    html_output += """
    </body>
    </html>
    """
    
    # Save HTML to file
    with open('lesson_list_for_students.html', 'w') as f:
        f.write(html_output)
    
    print("Generated lesson list for students at: lesson_list_for_students.html")
    
    # Also generate a simple JSON file with lesson data
    lessons_json = []
    
    for lesson_doc in sorted_lessons[:10]:
        lesson_data = lesson_doc.to_dict()
        lesson_id = lesson_doc.id
        
        lesson_json = {
            "id": lesson_id,
            "title": lesson_data.get('title', 'Unnamed Lesson'),
            "code": lesson_data.get('code', ''),
            "slides_count": 0,
            "images_count": 0,
            "preview": []
        }
        
        # Get slides for this lesson
        slides = db.collection('lessons').document(lesson_id).collection('slides').stream()
        slides_list = list(slides)
        
        # Count images
        total_images = 0
        
        # Sort slides by slide number
        slides_list = sorted(slides_list, key=lambda slide: slide.to_dict().get('slideNumber', 0))
        
        lesson_json["slides_count"] = len(slides_list)
        
        # Get preview of first 3 slides
        preview_slides = slides_list[:3] if len(slides_list) > 3 else slides_list
        
        for slide in preview_slides:
            slide_data = slide.to_dict()
            
            slide_images = slide_data.get('images', [])
            total_images += len(slide_images)
            
            preview_slide = {
                "slideNumber": slide_data.get('slideNumber', 0),
                "title": slide_data.get('title', ''),
                "imageCount": len(slide_images),
                "imageUrls": [img.get('url', '') for img in slide_images]
            }
            
            lesson_json["preview"].append(preview_slide)
        
        lesson_json["images_count"] = total_images
        lessons_json.append(lesson_json)
    
    # Save JSON to file
    with open('lesson_list_for_students.json', 'w') as f:
        json.dump(lessons_json, f, indent=2)
    
    print("Generated lesson data JSON at: lesson_list_for_students.json")

if __name__ == "__main__":
    list_lessons_for_students() 