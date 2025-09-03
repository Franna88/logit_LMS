
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
