import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'video_screen.dart';
import '../../screens/student/course_detail_screen.dart';

// This class acts as a router for different types of content
class ContentNavigator extends StatefulWidget {
  final String moduleTitle;
  final List<ContentItem> contentItems;
  final int initialContentIndex;
  final Function(int, bool)
  onContentComplete; // Parameters: contentIndex, isCompleted

  const ContentNavigator({
    super.key,
    required this.moduleTitle,
    required this.contentItems,
    required this.initialContentIndex,
    required this.onContentComplete,
  });

  @override
  State<ContentNavigator> createState() => _ContentNavigatorState();
}

class _ContentNavigatorState extends State<ContentNavigator> {
  late int _currentContentIndex;

  @override
  void initState() {
    super.initState();
    _currentContentIndex = widget.initialContentIndex;
  }

  void _navigateToNext() {
    if (_currentContentIndex < widget.contentItems.length - 1) {
      setState(() {
        _currentContentIndex++;
      });
    } else {
      // Return to course detail if this was the last content item
      Navigator.pop(context);
    }
  }

  void _navigateToPrevious() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
      });
    } else {
      // Return to course detail if this was the first content item
      Navigator.pop(context);
    }
  }

  void _markContentComplete() {
    widget.onContentComplete(_currentContentIndex, true);
    // Auto-navigate to next content if not the last item
    if (_currentContentIndex < widget.contentItems.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), _navigateToNext);
    }
  }

  void _exitToModule() {
    Navigator.pop(context);
  }

  void _handleQuizComplete(int score, int total) {
    final bool isPassing = (score / total) >= 0.7; // 70% passing threshold
    widget.onContentComplete(_currentContentIndex, isPassing);
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = widget.contentItems[_currentContentIndex];
    final bool hasNext = _currentContentIndex < widget.contentItems.length - 1;
    final bool hasPrevious = _currentContentIndex > 0;

    // Check if this content has Firebase slide data
    final slideData = currentContent.additionalData;
    final bool hasFirebaseData = slideData != null;

    // Navigate to appropriate screen based on content type
    switch (currentContent.type) {
      case ContentType.introduction:
      case ContentType.lesson:
        return LessonScreen(
          moduleTitle: widget.moduleTitle,
          lessonTitle: currentContent.title,
          lessonContent:
              hasFirebaseData ? '' : _getSampleContent(currentContent),
          imageUrls:
              hasFirebaseData
                  ? null
                  : ['lib/assets/images/course.jpg'], // Sample image
          slideData: slideData, // Pass Firebase slide data to the lesson screen
          isCompleted: currentContent.isCompleted,
          onComplete: _markContentComplete,
          onNext: _navigateToNext,
          onPrevious: _navigateToPrevious,
          hasNext: hasNext,
          hasPrevious: hasPrevious,
        );

      case ContentType.video:
        return VideoScreen(
          moduleTitle: widget.moduleTitle,
          videoTitle: currentContent.title,
          videoUrl: 'lib/assets/videos/sample.mp4', // Sample video URL
          description: _getSampleContent(currentContent),
          isCompleted: currentContent.isCompleted,
          onComplete: _markContentComplete,
          onNext: _navigateToNext,
          onPrevious: _navigateToPrevious,
          hasNext: hasNext,
          hasPrevious: hasPrevious,
        );

      case ContentType.quiz:
      case ContentType.assessment:
        return QuizScreen(
          moduleTitle: widget.moduleTitle,
          quizTitle: currentContent.title,
          questions: _getSampleQuestions(currentContent),
          isPractice: currentContent.type == ContentType.quiz,
          timeLimit:
              currentContent.type == ContentType.assessment
                  ? 30
                  : null, // 30 min time limit for assessments
          onComplete: _handleQuizComplete,
          onExit: _exitToModule,
        );

      case ContentType.exercise:
        // For this demo, we'll use the lesson screen template for exercises
        return LessonScreen(
          moduleTitle: widget.moduleTitle,
          lessonTitle: currentContent.title,
          lessonContent: _getSampleExerciseContent(currentContent),
          imageUrls: ['lib/assets/images/course2.jpg'], // Sample image
          slideData: slideData, // Pass Firebase slide data if available
          isCompleted: currentContent.isCompleted,
          onComplete: _markContentComplete,
          onNext: _navigateToNext,
          onPrevious: _navigateToPrevious,
          hasNext: hasNext,
          hasPrevious: hasPrevious,
        );

      default:
        // Fallback
        return LessonScreen(
          moduleTitle: widget.moduleTitle,
          lessonTitle: currentContent.title,
          lessonContent: 'Content not available',
          isCompleted: currentContent.isCompleted,
          onComplete: _markContentComplete,
          onNext: _navigateToNext,
          onPrevious: _navigateToPrevious,
          hasNext: hasNext,
          hasPrevious: hasPrevious,
        );
    }
  }

  // Sample content for lessons
  String _getSampleContent(ContentItem item) {
    // Module 1: Introduction to Diving Safety
    if (item.title == 'Introduction to the Course') {
      return '''# Welcome to Diving Safety and Awareness

In this comprehensive diving course, you will learn essential diving techniques and safety procedures that every certified diver must know and practice. Diving is an exhilarating activity that opens up an entirely new world to explore, but it requires proper knowledge, skills, and awareness to be performed safely.

## What You'll Learn

Throughout this course, we'll cover critical topics including:

- Proper equipment selection, usage, and maintenance
- Pre-dive planning and risk assessment
- Underwater navigation and communication
- Emergency recognition and response procedures
- Environmental awareness and conservation

## Course Structure

This course is organized into six modules, each focusing on different aspects of diving safety:

1. **Introduction to Diving Safety** - Foundational concepts and equipment overview
2. **Dive Planning and Risk Assessment** - Preparing for safe diving experiences
3. **Emergency Procedures** - Handling potential problems underwater
4. **Equipment Safety** - Detailed look at diving gear and maintenance
5. **Environmental Awareness** - Understanding marine conditions and conservation
6. **Advanced Safety Techniques** - Taking your safe diving practices to the next level

## Prerequisites

Before proceeding, please ensure you've:
- Completed a basic scuba certification course
- Familiarized yourself with standard diving equipment
- Reviewed the course materials available in the Resources section

Let's begin this journey toward becoming a safer, more aware diver!''';
    } else if (item.title == 'Diving Equipment Overview') {
      return '''# Diving Equipment: Your Life Support System

Your diving equipment is more than just gear—it's your life support system underwater. This lesson will help you understand each component, its purpose, and how to ensure it functions correctly.

## Core Diving Equipment

### Mask, Snorkel, and Fins

These basic items allow you to see clearly underwater, breathe at the surface without lifting your head, and move efficiently through water:

- **Mask**: Provides an air space in front of your eyes for clear vision
- **Snorkel**: Allows surface breathing while face-down in water
- **Fins**: Multiply your leg power for efficient movement underwater

### Exposure Protection
Your body loses heat 25 times faster in water than in air. Protection includes:

- **Wetsuits**: Made of neoprene, they trap a thin layer of water that your body heats
- **Drysuits**: Keep you completely dry, necessary for cold water diving
- **Gloves & Hoods**: Protect extremities in cooler conditions

### Buoyancy Control Device (BCD)
The BCD is a vest-like device that:

- Controls your buoyancy throughout the dive
- Holds your tank securely on your back
- Provides attachment points for accessories
- Inflates for positive buoyancy at the surface

### Regulator System

This critical equipment delivers breathable air from your high-pressure tank:

1. **First Stage**: Attaches to tank and reduces high pressure air
2. **Second Stage**: The mouthpiece that delivers air when you inhale
3. **Octopus**: Backup second stage for emergency air sharing
4. **Pressure Gauge**: Shows remaining air supply
5. **Depth Gauge**: Indicates current depth
6. **Dive Computer**: Tracks depth, time, and calculates no-decompression limits

## Equipment Maintenance

Proper maintenance extends the life of your equipment and ensures safety:

- Rinse all gear thoroughly with fresh water after each dive
- Allow equipment to dry completely before storage
- Store out of direct sunlight
- Have regulators professionally serviced annually
- Inspect all equipment before each dive

## Pre-Dive Equipment Check

Always perform the following checks before entering the water:

1. Turn on air and check tank pressure
2. Test all regulator functions
3. Check BCD inflation and deflation
4. Inspect mask, fins and exposure suit for damage
5. Verify all gauges and computer are functioning

Remember: Your life depends on your equipment underwater. Treat it with care and never dive with equipment you don't trust completely.''';
    } else if (item.title == 'Pre-Dive Safety Checks') {
      return '''# Pre-Dive Safety Checks: The Critical Final Step

The moments before entering the water are your last opportunity to ensure everything is functioning properly. This lesson covers the essential safety checks that should become second nature before every dive.

## The BWRAF System

Most divers use the BWRAF acronym (pronounced "bee-wraf") to remember the sequence of pre-dive checks:

### B - BCD
- Inflate your BCD fully to check for leaks
- Test both oral and power inflators
- Verify all dump valves function properly
- Ensure proper tank attachment

### W - Weights
- Confirm you have the correct amount of weight
- Check that weight pockets or belt are secure
- Verify quick-release mechanisms function properly
- Make sure weights are balanced appropriately

### R - Releases
- Check all straps and buckles
- Test tank band security
- Ensure emergency quick releases work smoothly
- Verify that knife/tool attachments are secure

### A - Air
- Turn on tank valve fully, then back a quarter turn
- Check tank pressure (should be at least 200 bar/3000 psi for a typical dive)
- Breathe from both primary and alternate air sources
- Monitor your pressure gauge for any drops over 1-2 minutes

### F - Final Check
- Mask: Properly fitted and defog applied
- Fins: Secured correctly
- Signals: Review hand signals with your buddy
- Accessories: Ensure cameras, lights, etc. are secure
- Entry: Discuss entry technique and meeting point underwater

## Buddy Checks

After completing your own checks, perform a reciprocal check with your buddy:

1. **Air**: Check each other's tank valve is fully open
2. **BCD**: Verify inflator hose connection and function
3. **Weights**: Locate and test each other's weight release mechanisms
4. **Releases**: Identify and test all emergency releases
5. **Equipment**: Check for proper hose routing and accessory placement

## Documentation and Planning
Before entering the water, always ensure:

- Dive plan is clearly communicated and understood
- Maximum depth and time limits are agreed upon
- Entry and exit points are identified
- Emergency protocols are reviewed

## Final Safety Considerations

- Never skip the pre-dive safety check, no matter how experienced you are
- Always perform checks even if diving with the same buddy repeatedly
- If you find any equipment issues, no matter how small, address them before diving
- Remember: The few minutes spent on safety checks could save your life

The pre-dive safety check is your last line of defense against equipment-related problems underwater. Make it a sacred ritual that you never compromise.''';
    }
    // Module 2: Dive Planning and Risk Assessment
    else if (item.title == 'Dive Planning Basics') {
      return '''# Dive Planning: The Foundation of Safe Diving

Proper dive planning significantly reduces risks and enhances enjoyment. This lesson covers the fundamental aspects of planning safe and successful dives.

## The Elements of a Dive Plan

### 1. Site Selection and Evaluation

Consider these factors when selecting a dive site:
- Water conditions (visibility, temperature, currents)
- Entry and exit points
- Maximum and average depths
- Local hazards and marine life
- Navigation challenges
- Emergency services availability

### 2. Dive Profiles

A dive profile describes the relationship between depth and time during your dive:
- Plan maximum depth based on certification level and experience
- Calculate no-decompression limits using tables or computers
- Consider multilevel diving to maximize bottom time safely
- Plan conservative profiles with safety margins

### 3. Gas Management

Proper gas planning ensures you have sufficient breathing gas:
- Begin with the "Rule of Thirds": ⅓ for the dive, ⅓ for the return, ⅓ for emergency
- Calculate air consumption rates based on previous dives
- Adjust reserves based on conditions (cold, current, depth)
- Always plan more conservative air requirements for challenging conditions

### 4. Thermal Protection

Select appropriate exposure protection:
- Water temperature (including at depth)
- Dive duration
- Personal comfort level
- Activity level during the dive

### 5. Buddy System Planning

Effective buddy planning includes:
- Clear communication of dive objectives
- Agreed-upon hand signals
- Lost buddy procedures
- Air-sharing emergency protocols
- Entry and exit procedures

## The Dive Planning Process

### Pre-Trip Planning (Days Before)
1. Research the dive site thoroughly
2. Check weather and water conditions forecast
3. Prepare and inspect all equipment
4. Review emergency procedures specific to the site
5. Confirm buddy arrangements and logistics

### Day-of-Dive Planning
1. Re-check weather and water conditions
2. Establish entry and exit points
3. Identify underwater landmarks for navigation
4. Set maximum depth, time, and turn-around points
5. Review emergency procedures with all divers

### Five-Minute Pre-Dive Plan
1. Visualize the dive and discuss with buddy
2. Confirm hand signals and communication
3. Establish air check intervals
4. Conduct equipment checks
5. Agree on contingency plans

## Risk Assessment and Mitigation

Every dive plan should include risk assessment:

| Risk Factor | Mitigation Strategy |
|-------------|---------------------|
| Strong current | Plan drift dive, carry surface marker buoy |
| Limited visibility | Use guideline, stay closer to buddy, carry light |
| Boat traffic | Deploy diver-down flag, surface away from channels |
| Entanglement hazards | Carry cutting tool, avoid areas with fishing lines |
| Marine life encounters | Research local species, maintain appropriate distance |

## Documentation

Document your dive plan including:
- Diver information and emergency contacts
- Planned profile (depth and time)
- Safety stops and decompression obligations
- Entry/exit points and navigation plan
- Emergency procedures specific to the location

Remember: A thorough dive plan is your roadmap to a safe and enjoyable experience underwater. Never dive without one!''';
    }
    // Module 3: Emergency Procedures
    else if (item.title == 'Recognizing Diving Emergencies') {
      return '''# Recognizing Diving Emergencies: Early Detection Saves Lives

The ability to quickly identify diving emergencies is crucial for effective response. This lesson covers the signs, symptoms, and appropriate reactions to common diving emergencies.

## Decompression Illness

### Decompression Sickness (DCS or "The Bends")
DCS occurs when nitrogen bubbles form in tissues during ascent.

**Signs and Symptoms:**
- Joint pain (particularly shoulders and elbows)
- Unusual fatigue or weakness
- Skin rashes or itching
- Dizziness or vertigo
- Numbness or tingling sensations
- Paralysis (in severe cases)
- Confusion or personality changes

**Response:**
- Stop diving immediately
- Administer 100% oxygen
- Hydrate the diver
- Position horizontally
- Seek emergency medical transport to recompression chamber
- Never return to altitude (flying or mountain driving) after suspected DCS

### Arterial Gas Embolism (AGE)
AGE is caused by air bubbles entering arterial circulation, often due to lung overexpansion during ascent.

**Signs and Symptoms:**
- Sudden loss of consciousness
- Confusion or personality changes
- Seizures
- Blurred vision or blindness
- Weakness or paralysis
- Difficulty breathing
- Bloody froth from mouth or nose

**Response:**
- Same as DCS but with greater urgency - this is life-threatening
- Position on left side with head slightly lower than body if unconscious

## Pulmonary Emergencies

### Pulmonary Barotrauma
Lung injury caused by expanding air during ascent.

**Signs and Symptoms:**
- Chest pain
- Difficulty breathing
- Coughing up blood
- Voice changes
- Blue discoloration of lips or skin

**Response:**
- Administer 100% oxygen
- Monitor for signs of AGE
- Seek immediate medical attention

### Pulmonary Edema
Fluid accumulation in the lungs, can occur even in shallow water.

**Signs and Symptoms:**
- Shortness of breath
- Pink, frothy sputum
- Crackling sounds when breathing
- Extreme fatigue
- Coughing

**Response:**
- Exit water immediately
- Sit upright to ease breathing
- Administer 100% oxygen
- Seek emergency medical care

## Other Common Emergencies

### Marine Life Injuries
**Signs and Symptoms:**
- Puncture wounds or lacerations
- Localized pain or burning sensation
- Swelling or discoloration
- Systemic reactions (in case of venomous injuries)

**Response:**
- Specific to the injury type (e.g., hot water for jellyfish stings, vinegar for some cnidarian stings)
- Clean and bandage wounds
- Monitor for signs of infection or allergic reaction

### Nitrogen Narcosis
**Signs and Symptoms:**
- Impaired judgment
- Delayed response time
- Euphoria or anxiety
- Overconfidence
- Task fixation

**Response:**
- Ascend to shallower depth
- Re-evaluate ability to continue dive safely

## Emergency Prevention

The best emergency is one that never happens:
- Always dive within your training and experience levels
- Use conservative dive profiles
- Stay well-hydrated and rested
- Perform thorough equipment checks
- Maintain good physical fitness
- Avoid alcohol before diving
- Ascend slowly and perform safety stops

## Emergency Preparation

Always be prepared for emergencies:
- Carry emergency contact information
- Know location of nearest recompression chamber
- Maintain first aid and oxygen provider certifications
- Carry appropriate first aid supplies
- Have emergency action plans for each dive site

Remember: In diving emergencies, time is critical. Early recognition and proper response dramatically improve outcomes. Always err on the side of caution if you suspect a diving emergency.''';
    }
    // Default content for any other module or lesson type
    else if (item.type == ContentType.introduction) {
      return '''Welcome to this diving course module!

In this module, you will learn essential diving techniques and safety procedures that every diver must know. Diving is an exciting activity, but it requires proper knowledge and skills to be performed safely.

Throughout this module, we'll cover important topics including proper equipment usage, dive planning, underwater navigation, and emergency procedures. 

Before you begin, please ensure you've completed all prerequisite modules and familiarized yourself with basic diving concepts. Let's dive in!''';
    } else if (item.type == ContentType.lesson) {
      return '''Diving safety is paramount for all underwater activities. This lesson covers the fundamental safety principles that every diver should know and follow.

## Equipment Checks

Always perform a thorough check of your diving equipment before entering the water:

1. **Regulator**: Ensure your primary and backup regulators are functioning properly.
2. **BCD (Buoyancy Control Device)**: Check that it inflates and deflates correctly.
3. **Air Tank**: Verify it's filled to the appropriate pressure and securely attached.
4. **Pressure Gauge**: Confirm it displays the correct tank pressure.
5. **Mask, Fins, and Wetsuit**: Inspect for any damage or defects.

## Buddy System

Never dive alone! The buddy system is an essential safety protocol in diving:

- Maintain visual contact with your buddy throughout the dive.
- Establish and review hand signals before diving.
- Plan how to handle emergency situations together.
- Perform regular buddy checks during the dive.

## Emergency Procedures

Knowing how to respond in emergencies is critical:

- Practice controlled emergency swimming ascent (CESA).
- Learn to recognize signs of decompression sickness and other diving-related injuries.
- Understand how to deploy and use safety devices like surface marker buoys.

Remember: Safety is everyone's responsibility in diving. Always prioritize safety over adventure!''';
    } else {
      return '''# ${item.title}

This content is currently being developed by our diving experts. Check back soon for comprehensive information on this topic!

In the meantime, you can explore the other available modules and lessons to continue your diving education.

## Key Points to Consider

- Safety is always the top priority in diving
- Regular practice maintains and improves your diving skills
- Continuing education is essential for becoming a better diver
- Always dive within the limits of your training and experience

We're excited to bring you more detailed content on this topic soon!''';
    }
  }

  // Sample content for exercises
  String _getSampleExerciseContent(ContentItem item) {
    return '''# Practical Exercise: Creating a Dive Plan

In this exercise, you'll create a comprehensive dive plan for a recreational dive at a depth of 25 meters (82 feet).

## Instructions

1. Download the dive planning worksheet from the resources section.
2. Fill out all the required information including:
   - Dive site information
   - Weather and water conditions
   - Entry and exit points
   - Planned depth and bottom time
   - Gas calculations
   - Emergency procedures
   - Buddy information

3. Calculate your no-decompression limits using the dive tables provided.
4. Determine your air consumption rate and total air needed.
5. Identify potential hazards and plan mitigation strategies.

## Submission

Once you've completed your dive plan:
1. Take a clear photo or scan of your completed worksheet
2. Upload it using the submission form below
3. You'll receive feedback from your instructor within 48 hours

This exercise will help you apply theoretical knowledge to real-world diving scenarios and prepare you for safe dive planning in various conditions.

**Important Note**: Always consult with a certified diving professional when planning actual dives.''';
  }

  // Sample questions for quizzes and assessments
  List<QuizQuestion> _getSampleQuestions(ContentItem item) {
    if (item.type == ContentType.quiz) {
      // Practice quiz
      return [
        QuizQuestion(
          questionText: 'What is the most important rule of scuba diving?',
          answerOptions: [
            'Never hold your breath',
            'Always dive alone',
            'Descend as quickly as possible',
            'Stay underwater as long as possible',
          ],
          correctAnswerIndex: 0,
          explanation:
              'Never holding your breath is the most important rule in scuba diving. Holding your breath can lead to lung overexpansion injuries such as pulmonary barotrauma when ascending, which can be fatal.',
        ),
        QuizQuestion(
          questionText:
              'What does the acronym BCD stand for in diving equipment?',
          answerOptions: [
            'Basic Control Device',
            'Buoyancy Control Device',
            'Backup Control Display',
            'Breathing Control Detector',
          ],
          correctAnswerIndex: 1,
          explanation:
              'BCD stands for Buoyancy Control Device. It\'s an inflatable vest that helps divers maintain neutral buoyancy underwater and positive buoyancy at the surface.',
        ),
        QuizQuestion(
          questionText:
              'Which of the following is a sign of decompression sickness?',
          answerOptions: [
            'Increased body temperature',
            'Joint pain',
            'Improved vision',
            'Increased energy',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Joint pain, often called "the bends," is a common symptom of decompression sickness. It occurs when nitrogen bubbles form in tissues during ascent from a dive.',
          imageUrl: 'lib/assets/images/course.jpg',
        ),
      ];
    } else {
      // Assessment (more comprehensive)
      return [
        QuizQuestion(
          questionText:
              'What gas is responsible for decompression sickness in scuba diving?',
          answerOptions: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Helium'],
          correctAnswerIndex: 2,
          explanation:
              'Nitrogen is the gas responsible for decompression sickness. As pressure increases during descent, more nitrogen dissolves in body tissues. If a diver ascends too quickly, this nitrogen can form bubbles in tissues and bloodstream, causing decompression sickness.',
        ),
        QuizQuestion(
          questionText:
              'What is the proper procedure if you run out of air while diving?',
          answerOptions: [
            'Hold your breath and swim to the surface',
            'Signal your buddy and share air using their alternate air source',
            'Take off your equipment to swim faster to the surface',
            'Inflate your BCD fully and race to the surface',
          ],
          correctAnswerIndex: 1,
          explanation:
              'The correct procedure is to signal your buddy and use their alternate air source (octopus). Never hold your breath or rush to the surface as this can cause serious injuries.',
        ),
        QuizQuestion(
          questionText:
              'What is the maximum recommended safe ascent rate in recreational diving?',
          answerOptions: [
            '10 meters/33 feet per minute',
            '18 meters/60 feet per minute',
            '30 meters/100 feet per minute',
            '5 meters/16 feet per minute',
          ],
          correctAnswerIndex: 0,
          explanation:
              'The maximum recommended safe ascent rate is 9-10 meters (30-33 feet) per minute. Ascending too quickly increases the risk of decompression sickness and other pressure-related injuries.',
        ),
        QuizQuestion(
          questionText:
              'Which of the following is NOT a mandatory piece of scuba equipment?',
          answerOptions: [
            'Mask and fins',
            'Regulator',
            'Underwater camera',
            'Pressure gauge',
          ],
          correctAnswerIndex: 2,
          explanation:
              'An underwater camera is not mandatory safety equipment for diving. Mask, fins, regulator, BCD, pressure gauge, and dive computer/tables are all considered essential for safe diving.',
        ),
        QuizQuestion(
          questionText:
              'What should you do if you encounter a strong current while diving?',
          answerOptions: [
            'Swim against the current to maintain your position',
            'Inflate your BCD fully and let the current carry you',
            'Descend closer to the bottom where current may be weaker and swim with it',
            'Remove your fins to reduce drag',
          ],
          correctAnswerIndex: 2,
          explanation:
              'When encountering a strong current, it\'s best to descend closer to the bottom where the current is usually weaker, conserve energy, and swim with the current rather than against it when possible.',
          imageUrl: 'lib/assets/images/course2.jpg',
        ),
      ];
    }
  }
}
