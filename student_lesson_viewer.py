#!/usr/bin/env python3
import firebase_admin
from firebase_admin import credentials, firestore, storage
import sys
import json
from datetime import datetime
import os

def generate_student_lesson_viewer():
    """
    Generate an interactive student-focused lesson viewer specifically for Lesson_01 and Lesson_02
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
    
    # Specific lesson IDs from our README documentation
    lesson_ids = [
        "LES_20250514005426_9db35c81-6661-4b90",  # Lesson_01
        "LES_20250514005500_90b1977f-fe0d-45df"   # Lesson_02
    ]
    
    lessons_data = []
    
    print("Fetching data for Lesson 01 and Lesson 02...")
    
    # Get lesson data for each lesson ID
    for lesson_id in lesson_ids:
        lesson_doc = db.collection('lessons').document(lesson_id).get()
        
        if not lesson_doc.exists:
            print(f"Warning: Lesson with ID {lesson_id} not found")
            continue
            
        lesson_data = lesson_doc.to_dict()
        
        # Get all slides for this lesson
        slides = db.collection('lessons').document(lesson_id).collection('slides').stream()
        slides_list = list(slides)
        
        # Sort slides by slide number
        slides_list = sorted(slides_list, key=lambda slide: slide.to_dict().get('slideNumber', 0))
        
        # Process slides
        processed_slides = []
        
        for slide in slides_list:
            slide_data = slide.to_dict()
            
            # Process images to ensure they have valid URLs
            processed_images = []
            for image in slide_data.get('images', []):
                if 'url' in image and image['url'] and not image['url'].startswith('PLACEHOLDER'):
                    processed_images.append(image)
            
            slide_data['images'] = processed_images
            processed_slides.append(slide_data)
        
        # Add processed slides to the lesson data
        lesson_data['slides'] = processed_slides
        lessons_data.append({
            'id': lesson_id,
            'data': lesson_data
        })
    
    print(f"Found {len(lessons_data)} lessons")
    
    # Generate engaging student view HTML
    html_output = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Logit LMS - Interactive Lesson Viewer</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <style>
            :root {
                --primary-color: #3498db;
                --secondary-color: #2ecc71;
                --accent-color: #e74c3c;
                --text-color: #2c3e50;
                --light-gray: #f5f7fa;
                --dark-gray: #7f8c8d;
                --white: #ffffff;
                --shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            }
            
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Roboto', sans-serif;
                color: var(--text-color);
                background-color: var(--light-gray);
                line-height: 1.6;
            }
            
            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
            }
            
            .header {
                text-align: center;
                margin-bottom: 30px;
                padding: 20px;
                background-color: var(--white);
                border-radius: 10px;
                box-shadow: var(--shadow);
            }
            
            .header h1 {
                color: var(--primary-color);
                margin-bottom: 10px;
            }
            
            .header p {
                color: var(--dark-gray);
            }
            
            .lesson-tabs {
                display: flex;
                margin-bottom: 20px;
                border-radius: 8px;
                overflow: hidden;
                box-shadow: var(--shadow);
            }
            
            .tab {
                flex: 1;
                padding: 15px;
                text-align: center;
                background-color: var(--white);
                cursor: pointer;
                font-weight: 500;
                transition: all 0.3s ease;
            }
            
            .tab:hover {
                background-color: rgba(52, 152, 219, 0.1);
            }
            
            .tab.active {
                background-color: var(--primary-color);
                color: var(--white);
            }
            
            .lesson-content {
                background-color: var(--white);
                border-radius: 10px;
                box-shadow: var(--shadow);
                overflow: hidden;
                margin-bottom: 30px;
            }
            
            .slides-nav {
                display: flex;
                justify-content: center;
                align-items: center;
                padding: 15px;
                background-color: var(--primary-color);
                color: white;
            }
            
            .nav-btn {
                background-color: transparent;
                border: 2px solid var(--white);
                color: var(--white);
                padding: 8px 15px;
                border-radius: 30px;
                cursor: pointer;
                margin: 0 10px;
                font-weight: 500;
                transition: all 0.3s ease;
            }
            
            .nav-btn:hover {
                background-color: var(--white);
                color: var(--primary-color);
            }
            
            .slide-counter {
                font-weight: 500;
                margin: 0 15px;
            }
            
            .slide {
                padding: 30px;
                display: none;
            }
            
            .slide.active {
                display: block;
                animation: fadeIn 0.5s ease;
            }
            
            @keyframes fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }
            
            .slide-title {
                font-size: 1.8rem;
                margin-bottom: 20px;
                color: var(--primary-color);
                border-bottom: 2px solid var(--light-gray);
                padding-bottom: 10px;
            }
            
            .slide-content {
                margin-bottom: 25px;
                white-space: pre-line;
            }
            
            .slide-content p {
                margin-bottom: 15px;
            }
            
            .slide-images {
                display: flex;
                flex-wrap: wrap;
                justify-content: center;
                gap: 20px;
                margin-top: 20px;
            }
            
            .slide-image {
                border-radius: 8px;
                overflow: hidden;
                box-shadow: var(--shadow);
                transition: transform 0.3s ease;
                max-width: 100%;
            }
            
            .slide-image:hover {
                transform: scale(1.03);
            }
            
            .slide-image img {
                max-width: 100%;
                height: auto;
                display: block;
            }
            
            .footer {
                text-align: center;
                padding: 20px;
                color: var(--dark-gray);
                font-size: 0.9rem;
            }
            
            .progress-container {
                width: 100%;
                height: 10px;
                background-color: var(--light-gray);
                border-radius: 5px;
                margin-top: 15px;
                overflow: hidden;
            }
            
            .progress-bar {
                height: 100%;
                background-color: var(--secondary-color);
                border-radius: 5px;
                transition: width 0.3s ease;
            }
            
            .content-section {
                background-color: var(--light-gray);
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            }
            
            .content-heading {
                font-weight: 500;
                margin-bottom: 5px;
                color: var(--primary-color);
            }
            
            /* Responsive adjustments */
            @media (max-width: 768px) {
                .slide {
                    padding: 20px;
                }
                
                .slide-title {
                    font-size: 1.5rem;
                }
                
                .slide-images {
                    flex-direction: column;
                    align-items: center;
                }
                
                .slide-image {
                    max-width: 100%;
                }
            }
            
            /* Image modal for enlargement */
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.8);
                z-index: 1000;
                justify-content: center;
                align-items: center;
            }
            
            .modal-content {
                max-width: 80%;
                max-height: 80%;
            }
            
            .modal-content img {
                width: 100%;
                height: auto;
                object-fit: contain;
            }
            
            .close-modal {
                position: absolute;
                top: 20px;
                right: 30px;
                color: white;
                font-size: 35px;
                cursor: pointer;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Logit LMS - Interactive Lesson Viewer</h1>
                <p>Your personalized learning experience for Accident Management</p>
            </div>
            
            <div class="lesson-tabs">
                <!-- Tabs will be generated by JS -->
            </div>
            
            <div class="lesson-content">
                <div class="slides-nav">
                    <button class="nav-btn prev-slide">Previous</button>
                    <span class="slide-counter">Slide 1 of 15</span>
                    <button class="nav-btn next-slide">Next</button>
                </div>
                
                <div class="slides-container">
                    <!-- Slide content will be inserted here by JavaScript -->
                </div>
                
                <div class="progress-container">
                    <div class="progress-bar" style="width: 0%"></div>
                </div>
            </div>
            
            <div class="footer">
                <p>© 2025 Logit LMS. All content is for educational purposes.</p>
                <p>Generated on: """ + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + """</p>
            </div>
        </div>
        
        <!-- Modal for image enlargement -->
        <div class="modal" id="imageModal">
            <span class="close-modal">&times;</span>
            <div class="modal-content">
                <img id="modalImage" src="" alt="Enlarged image">
            </div>
        </div>
        
        <script>
            // Lesson data from Firebase
            const lessonsData = """ + json.dumps(lessons_data) + """;
            
            // DOM Elements
            const lessonTabs = document.querySelector('.lesson-tabs');
            const slidesContainer = document.querySelector('.slides-container');
            const slideCounter = document.querySelector('.slide-counter');
            const prevButton = document.querySelector('.prev-slide');
            const nextButton = document.querySelector('.next-slide');
            const progressBar = document.querySelector('.progress-bar');
            const modal = document.getElementById('imageModal');
            const modalImg = document.getElementById('modalImage');
            const closeModal = document.querySelector('.close-modal');
            
            // State
            let currentLessonIndex = 0;
            let currentSlideIndex = 0;
            let totalSlides = 0;
            
            // Initialize the app
            function initializeApp() {
                // Create lesson tabs
                lessonsData.forEach((lesson, index) => {
                    const tab = document.createElement('div');
                    tab.classList.add('tab');
                    if (index === 0) tab.classList.add('active');
                    tab.textContent = lesson.data.title || `Lesson ${index + 1}`;
                    tab.addEventListener('click', () => switchLesson(index));
                    lessonTabs.appendChild(tab);
                });
                
                // Load the first lesson
                if (lessonsData.length > 0) {
                    loadLesson(0);
                }
                
                // Event listeners
                prevButton.addEventListener('click', showPreviousSlide);
                nextButton.addEventListener('click', showNextSlide);
                closeModal.addEventListener('click', () => modal.style.display = 'none');
                
                // Keyboard navigation
                document.addEventListener('keydown', (e) => {
                    if (e.key === 'ArrowLeft') {
                        showPreviousSlide();
                    } else if (e.key === 'ArrowRight') {
                        showNextSlide();
                    } else if (e.key === 'Escape' && modal.style.display === 'flex') {
                        modal.style.display = 'none';
                    }
                });
                
                // Close modal if clicked outside the image
                window.addEventListener('click', (e) => {
                    if (e.target === modal) {
                        modal.style.display = 'none';
                    }
                });
            }
            
            // Load a specific lesson
            function loadLesson(index) {
                if (index < 0 || index >= lessonsData.length) return;
                
                currentLessonIndex = index;
                currentSlideIndex = 0;
                
                // Update active tab
                document.querySelectorAll('.tab').forEach((tab, i) => {
                    if (i === index) {
                        tab.classList.add('active');
                    } else {
                        tab.classList.remove('active');
                    }
                });
                
                const lesson = lessonsData[index].data;
                const slides = lesson.slides || [];
                totalSlides = slides.length;
                
                // Clear slides container
                slidesContainer.innerHTML = '';
                
                // Create slides
                slides.forEach((slide, slideIndex) => {
                    const slideElement = createSlideElement(slide, slideIndex);
                    slidesContainer.appendChild(slideElement);
                });
                
                // Show first slide
                showSlide(0);
            }
            
            // Create HTML for a slide
            function createSlideElement(slide, index) {
                const slideElement = document.createElement('div');
                slideElement.classList.add('slide');
                slideElement.dataset.index = index;
                
                // Slide title
                const titleElement = document.createElement('h2');
                titleElement.classList.add('slide-title');
                titleElement.textContent = `Slide ${slide.slideNumber}: ${slide.title.split('\\n')[0]}`;
                slideElement.appendChild(titleElement);
                
                // Format content (handling newlines and sections)
                const contentElement = document.createElement('div');
                contentElement.classList.add('slide-content');
                
                const titleParts = slide.title.split('\\n').filter(Boolean);
                
                // First line is the main title, already shown above
                // Format the rest as content sections
                if (titleParts.length > 1) {
                    for (let i = 1; i < titleParts.length; i++) {
                        const part = titleParts[i].trim();
                        
                        // Check if this is a heading (all caps with optional colon)
                        if (part === part.toUpperCase() && part.length > 3) {
                            const sectionElement = document.createElement('div');
                            sectionElement.classList.add('content-section');
                            
                            const headingElement = document.createElement('h3');
                            headingElement.classList.add('content-heading');
                            headingElement.textContent = part;
                            sectionElement.appendChild(headingElement);
                            
                            // Look ahead for content that belongs to this heading
                            let j = i + 1;
                            let sectionContent = '';
                            
                            while (j < titleParts.length && 
                                   !(titleParts[j] === titleParts[j].toUpperCase() && titleParts[j].length > 3)) {
                                sectionContent += titleParts[j] + '\\n';
                                j++;
                            }
                            
                            if (sectionContent) {
                                const contentParagraph = document.createElement('p');
                                contentParagraph.textContent = sectionContent.trim();
                                sectionElement.appendChild(contentParagraph);
                            }
                            
                            contentElement.appendChild(sectionElement);
                            i = j - 1; // Skip to the next section
                        } else {
                            const paragraph = document.createElement('p');
                            paragraph.textContent = part;
                            contentElement.appendChild(paragraph);
                        }
                    }
                }
                
                slideElement.appendChild(contentElement);
                
                // Images
                if (slide.images && slide.images.length > 0) {
                    const imagesElement = document.createElement('div');
                    imagesElement.classList.add('slide-images');
                    
                    slide.images.forEach(image => {
                        if (image.url) {
                            const imageContainer = document.createElement('div');
                            imageContainer.classList.add('slide-image');
                            
                            const img = document.createElement('img');
                            img.src = image.url;
                            img.alt = image.filename || 'Slide image';
                            img.loading = 'lazy';
                            
                            // Make image clickable to enlarge
                            img.addEventListener('click', () => {
                                modalImg.src = image.url;
                                modal.style.display = 'flex';
                            });
                            
                            imageContainer.appendChild(img);
                            imagesElement.appendChild(imageContainer);
                        }
                    });
                    
                    slideElement.appendChild(imagesElement);
                }
                
                return slideElement;
            }
            
            // Switch to a different lesson
            function switchLesson(index) {
                loadLesson(index);
            }
            
            // Show a specific slide
            function showSlide(index) {
                if (index < 0 || index >= totalSlides) return;
                
                currentSlideIndex = index;
                
                // Update slides
                const slides = document.querySelectorAll('.slide');
                slides.forEach((slide, i) => {
                    if (i === index) {
                        slide.classList.add('active');
                    } else {
                        slide.classList.remove('active');
                    }
                });
                
                // Update counter
                slideCounter.textContent = `Slide ${index + 1} of ${totalSlides}`;
                
                // Update progress bar
                const progress = ((index + 1) / totalSlides) * 100;
                progressBar.style.width = `${progress}%`;
                
                // Update button states
                prevButton.disabled = index === 0;
                nextButton.disabled = index === totalSlides - 1;
            }
            
            // Show the previous slide
            function showPreviousSlide() {
                if (currentSlideIndex > 0) {
                    showSlide(currentSlideIndex - 1);
                }
            }
            
            // Show the next slide
            function showNextSlide() {
                if (currentSlideIndex < totalSlides - 1) {
                    showSlide(currentSlideIndex + 1);
                }
            }
            
            // Initialize the app when the DOM is loaded
            document.addEventListener('DOMContentLoaded', initializeApp);
        </script>
    </body>
    </html>
    """
    
    # Create output directory if it doesn't exist
    os.makedirs('student_content', exist_ok=True)
    
    # Save HTML to file
    with open('student_content/interactive_lesson_viewer.html', 'w') as f:
        f.write(html_output)
    
    print("Generated interactive lesson viewer at: student_content/interactive_lesson_viewer.html")
    
    # Also save the lesson data as JSON for reference
    with open('student_content/lesson_data.json', 'w') as f:
        json.dump(lessons_data, f, indent=2)
    
    print("Saved lesson data at: student_content/lesson_data.json")

if __name__ == "__main__":
    generate_student_lesson_viewer() 