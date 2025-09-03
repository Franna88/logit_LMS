#!/usr/bin/env python3
"""
DMT Course Integration Script for Flutter LMS

This script integrates the extracted DMT course into your existing LMS data files.
It will add the new course, modules, lessons, and slides to your current collections
while maintaining data integrity and creating backups.

Author: AI Assistant
Date: 2024
"""

import os
import json
import shutil
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime

class DMTCourseIntegrator:
    """Integrates DMT course into existing LMS data files."""
    
    def __init__(self):
        """Initialize the integrator with file paths."""
        self.base_dir = Path("/Users/mac/dev/logit_LMS")
        self.assets_dir = self.base_dir / "lib" / "assets" / "output" / "images"
        self.integrated_dir = self.base_dir / "integrated_course"
        self.backup_dir = self.base_dir / "backup_before_dmt_integration"
        
        # Data file paths
        self.data_files = {
            'courses': self.assets_dir / 'courses.json',
            'modules': self.assets_dir / 'modules.json', 
            'lessons': self.assets_dir / 'lessons.json',
            'slides': self.assets_dir / 'slides.json'
        }
        
        # DMT data file path
        self.dmt_data_file = self.integrated_dir / 'dmt_complete_course.json'
    
    def create_backup(self):
        """Create backup of existing data files."""
        print("📋 Creating backup of existing data files...")
        
        # Create backup directory
        self.backup_dir.mkdir(exist_ok=True)
        
        # Copy each data file to backup
        for name, file_path in self.data_files.items():
            if file_path.exists():
                backup_path = self.backup_dir / f"{name}_backup.json"
                shutil.copy2(file_path, backup_path)
                print(f"  ✓ Backed up {name}.json")
            else:
                print(f"  ⚠️  {name}.json not found - will create new")
        
        print(f"  📁 Backup saved to: {self.backup_dir}")
        print()
    
    def load_existing_data(self) -> Dict[str, List[Dict[str, Any]]]:
        """Load existing LMS data."""
        print("📚 Loading existing LMS data...")
        
        existing_data = {}
        
        for name, file_path in self.data_files.items():
            try:
                if file_path.exists():
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        existing_data[name] = data if isinstance(data, list) else [data]
                        print(f"  ✓ Loaded {len(existing_data[name])} {name}")
                else:
                    existing_data[name] = []
                    print(f"  ⚠️  {name}.json not found - starting with empty list")
            except Exception as e:
                print(f"  ✗ Error loading {name}: {e}")
                existing_data[name] = []
        
        print()
        return existing_data
    
    def load_dmt_data(self) -> Dict[str, Any]:
        """Load DMT course data."""
        print("🏥 Loading DMT course data...")
        
        try:
            with open(self.dmt_data_file, 'r', encoding='utf-8') as f:
                dmt_data = json.load(f)
                print(f"  ✓ Loaded DMT course with:")
                print(f"    - 1 course: {dmt_data['course']['title']}")
                print(f"    - {len(dmt_data['modules'])} modules")
                print(f"    - {len(dmt_data['lessons'])} lessons") 
                print(f"    - {len(dmt_data['slides'])} slides")
                print()
                return dmt_data
        except Exception as e:
            print(f"  ✗ Error loading DMT data: {e}")
            return {}
    
    def check_for_conflicts(self, existing_data: Dict[str, List], dmt_data: Dict[str, Any]) -> bool:
        """Check for ID conflicts between existing and new data."""
        print("🔍 Checking for ID conflicts...")
        
        conflicts_found = False
        
        # Check course ID
        course_id = dmt_data['course']['_id']
        existing_course_ids = [course['_id'] for course in existing_data['courses']]
        if course_id in existing_course_ids:
            print(f"  ⚠️  Course ID conflict: {course_id}")
            conflicts_found = True
        
        # Check module IDs
        for module in dmt_data['modules']:
            module_id = module['_id']
            existing_module_ids = [mod['_id'] for mod in existing_data['modules']]
            if module_id in existing_module_ids:
                print(f"  ⚠️  Module ID conflict: {module_id}")
                conflicts_found = True
        
        # Check lesson IDs
        for lesson in dmt_data['lessons']:
            lesson_id = lesson['_id']
            existing_lesson_ids = [les['_id'] for les in existing_data['lessons']]
            if lesson_id in existing_lesson_ids:
                print(f"  ⚠️  Lesson ID conflict: {lesson_id}")
                conflicts_found = True
        
        # Check slide IDs
        for slide in dmt_data['slides']:
            slide_id = slide['_id']
            existing_slide_ids = [sl['_id'] for sl in existing_data['slides']]
            if slide_id in existing_slide_ids:
                print(f"  ⚠️  Slide ID conflict: {slide_id}")
                conflicts_found = True
        
        if not conflicts_found:
            print("  ✅ No ID conflicts found - safe to proceed")
        else:
            print("  ❌ ID conflicts detected - integration may overwrite existing data")
        
        print()
        return conflicts_found
    
    def integrate_data(self, existing_data: Dict[str, List], dmt_data: Dict[str, Any]) -> Dict[str, List]:
        """Integrate DMT data with existing data."""
        print("🔧 Integrating DMT course data...")
        
        # Create integrated data structure
        integrated_data = {
            'courses': existing_data['courses'].copy(),
            'modules': existing_data['modules'].copy(), 
            'lessons': existing_data['lessons'].copy(),
            'slides': existing_data['slides'].copy()
        }
        
        # Add DMT course
        integrated_data['courses'].append(dmt_data['course'])
        print(f"  ✓ Added course: {dmt_data['course']['title']}")
        
        # Add DMT modules
        integrated_data['modules'].extend(dmt_data['modules'])
        print(f"  ✓ Added {len(dmt_data['modules'])} modules")
        
        # Add DMT lessons
        integrated_data['lessons'].extend(dmt_data['lessons'])
        print(f"  ✓ Added {len(dmt_data['lessons'])} lessons")
        
        # Add DMT slides
        integrated_data['slides'].extend(dmt_data['slides'])
        print(f"  ✓ Added {len(dmt_data['slides'])} slides")
        
        print()
        return integrated_data
    
    def validate_integration(self, integrated_data: Dict[str, List], dmt_data: Dict[str, Any]) -> bool:
        """Validate the integrated data."""
        print("✅ Validating integration...")
        
        validation_passed = True
        
        # Check total counts
        expected_courses = len(integrated_data['courses'])
        expected_modules = len(integrated_data['modules'])
        expected_lessons = len(integrated_data['lessons'])
        expected_slides = len(integrated_data['slides'])
        
        print(f"  📊 Final counts:")
        print(f"    - Courses: {expected_courses}")
        print(f"    - Modules: {expected_modules}")
        print(f"    - Lessons: {expected_lessons}")
        print(f"    - Slides: {expected_slides}")
        
        # Validate DMT course exists
        dmt_course_found = any(course['_id'] == dmt_data['course']['_id'] 
                              for course in integrated_data['courses'])
        if dmt_course_found:
            print("  ✓ DMT course successfully added")
        else:
            print("  ✗ DMT course not found in integrated data")
            validation_passed = False
        
        # Validate module relationships
        dmt_course_id = dmt_data['course']['_id']
        dmt_modules_in_data = [mod for mod in integrated_data['modules'] 
                              if mod.get('courseId') == dmt_course_id]
        
        if len(dmt_modules_in_data) == len(dmt_data['modules']):
            print(f"  ✓ All {len(dmt_data['modules'])} DMT modules properly linked")
        else:
            print(f"  ✗ Module count mismatch: expected {len(dmt_data['modules'])}, found {len(dmt_modules_in_data)}")
            validation_passed = False
        
        print()
        return validation_passed
    
    def save_integrated_data(self, integrated_data: Dict[str, List]):
        """Save the integrated data back to the original files."""
        print("💾 Saving integrated data...")
        
        for name, data in integrated_data.items():
            file_path = self.data_files[name]
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                print(f"  ✓ Saved {name}.json ({len(data)} items)")
            except Exception as e:
                print(f"  ✗ Error saving {name}.json: {e}")
        
        print()
    
    def create_integration_report(self, integrated_data: Dict[str, List], dmt_data: Dict[str, Any]):
        """Create a report of the integration."""
        report = {
            "integration_date": datetime.now().isoformat(),
            "dmt_course_id": dmt_data['course']['_id'],
            "dmt_course_title": dmt_data['course']['title'],
            "integration_summary": {
                "courses_added": 1,
                "modules_added": len(dmt_data['modules']),
                "lessons_added": len(dmt_data['lessons']),
                "slides_added": len(dmt_data['slides'])
            },
            "final_totals": {
                "total_courses": len(integrated_data['courses']),
                "total_modules": len(integrated_data['modules']),
                "total_lessons": len(integrated_data['lessons']),
                "total_slides": len(integrated_data['slides'])
            },
            "dmt_module_titles": [module['title'] for module in dmt_data['modules']],
            "backup_location": str(self.backup_dir)
        }
        
        report_file = self.base_dir / "dmt_integration_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print(f"📋 Integration report saved to: {report_file.name}")
        return report
    
    def run_integration(self) -> bool:
        """Run the complete integration process."""
        print("🚀 DMT Course Integration - Flutter LMS")
        print("=" * 60)
        print()
        
        try:
            # Step 1: Create backup
            self.create_backup()
            
            # Step 2: Load existing data
            existing_data = self.load_existing_data()
            
            # Step 3: Load DMT data
            dmt_data = self.load_dmt_data()
            if not dmt_data:
                print("❌ Failed to load DMT data - aborting integration")
                return False
            
            # Step 4: Check for conflicts
            conflicts = self.check_for_conflicts(existing_data, dmt_data)
            if conflicts:
                response = input("⚠️  Conflicts detected. Continue anyway? (y/N): ")
                if response.lower() != 'y':
                    print("❌ Integration cancelled by user")
                    return False
            
            # Step 5: Integrate data
            integrated_data = self.integrate_data(existing_data, dmt_data)
            
            # Step 6: Validate integration
            if not self.validate_integration(integrated_data, dmt_data):
                print("❌ Integration validation failed")
                return False
            
            # Step 7: Save integrated data
            self.save_integrated_data(integrated_data)
            
            # Step 8: Create report
            report = self.create_integration_report(integrated_data, dmt_data)
            
            print("=" * 60)
            print("✅ DMT Course Integration Complete!")
            print()
            print("📊 Summary:")
            print(f"   📚 Added: {report['dmt_course_title']}")
            print(f"   📦 Modules: {report['integration_summary']['modules_added']}")
            print(f"   📄 Lessons: {report['integration_summary']['lessons_added']}")
            print(f"   🎯 Slides: {report['integration_summary']['slides_added']}")
            print()
            print("🎯 The DMT course is now available in your Flutter LMS!")
            print(f"📁 Backup files saved to: {self.backup_dir}")
            
            return True
            
        except Exception as e:
            print(f"❌ Integration failed with error: {e}")
            return False


def main():
    """Main function to run the integration."""
    integrator = DMTCourseIntegrator()
    success = integrator.run_integration()
    
    if success:
        print("\n🎉 Next Steps:")
        print("1. Run your Flutter app to test the integration")
        print("2. Check that the DMT course appears in your course list")
        print("3. Navigate through the modules and lessons to verify content")
        print("4. If issues arise, restore from backup files")
    else:
        print("\n❌ Integration failed - please check the error messages above")


if __name__ == "__main__":
    main()
