import 'package:flutter/material.dart';
import 'package:apptienganh10/services/api_service.dart';
import 'package:apptienganh10/screens/student/lesson_exercise_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId;
  final String title;
  final String lessonType;
  final String content;
  final List<dynamic>? images;
  final List<dynamic>? audios;
  final List<dynamic>? videos;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.lessonType,
    this.content = '',
    this.images,
    this.audios,
    this.videos,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool isLoading = true;
  List<dynamic> grammarList = [];
  List<dynamic> vocabList = [];
  
  // YouTube controllers để quản lý video inline
  Map<String, YoutubePlayerController> _youtubeControllers = {};
  Set<String> _loadedVideos = {};
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingUrl;
  bool _isPlaying = false;
  bool _isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExtraContent();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose tất cả YouTube controllers
    for (var controller in _youtubeControllers.values) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    try {
      if (_currentPlayingUrl == url && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isAudioLoading = true);
        await _audioPlayer.setUrl(url);
        _currentPlayingUrl = url;
        setState(() => _isAudioLoading = false);
        await _audioPlayer.play();
      }
    } catch (e) {
      setState(() => _isAudioLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi phát audio: $e')));
    }
  }

  Future<void> _fetchExtraContent() async {
    try {
      if (widget.lessonType == 'grammar') {
        final data = await ApiService.getGrammarByLesson(widget.lessonId);
        if (mounted) setState(() => grammarList = data);
      } else if (widget.lessonType == 'vocabulary') {
        final data = await ApiService.getVocabularyByLesson(widget.lessonId);
        if (mounted) setState(() => vocabList = data);
      }
    } catch (e) {
      debugPrint('Error loading extra content: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Content chính của bài học
                  if (widget.content.isNotEmpty) ...[
                    const Text("Nội dung bài học:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.content, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 30),
                  ],

                  // 2. Hiển thị ảnh của Lesson (nếu có) - ẢNH TO
                  if (widget.images != null && widget.images!.isNotEmpty) ...[
                    const Text("Hình ảnh:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                    const SizedBox(height: 10),
                    ...widget.images!.map((img) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          img['url'] ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image, size: 40)),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // 3. Hiển thị video YouTube (nếu có)
                  if (widget.videos != null && widget.videos!.isNotEmpty) ...[
                    const Text("Video:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 10),
                    ...widget.videos!.map((video) => _buildYoutubePlayer(video)),
                    const SizedBox(height: 16),
                  ],

                  // 4. Hiển thị audio (nếu có)
                  if (widget.audios != null && widget.audios!.isNotEmpty) ...[
                    const Text("Audio:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 10),
                    ...widget.audios!.map((audio) => _buildAudioPlayer(audio)),
                    const SizedBox(height: 16),
                  ],

                  // 5. Nội dung Grammar (nếu có)
                  if (widget.lessonType == 'grammar' && grammarList.isNotEmpty) ...[
                    const Text("Ngữ pháp:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 10),
                    ...grammarList.map((g) => _buildGrammarCard(g)),
                    const Divider(height: 30),
                  ],

                  // 6. Nội dung Vocabulary (nếu có)
                  if (widget.lessonType == 'vocabulary' && vocabList.isNotEmpty) ...[
                    const Text("Từ vựng:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    ...vocabList.map((v) => _buildVocabCard(v)),
                    const Divider(height: 30),
                  ],

                  // 7. Button làm bài tập
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment),
                      label: const Text("Làm bài tập"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonExerciseScreen(
                              lessonId: widget.lessonId,
                              lessonTitle: widget.title,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildYoutubePlayer(dynamic video) {
    final type = video['type'] ?? 'upload';
    final url = video['url'] ?? '';
    final youtubeId = video['youtubeId'] ?? YoutubePlayer.convertUrlToId(url);
    final caption = video['caption'] ?? '';

    if ((type == 'youtube' || url.contains('youtube') || url.contains('youtu.be')) && youtubeId != null) {
      final isLoaded = _loadedVideos.contains(youtubeId);
      
      // Tạo controller nếu chưa có
      if (!_youtubeControllers.containsKey(youtubeId)) {
        _youtubeControllers[youtubeId] = YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLoaded)
              // Hiển thị thumbnail, nhấn để load player
              GestureDetector(
                onTap: () {
                  setState(() {
                    _loadedVideos.add(youtubeId);
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.black,
                            child: const Center(child: Icon(Icons.play_circle, size: 60, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              )
            else
              // Hiển thị player inline
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _youtubeControllers[youtubeId]!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                ),
              ),
            if (caption.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(caption, style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          ],
        ),
      );
    } else {
      // Upload video - hiển thị thông báo vì cần xử lý riêng
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.videocam, color: Colors.red, size: 40),
          title: Text(caption.isNotEmpty ? caption : 'Video'),
          subtitle: Text(url.isNotEmpty ? 'Video đã upload' : 'Không có URL'),
          trailing: const Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
          onTap: () {
            if (url.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Video URL: $url')),
              );
            }
          },
        ),
      );
    }
  }

  Widget _buildAudioPlayer(dynamic audio) {
    final url = audio['url'] ?? '';
    final caption = audio['caption'] ?? 'Audio';
    final isCurrentPlaying = _currentPlayingUrl == url && _isPlaying;
    final isCurrentLoading = _currentPlayingUrl == url && _isAudioLoading;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isCurrentLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                )
              : Icon(
                  isCurrentPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.orange,
                ),
        ),
        title: Text(caption, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(isCurrentPlaying ? 'Đang phát...' : 'Nhấn để phát'),
        trailing: Icon(
          isCurrentPlaying ? Icons.stop : Icons.volume_up,
          color: Colors.orange,
        ),
        onTap: () => _playAudio(url),
      ),
    );
  }

  Widget _buildGrammarCard(dynamic g) {
    final images = g['images'] as List<dynamic>? ?? [];
    final audios = g['audios'] as List<dynamic>? ?? [];
    final videos = g['videos'] as List<dynamic>? ?? [];
    final examples = g['examples'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(g['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(g['theory'] ?? ''),
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Ví dụ:", style: TextStyle(fontWeight: FontWeight.w500)),
              ...examples.map((ex) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text("• $ex", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              )),
            ],
            // Media của Grammar
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(images[i]['url'] ?? '', width: 100, height: 100, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            // Audio của Grammar
            if (audios.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...audios.map((a) => _buildAudioPlayer(a)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVocabCard(dynamic v) {
    final images = v['images'] as List<dynamic>? ?? [];
    final audios = v['audios'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v['word'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      if (v['phonetic'] != null && v['phonetic'].toString().isNotEmpty)
                        Text("/${v['phonetic']}/", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(v['meaning'] ?? '', style: const TextStyle(fontSize: 16)),
                      if (v['example'] != null && v['example'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text("Ví dụ: ${v['example']}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
                // Audio button
                if (audios.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _currentPlayingUrl == audios[0]['url'] && _isPlaying 
                          ? Icons.pause_circle 
                          : Icons.play_circle,
                      color: Colors.blue,
                      size: 40,
                    ),
                    onPressed: () => _playAudio(audios[0]['url'] ?? ''),
                  ),
              ],
            ),
            // Ảnh minh họa
            if (images.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(images[i]['url'] ?? '', width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
