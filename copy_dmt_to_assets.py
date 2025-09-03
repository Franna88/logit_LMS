#!/usr/bin/env python3
"""
Copy DMT course data to Flutter assets

This script copies the integrated DMT course data to the Flutter assets folder
so the app can properly load the lesson plans and course content.
"""

import json
import shutil
from pathlib import Path

def main():
    print("🔄 Copying DMT course data to Flutter assets...")
    
    # Paths
    base_dir = Path("/Users/mac/dev/logit_LMS")
    integrated_dir = base_dir / "integrated_course"
    assets_dir = base_dir / "lib" / "assets" / "output" / "images"
    
    # Load the complete DMT course data
    dmt_complete_file = integrated_dir / "dmt_complete_course.json"
    
    if not dmt_complete_file.exists():
        print(f"❌ DMT course data not found at {dmt_complete_file}")
        return
    
    with open(dmt_complete_file, 'r', encoding='utf-8') as f:
        dmt_data = json.load(f)
    
    print(f"✅ Loaded DMT course data with {len(dmt_data['modules'])} modules")
    
    # Load existing data files
    courses_file = assets_dir / "courses.json"
    modules_file = assets_dir / "modules.json"
    lessons_file = assets_dir / "lessons.json"
    slides_file = assets_dir / "slides.json"
    
    # Load existing courses
    with open(courses_file, 'r', encoding='utf-8') as f:
        courses = json.load(f)
    
    # Load existing modules
    with open(modules_file, 'r', encoding='utf-8') as f:
        modules = json.load(f)
    
    # Load existing lessons
    with open(lessons_file, 'r', encoding='utf-8') as f:
        lessons = json.load(f)
    
    # Load existing slides
    with open(slides_file, 'r', encoding='utf-8') as f:
        slides = json.load(f)
    
    print(f"📊 Current data: {len(courses)} courses, {len(modules)} modules, {len(lessons)} lessons, {len(slides)} slides")
    
    # Check if DMT course already exists
    dmt_course_exists = any(
        course.get('title', '').startswith('Diver Medic Training') 
        for course in courses
    )
    
    if dmt_course_exists:
        print("⚠️  DMT course already exists, removing old version...")
        # Remove old DMT course and related data
        dmt_course_id = None
        courses = [course for course in courses if not course.get('title', '').startswith('Diver Medic Training')]
        
        # Find and remove related modules, lessons, slides
        for course in courses:
            if course.get('title', '').startswith('Diver Medic Training'):
                dmt_course_id = course.get('_id')
                break
        
        if dmt_course_id:
            modules = [mod for mod in modules if mod.get('courseId') != dmt_course_id]
            # Get module IDs to remove lessons and slides
            dmt_module_ids = [mod['_id'] for mod in dmt_data['modules']]
            lessons = [lesson for lesson in lessons if lesson.get('moduleId') not in dmt_module_ids]
            dmt_lesson_ids = [lesson['_id'] for lesson in dmt_data['lessons']]
            slides = [slide for slide in slides if slide.get('lessonId') not in dmt_lesson_ids]
    
    # Add DMT course data
    courses.append(dmt_data['course'])
    modules.extend(dmt_data['modules'])
    lessons.extend(dmt_data['lessons'])
    slides.extend(dmt_data['slides'])
    
    print(f"✅ Updated data: {len(courses)} courses, {len(modules)} modules, {len(lessons)} lessons, {len(slides)} slides")
    
    # Save updated data
    with open(courses_file, 'w', encoding='utf-8') as f:
        json.dump(courses, f, indent=2, ensure_ascii=False)
    
    with open(modules_file, 'w', encoding='utf-8') as f:
        json.dump(modules, f, indent=2, ensure_ascii=False)
    
    with open(lessons_file, 'w', encoding='utf-8') as f:
        json.dump(lessons, f, indent=2, ensure_ascii=False)
    
    with open(slides_file, 'w', encoding='utf-8') as f:
        json.dump(slides, f, indent=2, ensure_ascii=False)
    
    print("💾 All data files updated successfully!")
    print("\n🎯 DMT Course Integration Complete!")
    print("The Flutter app should now be able to load the DMT course and lesson plans.")
    
    # Show summary
    print(f"\n📋 DMT Course Summary:")
    print(f"   📚 Course: {dmt_data['course']['title']}")
    print(f"   📦 Modules: {len(dmt_data['modules'])}")
    print(f"   📄 Lessons: {len(dmt_data['lessons'])}")
    print(f"   🎯 Slides: {len(dmt_data['slides'])}")

if __name__ == "__main__":
    main()
