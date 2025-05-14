# Logit LMS Firebase Structure Documentation

This document provides an overview of the Firebase database structure for the Logit LMS system, with a focus on the lesson content and associated images.

## Firebase Project Details

- **Project ID**: diving-app-8fa28
- **Storage Bucket**: diving-app-8fa28.firebasestorage.app

## Database Structure

The Firestore database has the following top-level collections:

### Collections

1. **assessments**
   - ID Format: ASS_[timestamp]_[uuid]
   - Fields: active, module_id, type, description, id, weighting, instruction, code, norm

2. **courseGroups**
   - ID Format: CLU_[timestamp]_[uuid]
   - Fields: sortcode, description, id

3. **courseProgress**
   - ID Format: [userId]_[courseId]
   - Fields: completedModules, assessmentScores, lastAccessed, userId, percentComplete, courseId

4. **courses**
   - ID Format: OPL_[timestamp]_[uuid]
   - Fields: active, title, description, id, group_id, code
   - Additional Fields for Modern Courses: isFree, imageUrl, categories, instructor, price, rating, isAvailable, status, totalStudents, modules

5. **lessons**
   - ID Format: LES_[timestamp]_[uuid]
   - Fields: is_lesson_material, module_id, id, code, title, is_case_study, sortcode, is_additional_material
   - Has subcollection: slides

6. **modules**
   - ID Format: MOD_[timestamp]_[uuid]
   - Fields: title, sortcode, course_id, id, evaluation_id, code

7. **users**
   - ID Format: [firebase auth uid]
   - Fields: profilePicture, selectedRoleId, bio, courses, selectedRole, lastLogin, lastRoleChange, name, lastLogout, isActive, progress, profileComplete, preferences, role, emailVerified, createdAt, roleId, email, username, achievements

## Recently Uploaded Lessons

### Lesson_01

- **ID**: LES_20250514005426_9db35c81-6661-4b90
- **Title**: Lesson_01
- **Slides**: 15 slides
- **Images**: 8 images
- **Content**: Covers accident management including bleeding, soft tissue injuries, shock, fractures, crush injuries, and chest trauma

**Images:**
1. Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png
2. Lesson_01_slide_1_8f3a5c57-9a5b-498b-b9bd-8d5ba9a0b9d2.png
3. Lesson_01_slide_4_2379cb9f-b8e6-417a-bebb-9ccb546977c3.png
4. Lesson_01_slide_5_5cd6309f-1f57-4a19-87e9-ec5279ddd360.png
5. Lesson_01_slide_6_ae28a4dc-4a14-4397-82f1-a1aae2c7aba8.png
6. Lesson_01_slide_12_b75cffc4-6ebe-4eda-bfcb-a74aa2c45d88.png
7. Lesson_01_slide_14_51d20603-dd70-47d3-8dba-e2f776ed5b8b.png
8. Lesson_01_slide_15_3c177ead-2daa-49b8-aecd-70a5a5203746.png

**Storage Path**: schools/DMT/lessons/LES_20250514005426_9db35c81-6661-4b90/images/

### Lesson_02

- **ID**: LES_20250514005500_90b1977f-fe0d-45df
- **Title**: Lesson_02
- **Slides**: 15 slides
- **Images**: 9 images
- **Content**: Covers chest trauma topics including pneumothorax, tension pneumothorax, pulmonary embolism, haemothorax, rib fractures, burns, electrical injuries, and poison

**Images:**
1. Lesson_02_slide_1_37374d19-33c2-4c33-8f26-d0eb1ef05112.png
2. Lesson_02_slide_3_517abed7-fe91-4901-8ff2-b5fd9322a4ad.png
3. Lesson_02_slide_6_3963ee76-2390-439f-8216-2723cc1431b7.png
4. Lesson_02_slide_10_ce4f234e-96e6-45f4-a677-f44040018d80.png
5. Lesson_02_slide_11_849d2d38-dc02-4db8-a7aa-17e87cae7a73.png
6. Lesson_02_slide_12_1c26b274-d706-4394-b7d7-cbf4b0eb40ed.png
7. Lesson_02_slide_13_fd3d10ca-22a8-40cc-a357-812b738f6c90.png
8. Lesson_02_slide_13_493467d2-86c1-4ba9-962a-98b5669b6c52.png
9. Lesson_02_slide_14_60a216a2-80fb-4d2e-a5e3-4cd1166efbf7.png

**Storage Path**: schools/DMT/lessons/LES_20250514005500_90b1977f-fe0d-45df/images/

## Data Structure Example

### Lesson Document

```json
{
  "id": "LES_20250514005426_9db35c81-6661-4b90",
  "title": "Lesson_01",
  "code": "DMT_Lesson_01",
  "sortcode": 0,
  "is_lesson_material": true,
  "is_case_study": false,
  "is_additional_material": false
}
```

### Slide Document (Subcollection of a Lesson)

```json
{
  "slideNumber": 1,
  "title": "BLEEDING \n\nOPEN WOUNDS\nDo not remove the object...",
  "content": [
    "SK-DIV-PPT-005",
    "1.2 Accident Management (Bleeding)"
  ],
  "images": [
    {
      "filename": "Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png",
      "url": "https://storage.googleapis.com/diving-app-8fa28.firebasestorage.app/schools/DMT/lessons/LES_20250514005426_9db35c81-6661-4b90/images/Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png",
      "storagePath": "schools/DMT/lessons/LES_20250514005426_9db35c81-6661-4b90/images/Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png"
    }
  ]
}
```

## Upload Scripts

### 1. Upload Script

The script `upload_fixed.sh` uploads lesson content to Firebase with proper storage configuration:

```bash
#!/bin/bash
# Create and activate virtual environment
source venv/bin/activate

# The correct storage bucket from the screenshot
STORAGE_BUCKET="diving-app-8fa28.firebasestorage.app"

# Upload Lesson_01 - Note the correct images directory: output/images
python3 firebase_uploader.py output/Lesson_01.json output/images config/service_account.json --storage-bucket $STORAGE_BUCKET

# Upload Lesson_02 - Note the correct images directory: output/images
python3 firebase_uploader.py output/Lesson_02.json output/images config/service_account.json --storage-bucket $STORAGE_BUCKET
```

### 2. Verification Scripts

The following scripts can be used to verify the data in Firebase:

- `check_lessons.py`: Checks the existence of lessons in Firestore
- `check_images_corrected.py`: Checks if images exist in Firebase Storage
- `check_latest_upload.py`: Checks the specific lessons that were last uploaded
- `firebase_structure_checker.py`: Provides an overview of the entire Firebase database structure

## Notes for Course Creators

When adding new lessons:

1. Prepare your lesson content in JSON format in the `output/` directory
2. Place associated images in the `output/images/` directory
3. Use the upload script with the correct storage bucket name
4. Verify the upload using the verification scripts
5. Update this README if you add new collections or fields

## Troubleshooting

If images are not showing up in the Firebase console:
1. Check the storage bucket name is correct: "diving-app-8fa28.firebasestorage.app"
2. Verify the image paths in the JSON files
3. Make sure the images are available in the correct directory (output/images)
4. Run the check_latest_upload.py script to verify the status
