#!/usr/bin/env python3
"""
Lesson Plan Extractor for Digital Master Training LMS

This script extracts content from Word documents (.docx) in the Lesson_plans folder
and converts them into structured JSON files that can be integrated into the LMS.

Author: AI Assistant
Date: 2024
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Any, Optional
from docx import Document
from docx.document import Document as DocumentType
from docx.oxml.table import CT_Tbl
from docx.oxml.text.paragraph import CT_P
from docx.table import _Cell, Table
from docx.text.paragraph import Paragraph

class LessonPlanExtractor:
    """Extracts and structures lesson plan content from Word documents."""
    
    def __init__(self, lesson_plans_dir: str, output_dir: str):
        """
        Initialize the lesson plan extractor.
        
        Args:
            lesson_plans_dir: Directory containing the Word document lesson plans
            output_dir: Directory where JSON files will be saved
        """
        self.lesson_plans_dir = Path(lesson_plans_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def extract_lesson_number(self, filename: str) -> int:
        """Extract lesson number from filename."""
        match = re.search(r'Lesson Plan (\d+)', filename)
        return int(match.group(1)) if match else 0
    
    def clean_text(self, text: str) -> str:
        """Clean and normalize text content."""
        if not text:
            return ""
        
        # Remove excessive whitespace
        text = re.sub(r'\s+', ' ', text.strip())
        
        # Remove special characters that might cause JSON issues
        text = text.replace('\x0b', '\n')  # Vertical tab to newline
        text = text.replace('\x0c', '\n')  # Form feed to newline
        
        return text
    
    def extract_document_structure(self, doc: DocumentType) -> Dict[str, Any]:
        """
        Extract structured content from a Word document.
        
        Args:
            doc: python-docx Document object
            
        Returns:
            Dictionary containing structured lesson content
        """
        content = {
            'title': '',
            'lesson_number': 0,
            'objectives': [],
            'duration': '',
            'materials': [],
            'activities': [],
            'assessment': [],
            'content_sections': [],
            'raw_paragraphs': [],
            'tables': []
        }
        
        current_section = None
        current_content = []
        
        # Process all document elements
        for element in doc.element.body:
            if isinstance(element, CT_P):
                # Handle paragraphs
                paragraph = Paragraph(element, doc)
                text = self.clean_text(paragraph.text)
                
                if not text:
                    continue
                
                content['raw_paragraphs'].append(text)
                
                # Check if this is a section header
                if self.is_section_header(text):
                    # Save previous section
                    if current_section and current_content:
                        content['content_sections'].append({
                            'section': current_section,
                            'content': current_content
                        })
                    
                    # Start new section
                    current_section = text
                    current_content = []
                else:
                    # Add to current section or general content
                    if current_section:
                        current_content.append(text)
                    else:
                        # Try to categorize content
                        self.categorize_content(text, content)
                        
            elif isinstance(element, CT_Tbl):
                # Handle tables
                table = Table(element, doc)
                table_data = self.extract_table_data(table)
                if table_data:
                    content['tables'].append(table_data)
        
        # Don't forget the last section
        if current_section and current_content:
            content['content_sections'].append({
                'section': current_section,
                'content': current_content
            })
        
        return content
    
    def is_section_header(self, text: str) -> bool:
        """Determine if text is likely a section header."""
        # Common section headers in lesson plans
        headers = [
            'learning objectives', 'objectives', 'learning outcomes',
            'duration', 'time', 'materials', 'resources', 'equipment',
            'activities', 'lesson activities', 'procedures', 'steps',
            'assessment', 'evaluation', 'introduction', 'development',
            'conclusion', 'homework', 'assignment', 'safety', 'prerequisites'
        ]
        
        text_lower = text.lower().strip()
        
        # Check if it's all caps (common for headers)
        if text.isupper() and len(text) > 3:
            return True
            
        # Check if it matches common headers
        for header in headers:
            if header in text_lower:
                return True
                
        # Check if it's short and ends with colon
        if len(text) < 50 and text.endswith(':'):
            return True
            
        return False
    
    def categorize_content(self, text: str, content: Dict[str, Any]):
        """Categorize content into appropriate sections."""
        text_lower = text.lower()
        
        if any(word in text_lower for word in ['objective', 'goal', 'aim', 'outcome']):
            content['objectives'].append(text)
        elif any(word in text_lower for word in ['minute', 'hour', 'duration', 'time']):
            if not content['duration']:
                content['duration'] = text
        elif any(word in text_lower for word in ['material', 'equipment', 'resource', 'tool']):
            content['materials'].append(text)
        elif any(word in text_lower for word in ['assessment', 'test', 'quiz', 'evaluation']):
            content['assessment'].append(text)
        elif any(word in text_lower for word in ['activity', 'exercise', 'practice', 'step']):
            content['activities'].append(text)
    
    def extract_table_data(self, table: Table) -> Optional[Dict[str, Any]]:
        """Extract data from a table."""
        if not table.rows:
            return None
            
        table_data = {
            'headers': [],
            'rows': []
        }
        
        # Extract headers from first row
        first_row = table.rows[0]
        for cell in first_row.cells:
            table_data['headers'].append(self.clean_text(cell.text))
        
        # Extract data rows
        for row in table.rows[1:]:
            row_data = []
            for cell in row.cells:
                row_data.append(self.clean_text(cell.text))
            if any(row_data):  # Only add non-empty rows
                table_data['rows'].append(row_data)
        
        return table_data if table_data['rows'] else None
    
    def parse_table_content(self, tables: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Parse structured content from tables."""
        parsed_content = {
            'duration': '',
            'objectives': [],
            'materials': [],
            'procedures': [],
            'assessment': [],
            'target_audience': '',
            'learning_goals': []
        }
        
        for table in tables:
            headers = table.get('headers', [])
            rows = table.get('rows', [])
            
            # Process each table based on its headers
            if not headers or not rows:
                continue
                
            first_header = headers[0].upper() if headers else ''
            
            # Extract duration
            if 'LESSON DURATION' in first_header or any('DURATION' in str(row[0]).upper() for row in rows if row):
                for row in rows:
                    if row and len(row) > 1 and 'DURATION' in str(row[0]).upper():
                        parsed_content['duration'] = str(row[1]).strip()
                        break
            
            # Extract target audience
            if any('TARGET AUDIENCE' in str(row[0]).upper() for row in rows if row):
                for row in rows:
                    if row and len(row) > 1 and 'TARGET AUDIENCE' in str(row[0]).upper():
                        parsed_content['target_audience'] = str(row[1]).strip()
                        break
            
            # Extract objectives
            if 'MAIN OBJECTIVES' in first_header:
                for row in rows:
                    if row and row[0]:
                        parsed_content['objectives'].append(str(row[0]).strip())
            
            # Extract learning goals
            if 'LEARNING GOALS' in first_header:
                for row in rows:
                    if row and row[0]:
                        # Split learning goals by checkboxes or bullet points
                        goals_text = str(row[0]).strip()
                        # Split by checkbox symbols or bullet points
                        goals = re.split(r'☐|•|\n', goals_text)
                        for goal in goals:
                            goal = goal.strip()
                            if goal and len(goal) > 10:  # Only substantial goals
                                parsed_content['learning_goals'].append(goal)
            
            # Extract materials
            if 'MATERIALS' in first_header:
                for row in rows:
                    if row and row[0]:
                        materials_text = str(row[0]).strip()
                        # Split by common separators
                        materials = re.split(r'[,;]\s*|\sand\s+', materials_text)
                        for material in materials:
                            material = material.strip()
                            if material and len(material) > 3:
                                parsed_content['materials'].append(material)
            
            # Extract procedures
            if 'PROCEDURES' in first_header:
                for row in rows:
                    if row and row[0]:
                        procedures_text = str(row[0]).strip()
                        # Split by time markers or numbered steps
                        procedures = re.split(r'\d+(?:st|nd|rd|th)\s+\d+\s+minutes?\s*-\s*|\d+\.\s*', procedures_text)
                        for procedure in procedures:
                            procedure = procedure.strip()
                            if procedure and len(procedure) > 10:
                                parsed_content['procedures'].append(procedure)
            
            # Extract assessment criteria
            if 'ASSESSMENT' in first_header and 'GRADE' in str(rows[0] if rows else '').upper():
                for row in rows[1:]:  # Skip header row
                    if row and len(row) >= 2:
                        grade = str(row[0]).strip()
                        criteria = str(row[1]).strip()
                        if grade and criteria and grade.lower() in ['red', 'amber', 'green']:
                            parsed_content['assessment'].append({
                                'grade': grade,
                                'criteria': criteria
                            })
        
        return parsed_content

    def convert_to_lms_format(self, lesson_content: Dict[str, Any], filename: str) -> Dict[str, Any]:
        """
        Convert extracted content to LMS-compatible format.
        
        Args:
            lesson_content: Extracted lesson content
            filename: Original filename for reference
            
        Returns:
            LMS-compatible lesson structure
        """
        lesson_number = self.extract_lesson_number(filename)
        
        # Extract title from filename
        title_match = re.search(r'Lesson Plan \d+ - (.+)\.docx', filename)
        title = title_match.group(1) if title_match else f"Lesson {lesson_number}"
        
        # Parse table content for structured data
        parsed_tables = self.parse_table_content(lesson_content.get('tables', []))
        
        # Merge parsed table content with existing content
        objectives = lesson_content.get('objectives', []) + parsed_tables.get('objectives', []) + parsed_tables.get('learning_goals', [])
        materials = lesson_content.get('materials', []) + parsed_tables.get('materials', [])
        activities = lesson_content.get('activities', []) + parsed_tables.get('procedures', [])
        assessment = lesson_content.get('assessment', []) + parsed_tables.get('assessment', [])
        
        lms_lesson = {
            'lesson_id': f"lesson_{lesson_number:02d}",
            'title': title,
            'lesson_number': lesson_number,
            'description': self.generate_description_from_parsed(parsed_tables, lesson_content),
            'duration': parsed_tables.get('duration') or lesson_content.get('duration', ''),
            'target_audience': parsed_tables.get('target_audience', ''),
            'objectives': objectives,
            'materials': materials,
            'content_sections': lesson_content.get('content_sections', []),
            'activities': activities,
            'assessment': assessment,
            'tables': lesson_content.get('tables', []),
            'metadata': {
                'source_file': filename,
                'extraction_date': self.get_current_date(),
                'total_paragraphs': len(lesson_content.get('raw_paragraphs', [])),
                'total_sections': len(lesson_content.get('content_sections', [])),
                'total_tables': len(lesson_content.get('tables', []))
            },
            # For compatibility with existing slide-based lessons
            'slides': self.convert_to_slides_enhanced(lesson_content, title, parsed_tables)
        }
        
        return lms_lesson
    
    def generate_description_from_parsed(self, parsed_tables: Dict[str, Any], lesson_content: Dict[str, Any]) -> str:
        """Generate a description from parsed table content."""
        # Try parsed objectives first
        if parsed_tables.get('objectives'):
            return parsed_tables['objectives'][0]
        elif parsed_tables.get('learning_goals'):
            return parsed_tables['learning_goals'][0]
        elif lesson_content.get('objectives'):
            return lesson_content['objectives'][0]
        elif lesson_content.get('content_sections'):
            first_section = lesson_content['content_sections'][0]
            if first_section.get('content'):
                return first_section['content'][0]
        elif lesson_content.get('raw_paragraphs'):
            # Use first substantial paragraph
            for para in lesson_content['raw_paragraphs']:
                if len(para) > 50:
                    return para
        
        return "Medical training lesson plan"

    def generate_description(self, lesson_content: Dict[str, Any]) -> str:
        """Generate a description from lesson content."""
        # Use first objective or first content section as description
        if lesson_content.get('objectives'):
            return lesson_content['objectives'][0]
        elif lesson_content.get('content_sections'):
            first_section = lesson_content['content_sections'][0]
            if first_section.get('content'):
                return first_section['content'][0]
        elif lesson_content.get('raw_paragraphs'):
            # Use first substantial paragraph
            for para in lesson_content['raw_paragraphs']:
                if len(para) > 50:
                    return para
        
        return "Medical training lesson plan"
    
    def convert_to_slides(self, lesson_content: Dict[str, Any], title: str) -> List[Dict[str, Any]]:
        """Convert lesson content to slide format for compatibility."""
        slides = []
        slide_number = 1
        
        # Title slide
        slides.append({
            'slideNumber': slide_number,
            'title': title,
            'content': lesson_content.get('objectives', [])[:2],  # First 2 objectives
            'images': []
        })
        slide_number += 1
        
        # Content sections as slides
        for section in lesson_content.get('content_sections', []):
            slides.append({
                'slideNumber': slide_number,
                'title': section.get('section', f'Section {slide_number}'),
                'content': section.get('content', []),
                'images': []
            })
            slide_number += 1
        
        # Activities as slides
        if lesson_content.get('activities'):
            activities_per_slide = 3
            activity_chunks = [lesson_content['activities'][i:i + activities_per_slide] 
                             for i in range(0, len(lesson_content['activities']), activities_per_slide)]
            
            for i, chunk in enumerate(activity_chunks):
                slides.append({
                    'slideNumber': slide_number,
                    'title': f'Activities {i + 1}' if len(activity_chunks) > 1 else 'Activities',
                    'content': chunk,
                    'images': []
                })
                slide_number += 1
        
        # Assessment as final slide
        if lesson_content.get('assessment'):
            slides.append({
                'slideNumber': slide_number,
                'title': 'Assessment',
                'content': lesson_content['assessment'],
                'images': []
            })
        
        return slides
    
    def convert_to_slides_enhanced(self, lesson_content: Dict[str, Any], title: str, parsed_tables: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Convert lesson content to enhanced slide format using parsed table data."""
        slides = []
        slide_number = 1
        
        # Title slide with objectives
        objectives_content = parsed_tables.get('objectives', []) + parsed_tables.get('learning_goals', [])
        slides.append({
            'slideNumber': slide_number,
            'title': title,
            'content': [
                f"Duration: {parsed_tables.get('duration', 'Not specified')}",
                f"Target Audience: {parsed_tables.get('target_audience', 'Not specified')}"
            ] + objectives_content[:3],  # First 3 objectives
            'images': []
        })
        slide_number += 1
        
        # Learning objectives slide (if we have more than 3)
        if len(objectives_content) > 3:
            slides.append({
                'slideNumber': slide_number,
                'title': 'Learning Objectives',
                'content': objectives_content,
                'images': []
            })
            slide_number += 1
        
        # Materials slide
        if parsed_tables.get('materials'):
            slides.append({
                'slideNumber': slide_number,
                'title': 'Materials Required',
                'content': parsed_tables['materials'],
                'images': []
            })
            slide_number += 1
        
        # Procedures/Activities slides
        if parsed_tables.get('procedures'):
            procedures_per_slide = 2
            procedure_chunks = [parsed_tables['procedures'][i:i + procedures_per_slide] 
                              for i in range(0, len(parsed_tables['procedures']), procedures_per_slide)]
            
            for i, chunk in enumerate(procedure_chunks):
                slides.append({
                    'slideNumber': slide_number,
                    'title': f'Lesson Procedures {i + 1}' if len(procedure_chunks) > 1 else 'Lesson Procedures',
                    'content': chunk,
                    'images': []
                })
                slide_number += 1
        
        # Content sections as slides (if any)
        for section in lesson_content.get('content_sections', []):
            slides.append({
                'slideNumber': slide_number,
                'title': section.get('section', f'Section {slide_number}'),
                'content': section.get('content', []),
                'images': []
            })
            slide_number += 1
        
        # Assessment slide
        if parsed_tables.get('assessment'):
            assessment_content = []
            for assessment in parsed_tables['assessment']:
                if isinstance(assessment, dict):
                    assessment_content.append(f"{assessment.get('grade', '')}: {assessment.get('criteria', '')}")
                else:
                    assessment_content.append(str(assessment))
            
            slides.append({
                'slideNumber': slide_number,
                'title': 'Assessment Criteria',
                'content': assessment_content,
                'images': []
            })
        
        return slides
    
    def get_current_date(self) -> str:
        """Get current date as string."""
        from datetime import datetime
        return datetime.now().isoformat()
    
    def process_single_file(self, file_path: Path) -> Optional[Dict[str, Any]]:
        """
        Process a single Word document.
        
        Args:
            file_path: Path to the Word document
            
        Returns:
            Processed lesson data or None if processing failed
        """
        try:
            print(f"Processing: {file_path.name}")
            
            # Open and read the document
            doc = Document(str(file_path))
            
            # Extract content
            lesson_content = self.extract_document_structure(doc)
            
            # Convert to LMS format
            lms_lesson = self.convert_to_lms_format(lesson_content, file_path.name)
            
            print(f"✓ Successfully processed {file_path.name}")
            print(f"  - Found {len(lms_lesson['content_sections'])} content sections")
            print(f"  - Found {len(lms_lesson['objectives'])} objectives")
            print(f"  - Generated {len(lms_lesson['slides'])} slides")
            
            return lms_lesson
            
        except Exception as e:
            print(f"✗ Error processing {file_path.name}: {str(e)}")
            return None
    
    def process_all_files(self) -> Dict[str, Dict[str, Any]]:
        """
        Process all Word documents in the lesson plans directory.
        
        Returns:
            Dictionary mapping filenames to processed lesson data
        """
        results = {}
        
        # Find all .docx files
        docx_files = list(self.lesson_plans_dir.glob("*.docx"))
        
        if not docx_files:
            print(f"No .docx files found in {self.lesson_plans_dir}")
            return results
        
        print(f"Found {len(docx_files)} lesson plan documents")
        print("-" * 50)
        
        # Process each file
        for file_path in sorted(docx_files):
            lesson_data = self.process_single_file(file_path)
            if lesson_data:
                results[file_path.name] = lesson_data
                
                # Save individual JSON file
                output_filename = f"lesson_plan_{lesson_data['lesson_number']:02d}.json"
                output_path = self.output_dir / output_filename
                
                with open(output_path, 'w', encoding='utf-8') as f:
                    json.dump(lesson_data, f, indent=2, ensure_ascii=False)
                
                print(f"  → Saved to: {output_filename}")
            
            print()
        
        return results
    
    def create_summary_file(self, results: Dict[str, Dict[str, Any]]):
        """Create a summary file with all lesson plans."""
        summary = {
            'total_lessons': len(results),
            'extraction_date': self.get_current_date(),
            'lessons': []
        }
        
        for filename, lesson_data in sorted(results.items()):
            summary['lessons'].append({
                'lesson_id': lesson_data['lesson_id'],
                'title': lesson_data['title'],
                'lesson_number': lesson_data['lesson_number'],
                'description': lesson_data['description'],
                'source_file': filename,
                'content_sections_count': len(lesson_data['content_sections']),
                'objectives_count': len(lesson_data['objectives']),
                'slides_count': len(lesson_data['slides'])
            })
        
        summary_path = self.output_dir / 'lesson_plans_summary.json'
        with open(summary_path, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        
        print(f"📋 Summary saved to: lesson_plans_summary.json")


def main():
    """Main function to run the lesson plan extraction."""
    
    # Configuration
    lesson_plans_dir = "/Users/mac/dev/logit_LMS/lib/assets/images/Lesson_plans"
    output_dir = "/Users/mac/dev/logit_LMS/extracted_lesson_plans"
    
    print("🚀 Digital Master Training - Lesson Plan Extractor")
    print("=" * 60)
    print(f"📁 Source directory: {lesson_plans_dir}")
    print(f"📁 Output directory: {output_dir}")
    print()
    
    # Initialize extractor
    extractor = LessonPlanExtractor(lesson_plans_dir, output_dir)
    
    # Process all files
    results = extractor.process_all_files()
    
    if results:
        print("=" * 60)
        print(f"✅ Successfully processed {len(results)} lesson plans")
        
        # Create summary
        extractor.create_summary_file(results)
        
        print("\n📊 Processing Summary:")
        print("-" * 30)
        for filename, lesson_data in sorted(results.items()):
            print(f"Lesson {lesson_data['lesson_number']:2d}: {lesson_data['title']}")
        
        print(f"\n🎯 All lesson plans have been extracted and saved to:")
        print(f"   {output_dir}")
        
    else:
        print("❌ No lesson plans were successfully processed")


if __name__ == "__main__":
    main()
