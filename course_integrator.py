#!/usr/bin/env python3
"""
Course Integrator for Digital Master Training LMS

This script integrates the extracted lesson plans into the existing course structure,
creating a comprehensive Diver Medic Training (DMT) course with proper modules and lessons.

Author: AI Assistant
Date: 2024
"""

import os
import json
import uuid
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime

class CourseIntegrator:
    """Integrates extracted lesson plans into the LMS course structure."""
    
    def __init__(self, lesson_plans_dir: str, output_dir: str):
        """
        Initialize the course integrator.
        
        Args:
            lesson_plans_dir: Directory containing extracted lesson plan JSON files
            output_dir: Directory where integrated course files will be saved
        """
        self.lesson_plans_dir = Path(lesson_plans_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
        # Course configuration
        self.course_id = str(uuid.uuid4())
        self.course_title = "Diver Medic Training (DMT) - Complete Course"
        self.course_description = "Comprehensive medical training program for Diver Medic Technicians (DMTs) and Medical First Aiders (MFAs). Covers accident management, medical emergencies, and essential medical procedures for diving operations."
        
        # Collections to store integrated data
        self.integrated_course = None
        self.integrated_modules = []
        self.integrated_lessons = []
        self.integrated_slides = []
        
    def generate_id(self) -> str:
        """Generate a unique ID."""
        return str(uuid.uuid4())
    
    def get_current_timestamp(self) -> str:
        """Get current timestamp in ISO format."""
        return datetime.now().isoformat() + "+00:00"
    
    def load_lesson_plans(self) -> Dict[str, Dict[str, Any]]:
        """Load all lesson plan JSON files."""
        lesson_plans = {}
        
        for lesson_file in sorted(self.lesson_plans_dir.glob("lesson_plan_*.json")):
            try:
                with open(lesson_file, 'r', encoding='utf-8') as f:
                    lesson_data = json.load(f)
                    lesson_plans[lesson_file.name] = lesson_data
                    print(f"✓ Loaded: {lesson_file.name}")
            except Exception as e:
                print(f"✗ Error loading {lesson_file.name}: {e}")
        
        return lesson_plans
    
    def create_slide_from_lesson_slide(self, lesson_slide: Dict[str, Any], lesson_id: str) -> Dict[str, Any]:
        """Convert lesson slide to LMS slide format."""
        slide_id = self.generate_id()
        timestamp = self.get_current_timestamp()
        
        # Format content as HTML-like structure
        content_html = ""
        if lesson_slide.get('content'):
            content_html = "<ul>"
            for item in lesson_slide['content']:
                content_html += f"<li>{item}</li>"
            content_html += "</ul>"
        
        slide = {
            "_id": slide_id,
            "_path": f"slides/{slide_id}",
            "_collection": "slides",
            "title": lesson_slide.get('title', ''),
            "content": content_html,
            "slideNumber": lesson_slide.get('slideNumber', 1),
            "lessonId": lesson_id,
            "images": lesson_slide.get('images', []),
            "createdAt": timestamp,
            "updatedAt": timestamp,
            "sourceType": "lesson_plan_extraction"
        }
        
        return slide
    
    def create_lesson_from_plan(self, lesson_plan: Dict[str, Any], module_id: str, order: int) -> Dict[str, Any]:
        """Convert lesson plan to LMS lesson format."""
        lesson_id = self.generate_id()
        timestamp = self.get_current_timestamp()
        
        # Create slides for this lesson
        slide_ids = []
        lesson_slides = lesson_plan.get('slides', [])
        
        for slide_data in lesson_slides:
            slide = self.create_slide_from_lesson_slide(slide_data, lesson_id)
            self.integrated_slides.append(slide)
            slide_ids.append(slide['_id'])
        
        lesson = {
            "_id": lesson_id,
            "_path": f"lessons/{lesson_id}",
            "_collection": "lessons",
            "title": lesson_plan.get('title', ''),
            "description": lesson_plan.get('description', ''),
            "duration": lesson_plan.get('duration', ''),
            "target_audience": lesson_plan.get('target_audience', ''),
            "objectives": lesson_plan.get('objectives', []),
            "materials": lesson_plan.get('materials', []),
            "activities": lesson_plan.get('activities', []),
            "assessment": lesson_plan.get('assessment', []),
            "slideIds": slide_ids,
            "contentType": "slide",
            "moduleId": module_id,
            "order": order,
            "createdAt": timestamp,
            "updatedAt": timestamp,
            "sourceType": "lesson_plan_extraction",
            "metadata": lesson_plan.get('metadata', {})
        }
        
        return lesson
    
    def group_lessons_into_modules(self, lesson_plans: Dict[str, Dict[str, Any]]) -> List[Dict[str, List[str]]]:
        """Group lessons into logical modules based on content similarity."""
        
        # Define module groupings based on lesson content
        module_groups = [
            {
                "title": "Accident Management Fundamentals",
                "description": "Core principles of accident management including bleeding control, soft tissue injuries, and shock management",
                "lessons": ["lesson_plan_01.json"]  # Lesson 1: Principles, Bleeding, Soft tissue and Shock
            },
            {
                "title": "Trauma and Injury Management",
                "description": "Advanced trauma management covering fractures, crush injuries, and chest trauma",
                "lessons": ["lesson_plan_02.json"]  # Lesson 2: Fractures, Crush Injuries, Chest Trauma
            },
            {
                "title": "Burns and Environmental Injuries",
                "description": "Management of burns, electrical injuries, and poisoning incidents",
                "lessons": ["lesson_plan_03.json"]  # Lesson 3: Burns, Electrical Injury and Poisoning
            },
            {
                "title": "Patient Assessment",
                "description": "Systematic approach to casualty assessment and triage",
                "lessons": ["lesson_plan_04.json"]  # Lesson 4: Casualty Assessment
            },
            {
                "title": "Medical Emergency Response",
                "description": "Management of medical emergencies in diving operations",
                "lessons": ["lesson_plan_05.json"]  # Lesson 5: Management of Medical Emergencies
            },
            {
                "title": "Vascular Access Procedures",
                "description": "Cannulation techniques and vascular access procedures",
                "lessons": ["lesson_plan_06.json"]  # Lesson 6: Cannulation
            },
            {
                "title": "Urological Procedures",
                "description": "Urethral catheterization procedures and techniques",
                "lessons": ["lesson_plan_07.json"]  # Lesson 7: Urethral Catheterisation
            },
            {
                "title": "Airway Management",
                "description": "Advanced airway management techniques and procedures",
                "lessons": ["lesson_plan_08.json"]  # Lesson 8: Airway Management
            },
            {
                "title": "Thoracic Procedures",
                "description": "Chest drain insertion and thoracentesis procedures",
                "lessons": ["lesson_plan_09.json"]  # Lesson 9: Chest Drain -Thoracentesis
            },
            {
                "title": "Surgical Procedures",
                "description": "Basic suturing techniques and wound closure",
                "lessons": ["lesson_plan_10.json"]  # Lesson 10: Suturing
            },
            {
                "title": "Pharmacology and Drug Administration",
                "description": "Drug administration techniques and pharmacological principles",
                "lessons": ["lesson_plan_11.json"]  # Lesson 11: Drug Administration
            },
            {
                "title": "Diving Medical Advisory Service (DMAS)",
                "description": "DMAS protocols and procedures for diving medical support",
                "lessons": ["lesson_plan_12.json"]  # Lesson 12: DMAS
            }
        ]
        
        return module_groups
    
    def create_module_from_group(self, group: Dict[str, Any], lesson_plans: Dict[str, Dict[str, Any]], order: int) -> Dict[str, Any]:
        """Create a module from a lesson group."""
        module_id = self.generate_id()
        timestamp = self.get_current_timestamp()
        
        lesson_ids = []
        lesson_order = 1
        
        # Create lessons for this module
        for lesson_file in group['lessons']:
            if lesson_file in lesson_plans:
                lesson = self.create_lesson_from_plan(
                    lesson_plans[lesson_file], 
                    module_id, 
                    lesson_order
                )
                self.integrated_lessons.append(lesson)
                lesson_ids.append(lesson['_id'])
                lesson_order += 1
        
        module = {
            "_id": module_id,
            "_path": f"modules/{module_id}",
            "_collection": "modules",
            "title": group['title'],
            "description": group['description'],
            "courseId": self.course_id,
            "lessonIds": lesson_ids,
            "testIds": [],
            "questionIds": [],
            "order": order,
            "createdAt": timestamp,
            "updatedAt": timestamp,
            "sourceType": "lesson_plan_extraction"
        }
        
        return module
    
    def create_course(self, module_ids: List[str]) -> Dict[str, Any]:
        """Create the main course structure."""
        timestamp = self.get_current_timestamp()
        
        course = {
            "_id": self.course_id,
            "_path": f"courses/{self.course_id}",
            "_collection": "courses",
            "title": self.course_title,
            "description": self.course_description,
            "instructor": "Digital Master Training",
            "categories": ["medical", "diving", "emergency", "training"],
            "price": 0.0,
            "isFree": True,
            "rating": 5.0,
            "totalStudents": 0,
            "isAvailable": True,
            "status": "active",
            "imageUrl": "https://picsum.photos/id/1031/500/300",  # Medical/diving themed image
            "modules": module_ids,
            "createdAt": timestamp,
            "updatedAt": timestamp,
            "sourceType": "lesson_plan_extraction",
            "metadata": {
                "total_lessons": len(self.integrated_lessons),
                "total_slides": len(self.integrated_slides),
                "extraction_date": timestamp,
                "target_audience": "DMTs and MFAs"
            }
        }
        
        return course
    
    def integrate_lesson_plans(self) -> Dict[str, Any]:
        """Main integration process."""
        print("🚀 Digital Master Training - Course Integrator")
        print("=" * 60)
        print(f"📁 Source directory: {self.lesson_plans_dir}")
        print(f"📁 Output directory: {self.output_dir}")
        print()
        
        # Load lesson plans
        print("📚 Loading lesson plans...")
        lesson_plans = self.load_lesson_plans()
        
        if not lesson_plans:
            print("❌ No lesson plans found!")
            return {}
        
        print(f"✅ Loaded {len(lesson_plans)} lesson plans")
        print()
        
        # Group lessons into modules
        print("📦 Creating modules...")
        module_groups = self.group_lessons_into_modules(lesson_plans)
        
        module_ids = []
        for i, group in enumerate(module_groups, 1):
            module = self.create_module_from_group(group, lesson_plans, i)
            self.integrated_modules.append(module)
            module_ids.append(module['_id'])
            print(f"  ✓ Module {i}: {group['title']} ({len(group['lessons'])} lessons)")
        
        print()
        
        # Create main course
        print("🎓 Creating course...")
        self.integrated_course = self.create_course(module_ids)
        print(f"  ✓ Course: {self.course_title}")
        print()
        
        # Generate summary
        summary = {
            "course": self.integrated_course,
            "modules": self.integrated_modules,
            "lessons": self.integrated_lessons,
            "slides": self.integrated_slides,
            "statistics": {
                "total_modules": len(self.integrated_modules),
                "total_lessons": len(self.integrated_lessons),
                "total_slides": len(self.integrated_slides),
                "integration_date": self.get_current_timestamp()
            }
        }
        
        return summary
    
    def save_integrated_data(self, integrated_data: Dict[str, Any]):
        """Save integrated data to separate JSON files."""
        print("💾 Saving integrated data...")
        
        # Save course
        course_file = self.output_dir / "dmt_course.json"
        with open(course_file, 'w', encoding='utf-8') as f:
            json.dump(integrated_data['course'], f, indent=2, ensure_ascii=False)
        print(f"  ✓ Course saved to: {course_file.name}")
        
        # Save modules
        modules_file = self.output_dir / "dmt_modules.json"
        with open(modules_file, 'w', encoding='utf-8') as f:
            json.dump(integrated_data['modules'], f, indent=2, ensure_ascii=False)
        print(f"  ✓ Modules saved to: {modules_file.name}")
        
        # Save lessons
        lessons_file = self.output_dir / "dmt_lessons.json"
        with open(lessons_file, 'w', encoding='utf-8') as f:
            json.dump(integrated_data['lessons'], f, indent=2, ensure_ascii=False)
        print(f"  ✓ Lessons saved to: {lessons_file.name}")
        
        # Save slides
        slides_file = self.output_dir / "dmt_slides.json"
        with open(slides_file, 'w', encoding='utf-8') as f:
            json.dump(integrated_data['slides'], f, indent=2, ensure_ascii=False)
        print(f"  ✓ Slides saved to: {slides_file.name}")
        
        # Save complete integrated dataset
        complete_file = self.output_dir / "dmt_complete_course.json"
        with open(complete_file, 'w', encoding='utf-8') as f:
            json.dump(integrated_data, f, indent=2, ensure_ascii=False)
        print(f"  ✓ Complete dataset saved to: {complete_file.name}")
        
        # Save statistics
        stats_file = self.output_dir / "integration_statistics.json"
        with open(stats_file, 'w', encoding='utf-8') as f:
            json.dump(integrated_data['statistics'], f, indent=2, ensure_ascii=False)
        print(f"  ✓ Statistics saved to: {stats_file.name}")
        
        print()
        
    def create_import_instructions(self):
        """Create instructions for importing the course into the LMS."""
        instructions = """
# DMT Course Import Instructions

## Files Generated
- `dmt_course.json` - Main course definition
- `dmt_modules.json` - All 12 modules 
- `dmt_lessons.json` - All lessons with objectives and activities
- `dmt_slides.json` - All slide content
- `dmt_complete_course.json` - Complete integrated dataset
- `integration_statistics.json` - Import statistics

## Integration Steps

### Option 1: Manual Integration
1. Add the course from `dmt_course.json` to your courses collection
2. Add all modules from `dmt_modules.json` to your modules collection  
3. Add all lessons from `dmt_lessons.json` to your lessons collection
4. Add all slides from `dmt_slides.json` to your slides collection

### Option 2: Programmatic Integration
```python
import json

# Load the complete dataset
with open('dmt_complete_course.json', 'r') as f:
    dmt_data = json.load(f)

# Add to your existing collections
courses.append(dmt_data['course'])
modules.extend(dmt_data['modules'])
lessons.extend(dmt_data['lessons'])
slides.extend(dmt_data['slides'])
```

## Course Structure
- **Course**: Diver Medic Training (DMT) - Complete Course
- **Modules**: 12 specialized medical training modules
- **Lessons**: 12 comprehensive lesson plans
- **Slides**: Multiple slides per lesson with structured content

## Features
- ✅ Complete lesson objectives
- ✅ Materials lists
- ✅ Step-by-step activities
- ✅ Assessment criteria (Red/Amber/Green)
- ✅ Target audience specification
- ✅ Duration information
- ✅ Slide-based content delivery

## Target Audience
- Diver Medic Technicians (DMTs)
- Medical First Aiders (MFAs)
- Diving medical personnel
"""
        
        instructions_file = self.output_dir / "IMPORT_INSTRUCTIONS.md"
        with open(instructions_file, 'w', encoding='utf-8') as f:
            f.write(instructions)
        
        print(f"📋 Import instructions saved to: {instructions_file.name}")


def main():
    """Main function to run the course integration."""
    
    # Configuration
    lesson_plans_dir = "/Users/mac/dev/logit_LMS/extracted_lesson_plans"
    output_dir = "/Users/mac/dev/logit_LMS/integrated_course"
    
    # Initialize integrator
    integrator = CourseIntegrator(lesson_plans_dir, output_dir)
    
    # Integrate lesson plans
    integrated_data = integrator.integrate_lesson_plans()
    
    if integrated_data:
        # Save integrated data
        integrator.save_integrated_data(integrated_data)
        
        # Create import instructions
        integrator.create_import_instructions()
        
        print("=" * 60)
        print("✅ Course Integration Complete!")
        print()
        print("📊 Summary:")
        print(f"   📚 Course: {integrator.course_title}")
        print(f"   📦 Modules: {integrated_data['statistics']['total_modules']}")
        print(f"   📄 Lessons: {integrated_data['statistics']['total_lessons']}")
        print(f"   🎯 Slides: {integrated_data['statistics']['total_slides']}")
        print()
        print(f"🎯 All files saved to: {output_dir}")
        print("📋 See IMPORT_INSTRUCTIONS.md for integration steps")
        
    else:
        print("❌ Course integration failed")


if __name__ == "__main__":
    main()
