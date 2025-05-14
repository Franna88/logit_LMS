# PowerPoint Content Extractor for LMS

This tool extracts content from PowerPoint (.pptx) files and uploads it to your Firebase LMS as structured lesson content. It's a two-step process:

1. Extract content from PowerPoint files, saving text as JSON and images to a folder
2. Upload the extracted content to Firebase as a lesson that can be attached to courses/modules

## Setup

1. Create a Python virtual environment:

```bash
python3 -m venv pptx_env
source pptx_env/bin/activate
```

2. Install dependencies:

```bash
pip install python-pptx firebase-admin
```

3. Firebase setup:
   - The project is already configured with Firebase
   - Make sure the service account key is in the `config/service_account.json` file

## Usage

### Step 1: Extract PowerPoint Content

```bash
python pptx_extractor.py path/to/your/presentation.pptx --output-dir output
```

This will create:
- A JSON file with text content from each slide
- An "images" folder containing all images from the presentation

### Step 2: Upload to Firebase LMS

```bash
python firebase_uploader.py output/presentation_name.json output/images config/service_account.json --school-code DMT
```

To attach the lesson to a specific module within a course:
```bash
python firebase_uploader.py output/presentation_name.json output/images config/service_account.json --course-id COURSE_ID_HERE --module-id MODULE_ID_HERE --school-code DMT
```

The script will:
1. Create a new lesson in the LMS
2. Upload all images to Firebase Storage
3. Structure the slides as a subcollection under the lesson
4. Optionally connect the lesson to a specific module and course

### Finding Course and Module IDs

To find existing course and module IDs, you can use the structure checker tool:

```bash
python firebase_structure_checker.py config/service_account.json
```

## Data Structure

The uploaded content will be organized as follows:

1. A new document in the `lessons` collection with metadata:
   - `id`: Unique lesson identifier (auto-generated)
   - `title`: From the PowerPoint filename
   - `code`: Formatted as "SCHOOL_TITLE" (e.g., "DMT_Lesson_01")
   - `is_lesson_material`: true
   - `module_id`: If provided, links to a specific module

2. A `slides` subcollection containing each slide:
   - Slide title, content, and images with public URLs
   - Maintained slide numbering and order

3. Images stored in Firebase Storage:
   - Path structure: `schools/SCHOOL_CODE/lessons/LESSON_ID/images/`

## Customizing

You can customize how content is extracted and structured by modifying the scripts:
- `pptx_extractor.py`: Change how PowerPoint content is parsed
- `firebase_uploader.py`: Adjust how content is structured in Firebase 