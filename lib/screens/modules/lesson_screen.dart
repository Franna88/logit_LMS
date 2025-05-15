import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_network/image_network.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart' show kIsWeb;

class LessonScreen extends StatefulWidget {
  final String moduleTitle;
  final String lessonTitle;
  final String lessonContent;
  final List<String>? imageUrls;
  final Map<String, dynamic>? slideData;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const LessonScreen({
    super.key,
    required this.moduleTitle,
    required this.lessonTitle,
    required this.lessonContent,
    this.imageUrls,
    this.slideData,
    required this.isCompleted,
    required this.onComplete,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late ScrollController _scrollController;
  bool _showCompleteButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Show the complete button when user scrolls near the bottom
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_showCompleteButton) {
      setState(() {
        _showCompleteButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernLayout(
      title: widget.moduleTitle,
      showBackButton: true,
      currentIndex: -1,
      child: Stack(
        children: [
          // Lesson Content
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Module Progress Indicator
                _buildProgressIndicator(),

                // Lesson Title Card
                _buildLessonTitleCard(),

                const SizedBox(height: 24),

                // Content Container with shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // If Firebase slide data is available, use it instead of local data
                      if (widget.slideData != null)
                        _buildSlideContent(widget.slideData!)
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display images if available (legacy support)
                            if (widget.imageUrls != null &&
                                widget.imageUrls!.isNotEmpty)
                              _buildImageSection(widget.imageUrls!),

                            // Lesson Content Text (legacy support)
                            _buildContentText(widget.lessonContent),
                          ],
                        ),
                    ],
                  ),
                ),

                // Bottom padding to ensure content isn't hidden behind the navigation bar
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildNavigationBar(),
          ),
        ],
      ),
    );
  }

  // Build progress indicator
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Text(
            'Module Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: 0.7, // This should be calculated based on course progress
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // Build lesson title card
  Widget _buildLessonTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slide number or lesson indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Lesson Content',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lesson Title
          Text(
            widget.lessonTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          // Learning time estimate
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Estimated time: 15 minutes', // This could be a parameter
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build content from Firebase slide data
  Widget _buildSlideContent(Map<String, dynamic> slideData) {
    // Process image data to ensure asset paths are properly formatted
    List<dynamic> processImageData(List<dynamic> imageData) {
      return imageData.map((image) {
        if (image is Map) {
          // Handle 'path' field structure (used for local assets)
          if (image.containsKey('path') && !image.containsKey('url')) {
            // Add the URL field based on the path
            String path = image['path'] as String;
            return {
              ...image,
              'url': 'output/$path', // Add prefix for asset path
              'isAsset': true, // Flag to indicate this is a local asset
            };
          }
        }
        return image;
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display slide title if not already shown in the title card
        if (slideData.containsKey('title') &&
            slideData['title'] != widget.lessonTitle)
          _buildSectionTitle(slideData['title']),

        // Display any additional content fields
        if (slideData.containsKey('content'))
          _buildContentMetadata(slideData['content']),

        // Display images if available
        if (slideData.containsKey('images') &&
            slideData['images'] is List &&
            (slideData['images'] as List).isNotEmpty)
          _buildFirebaseImageSection(
            processImageData(slideData['images'] as List<dynamic>),
          ),
      ],
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // Method to display content metadata in a more appealing card
  Widget _buildContentMetadata(dynamic content) {
    if (content is List && content.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Key Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            // Content items with enhanced styling
            ...content
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Enhanced method to display Firebase images with better styling and local fallbacks
  Widget _buildFirebaseImageSection(List<dynamic> imageData) {
    // Calculate responsive width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth > 600 ? 600.0 : screenWidth - 80;

    // Prepare fallback images based on lesson title
    List<String> getFallbackImages() {
      final lessonTitle = widget.lessonTitle;
      if (lessonTitle.contains("Bleeding") ||
          lessonTitle.contains("BLEEDING")) {
        return [
          'output/images/Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png',
          'output/images/Lesson_01_slide_4_2379cb9f-b8e6-417a-bebb-9ccb546977c3.png',
          'output/images/Lesson_01_slide_5_5cd6309f-1f57-4a19-87e9-ec5279ddd360.png',
        ];
      } else if (lessonTitle.contains("Emergency") ||
          lessonTitle.contains("First Aid")) {
        return [
          'output/images/Lesson_01_slide_6_ae28a4dc-4a14-4397-82f1-a1aae2c7aba8.png',
          'output/images/Lesson_02_slide_11_849d2d38-dc02-4db8-a7aa-17e87cae7a73.png',
        ];
      } else if (lessonTitle.contains("Pneumothorax") ||
          lessonTitle.contains("Chest")) {
        return [
          'output/images/Lesson_02_slide_1_37374d19-33c2-4c33-8f26-d0eb1ef05112.png',
          'output/images/Lesson_02_slide_3_517abed7-fe91-4901-8ff2-b5fd9322a4ad.png',
        ];
      } else if (lessonTitle.contains("Burns") ||
          lessonTitle.contains("Skin")) {
        return [
          'output/images/Lesson_02_slide_6_3963ee76-2390-439f-8216-2723cc1431b7.png',
          'output/images/Lesson_02_slide_10_ce4f234e-96e6-45f4-a677-f44040018d80.png',
        ];
      } else {
        return [
          'output/images/Lesson_01_slide_1_a5708d93-bb45-4572-9616-69c45188d6fa.png',
          'output/images/Lesson_02_slide_1_37374d19-33c2-4c33-8f26-d0eb1ef05112.png',
        ];
      }
    }

    final fallbackImages = getFallbackImages();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        for (var i = 0; i < imageData.length; i++)
          if (imageData[i] is Map)
            Builder(
              builder: (context) {
                final imageMap = imageData[i] as Map;
                final bool isAsset =
                    imageMap.containsKey('isAsset') &&
                    imageMap['isAsset'] == true;
                final String imageUrl =
                    imageMap.containsKey('url')
                        ? imageMap['url'] as String
                        : '';
                final String fallbackImage =
                    i < fallbackImages.length
                        ? fallbackImages[i]
                        : fallbackImages[0];

                // Track if remote image failed to load
                final ValueNotifier<bool> useFallback = ValueNotifier<bool>(
                  isAsset,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Card with enhanced border and shadow
                      Container(
                        width: imageWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9, // Standard aspect ratio
                            child: ValueListenableBuilder<bool>(
                              valueListenable: useFallback,
                              builder: (context, useLocalImage, child) {
                                if (useLocalImage) {
                                  // If it's an asset, use Image.asset directly
                                  final assetPath =
                                      isAsset ? imageUrl : fallbackImage;
                                  return Image.asset(
                                    assetPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // If asset fails, show error
                                      print('Error loading asset: $assetPath');
                                      print('Error: $error');
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Unable to load image',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              assetPath,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }

                                // Otherwise try to load remote image
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Shimmer loading background
                                    Container(color: Colors.grey[200]),

                                    // Try to load remote image
                                    kIsWeb
                                        ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                color: Colors.blue,
                                                strokeWidth: 3,
                                              ),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            // On error, trigger fallback
                                            Future.microtask(
                                              () => useFallback.value = true,
                                            );
                                            return const SizedBox();
                                          },
                                        )
                                        : ImageNetwork(
                                          image: imageUrl,
                                          width: imageWidth,
                                          height: imageWidth * 9 / 16,
                                          duration: 800,
                                          curve: Curves.easeIn,
                                          onPointer: true,
                                          debugPrint: false,
                                          fitAndroidIos: BoxFit.cover,
                                          fitWeb: BoxFitWeb.cover,
                                          onLoading: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.blue,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                          onError: Center(
                                            child: Builder(
                                              builder: (context) {
                                                // On error, trigger fallback
                                                Future.microtask(
                                                  () =>
                                                      useFallback.value = true,
                                                );
                                                return const SizedBox();
                                              },
                                            ),
                                          ),
                                        ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Enhanced image caption with clearer styling
                      Container(
                        margin: const EdgeInsets.only(top: 12, left: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: useFallback,
                                builder: (context, useLocalImage, child) {
                                  // Use description if available
                                  final hasDescription =
                                      imageMap.containsKey('description') &&
                                      imageMap['description'] != null;

                                  return Text(
                                    hasDescription
                                        ? imageMap['description']
                                        : useLocalImage
                                        ? _getImageCaption(fallbackImage, i)
                                        : 'Image for ${widget.lessonTitle}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }

  // Legacy method for local image URLs with improved styling
  Widget _buildImageSection(List<String> imageUrls) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth > 600 ? 600.0 : screenWidth - 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${imageUrls.length} images for this lesson',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        for (int i = 0; i < imageUrls.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with shadow
                Container(
                  width: imageWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        imageUrls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Image not available",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Auto-generated caption for local images
                Container(
                  margin: const EdgeInsets.only(top: 12, left: 4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          // Extract a caption from the image filename
                          _getImageCaption(imageUrls[i], i),
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Helper method to generate captions for local images
  String _getImageCaption(String imagePath, int index) {
    // Extract filename from path
    final filename = imagePath.split('/').last;

    // Map specific image filenames to descriptive captions
    if (filename.contains('Lesson_01_slide_1')) {
      return "Bleeding management procedures for open wounds";
    } else if (filename.contains('Lesson_01_slide_4')) {
      return "RICER treatment protocol for soft tissue injuries";
    } else if (filename.contains('Lesson_01_slide_5')) {
      return "Signs and symptoms of shock in emergency situations";
    } else if (filename.contains('Lesson_01_slide_6')) {
      return "Different types of shock and their characteristics";
    } else if (filename.contains('Lesson_01_slide_12')) {
      return "Anatomical illustration of chest trauma and injuries";
    } else if (filename.contains('Lesson_01_slide_14')) {
      return "Flail chest treatment and management procedure";
    } else if (filename.contains('Lesson_01_slide_15')) {
      return "Contusions and hematoma identification and treatment";
    } else if (filename.contains('Lesson_02_slide_1')) {
      return "Pneumothorax diagnosis and emergency management";
    } else if (filename.contains('Lesson_02_slide_3')) {
      return "Pulmonary embolism identification and treatment protocols";
    } else if (filename.contains('Lesson_02_slide_6')) {
      return "Anatomy of skin layers relevant to burn treatment";
    } else if (filename.contains('Lesson_02_slide_10')) {
      return "Burn severity assessment chart based on body percentage";
    } else if (filename.contains('Lesson_02_slide_11')) {
      return "Proper treatment procedure for different types of burns";
    } else if (filename.contains('Lesson_02_slide_12')) {
      return "Electrical injuries and associated treatment protocols";
    } else if (filename.contains('Lesson_02_slide_13')) {
      return "Types of poisoning and exposure routes identification";
    } else if (filename.contains('Lesson_02_slide_14')) {
      return "Signs and symptoms of various types of poisoning";
    }

    // Generic captions based on lesson title and index
    final lessonTitle = widget.lessonTitle;
    if (lessonTitle.contains("Bleeding") || lessonTitle.contains("BLEEDING")) {
      final topics = [
        "Proper wound management procedure illustration",
        "Bleeding control techniques demonstration",
        "First aid protocol for severe bleeding",
        "Emergency response flowchart for bleeding",
        "Patient assessment for bleeding injuries",
      ];
      return _getSafeCaption(topics, index);
    } else if (lessonTitle.contains("Emergency") ||
        lessonTitle.contains("Procedures")) {
      final topics = [
        "Emergency procedure protocol illustration",
        "Critical response steps in emergency situations",
        "First responder techniques for urgent care",
        "Patient stabilization procedure diagram",
        "Safety protocol for emergency management",
      ];
      return _getSafeCaption(topics, index);
    } else if (lessonTitle.contains("Injury") ||
        lessonTitle.contains("Trauma")) {
      final topics = [
        "Trauma assessment checklist visualization",
        "Injury classification and management guide",
        "Treatment protocol for traumatic injuries",
        "Patient care procedure for trauma",
        "Injury evaluation flowchart",
      ];
      return _getSafeCaption(topics, index);
    }

    // Default caption
    return "Illustration for ${widget.lessonTitle}";
  }

  // Helper to safely get a caption by index with fallback
  String _getSafeCaption(List<String> options, int index) {
    if (index < options.length) {
      return options[index];
    }
    return options.first;
  }

  // Enhanced content text building with better typography and styling
  Widget _buildContentText(String content) {
    final paragraphs = content.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          paragraphs.map((paragraph) => _formatParagraph(paragraph)).toList(),
    );
  }

  // Enhanced paragraph formatting with better typography
  Widget _formatParagraph(String paragraph) {
    // Check if this is a heading (starts with # or ##)
    if (paragraph.startsWith('## ')) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0, top: 24.0),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.blue, width: 2)),
        ),
        child: Text(
          paragraph.substring(3),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else if (paragraph.startsWith('# ')) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24.0, top: 32.0),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(color: Colors.blue, width: 3),
          ),
          color: Colors.blue.withOpacity(0.05),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Text(
            paragraph.substring(2),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }
    // Enhanced list with better bullet points and spacing
    else if (paragraph.contains('\n1. ') ||
        paragraph.contains('\n- ') ||
        paragraph.startsWith('1. ') ||
        paragraph.startsWith('- ')) {
      final lines = paragraph.split('\n');

      return Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              lines.map((line) {
                if (line.startsWith('- ')) {
                  return _buildBulletPoint(line.substring(2), false);
                } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
                  final match = RegExp(r'^\d+\.\s').firstMatch(line);
                  if (match != null) {
                    return _buildBulletPoint(
                      line.substring(match.end),
                      true,
                      number: match.group(0)?.trim().replaceAll('.', '') ?? '',
                    );
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    line,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                );
              }).toList(),
        ),
      );
    }
    // Regular paragraph with better typography
    else {
      return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          paragraph,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            letterSpacing: 0.3,
            color: Colors.black87,
          ),
        ),
      );
    }
  }

  // Helper method for building enhanced bullet points
  Widget _buildBulletPoint(String text, bool isNumbered, {String number = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNumbered)
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12, top: 8),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced navigation bar with modern styling
  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          OutlinedButton.icon(
            onPressed: widget.hasPrevious ? widget.onPrevious : null,
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),

          // Complete/Mark as Read Button
          if (_showCompleteButton || widget.isCompleted)
            ElevatedButton.icon(
              onPressed: widget.isCompleted ? null : widget.onComplete,
              icon: Icon(
                widget.isCompleted ? Icons.check_circle : Icons.check,
                size: 18,
              ),
              label: Text(
                widget.isCompleted ? 'Completed' : 'Mark as Complete',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.green,
                foregroundColor:
                    widget.isCompleted ? Colors.green : Colors.white,
                disabledBackgroundColor: Colors.green.withOpacity(0.2),
                disabledForegroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),

          // Next Button - Enhanced styling
          ElevatedButton.icon(
            onPressed: widget.hasNext ? widget.onNext : null,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
