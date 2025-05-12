# Image Assets Directory

This directory contains images used throughout the Digital Master Training (DMT) Learning Management System.

## Directory Structure

- `/courses`: Contains course thumbnail and banner images
  - Naming convention: `course_[id]_[thumbnail/banner].[extension]`
  - Example: `course_1_thumbnail.jpg`, `course_1_banner.jpg`

## Adding Images

To add new course images:

1. Place your image files in the appropriate directory
2. Use the naming conventions above to maintain consistency
3. Make sure images are optimized for web/mobile

## Usage in Code

To use these images in your Flutter code:

```dart
// Example: loading a course thumbnail
Image.asset('lib/assets/images/courses/course_1_thumbnail.jpg')
```

## Dummy Images

For testing and development purposes, you can use these placeholder URLs:

- Course images: https://placehold.co/600x400?text=Course+Thumbnail
- User avatars: https://placehold.co/150x150?text=User+Avatar

Or you can use local placeholder images that follow the naming convention. 