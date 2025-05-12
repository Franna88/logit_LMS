import 'package:flutter/material.dart';
import '../../widgets/modern_layout.dart';

class VideoScreen extends StatefulWidget {
  final String moduleTitle;
  final String videoTitle;
  final String videoUrl; // Path to the video asset or URL
  final String? description;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const VideoScreen({
    super.key,
    required this.moduleTitle,
    required this.videoTitle,
    required this.videoUrl,
    this.description,
    required this.isCompleted,
    required this.onComplete,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _bufferPosition = 0;
  double _videoDuration = 100; // Placeholder value
  bool _showControls = true;
  bool _hasWatchedEnough = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // In a real implementation, you would initialize a video player here
    // For this demo, we'll simulate video playback
    _startVideoSimulation();
  }

  void _startVideoSimulation() {
    // Simulate video loading and playing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _videoDuration = 300; // 5 minutes video length
        });

        // Auto-hide controls after a few seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showControls = false;
            });
          }
        });

        // Simulate video progress
        Future.delayed(const Duration(seconds: 1), _updateVideoProgress);
      }
    });
  }

  void _updateVideoProgress() {
    if (!mounted || !_isPlaying) return;

    setState(() {
      _currentPosition += 1;
      if (_currentPosition > _videoDuration) {
        _currentPosition = _videoDuration;
        _isPlaying = false;
        _hasWatchedEnough = true;
      }

      // Update buffer position (always ahead of current position)
      _bufferPosition =
          (_currentPosition + 30) > _videoDuration
              ? _videoDuration
              : _currentPosition + 30;
    });

    // Continue updating if still playing
    if (_isPlaying) {
      Future.delayed(const Duration(seconds: 1), _updateVideoProgress);
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        Future.delayed(const Duration(seconds: 1), _updateVideoProgress);
      }
    });
  }

  void _showHideControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after a few seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _formatDuration(double seconds) {
    final Duration duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool _isUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModernLayout(
        title: widget.moduleTitle,
        showBackButton: true,
        currentIndex: -1,
        child: Stack(
          children: [
            // Main content with scrolling
            SingleChildScrollView(
              child: Column(
                children: [
                  // Video Player Area (smaller by default, full-screen when expanded)
                  _buildVideoPlayer(),

                  // Video Information
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Title
                        Text(
                          widget.videoTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Video URL
                        if (_isUrl(widget.videoUrl)) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.link,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.videoUrl,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // In a real app, this would open the URL in a browser
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Opening video URL...'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('Open'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Video Description
                        if (widget.description != null) ...[
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description!,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Notes area
                        _buildNotesArea(),

                        // Key Points Section
                        const SizedBox(height: 24),
                        _buildKeyPointsSection(),

                        // Bottom space for navigation bar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar - fixed at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Calculate dimensions based on expansion state
    double height = _isExpanded ? 400 : 180;

    return Stack(
      children: [
        GestureDetector(
          onTap: _showHideControls,
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                // Video Placeholder (in a real app, this would be your video player widget)
                Center(
                  child: Image.asset(
                    'lib/assets/images/course.jpg',
                    fit: BoxFit.contain,
                    height: height * 0.8,
                  ),
                ),

                // Loading indicator (only visible when buffering)
                if (_isPlaying && _currentPosition == 0)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                // Video Controls (visible when _showControls is true)
                if (_showControls)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Play/Pause button in the middle
                        Expanded(
                          child: Center(
                            child: IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                _isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ),
                        ),

                        // Progress bar and time at the bottom
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                _formatDuration(_currentPosition),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    // Buffer progress
                                    Container(
                                      height: 4,
                                      width:
                                          (_bufferPosition / _videoDuration) *
                                          (MediaQuery.of(context).size.width -
                                              90),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    // Playback progress
                                    Container(
                                      height: 4,
                                      width:
                                          (_currentPosition / _videoDuration) *
                                          (MediaQuery.of(context).size.width -
                                              90),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    // Dragable thumb
                                    Positioned(
                                      left:
                                          (_currentPosition / _videoDuration) *
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  90) -
                                          8,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          // Calculate new position based on drag
                                          final RenderBox box =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final double localX =
                                              box
                                                  .globalToLocal(
                                                    details.globalPosition,
                                                  )
                                                  .dx;
                                          final double percent =
                                              localX /
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  90);
                                          setState(() {
                                            _currentPosition =
                                                percent * _videoDuration;
                                            if (_currentPosition < 0)
                                              _currentPosition = 0;
                                            if (_currentPosition >
                                                _videoDuration)
                                              _currentPosition = _videoDuration;
                                          });
                                        },
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(_videoDuration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Expand/Collapse Button
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: Icon(
                _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: _toggleExpand,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              iconSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Take notes while watching...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Save Notes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Key Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildKeyPoints(),
        ],
      ),
    );
  }

  List<Widget> _buildKeyPoints() {
    List<String> points = [
      'Always check your equipment before diving',
      'Maintain proper buoyancy control throughout the dive',
      'Stay within your training and experience level',
      'Plan your dive and dive your plan',
      'Monitor your air supply frequently',
    ];

    return points.map((point) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                point,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton.icon(
            onPressed: widget.hasPrevious ? widget.onPrevious : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.white,
              elevation: 0,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),

          // Complete/Mark as Watched Button
          ElevatedButton.icon(
            onPressed:
                widget.isCompleted || !_hasWatchedEnough
                    ? null
                    : widget.onComplete,
            icon: Icon(widget.isCompleted ? Icons.check_circle : Icons.check),
            label: Text(widget.isCompleted ? 'Completed' : 'Mark as Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.green,
              foregroundColor: widget.isCompleted ? Colors.green : Colors.white,
              disabledBackgroundColor:
                  _hasWatchedEnough
                      ? Colors.green
                      : Colors.grey.withOpacity(0.2),
              disabledForegroundColor:
                  _hasWatchedEnough
                      ? Colors.white
                      : Colors.grey.withOpacity(0.38),
            ),
          ),

          // Next Button
          ElevatedButton.icon(
            onPressed: widget.hasNext ? widget.onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
