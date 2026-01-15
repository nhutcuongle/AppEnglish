import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class AudioPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;

  const AudioPlayerWidget({super.key, this.url, this.file});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    _audioPlayer = AudioPlayer();
    
    // Configure for music/media playback
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        _audioPlayer.seek(Duration.zero);
      }
    });

    _audioPlayer.onLog.listen((msg) {
      debugPrint('AudioPlayer Log: $msg');
    });

    _setSource();
  }

  Future<void> _setSource() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    try {
      Source? source;
      if (widget.file != null) {
        source = DeviceFileSource(widget.file!.path);
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        // Clean URL just in case
        final cleanUrl = widget.url!.trim();
        source = UrlSource(cleanUrl);
      }

      if (source != null) {
        await _audioPlayer.setSource(source);
        // Sometimes onDurationChanged doesn't fire immediately for some formats
        // We can try to get duration manually after a short delay
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted && _duration == Duration.zero) {
            final d = await _audioPlayer.getDuration();
            if (d != null && d != Duration.zero) {
              setState(() {
                _duration = d;
                _isLoading = false;
              });
            }
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Không có nguồn âm thanh";
        });
      }
    } catch (e) {
      debugPrint('Error setting audio source: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Lỗi tải âm thanh";
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url || widget.file?.path != oldWidget.file?.path) {
      _setSource();
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_errorMessage != null) {
      _setSource(); // Try to reload
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position >= _duration && _duration > Duration.zero) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể phát âm thanh: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _errorMessage != null ? Colors.red.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _errorMessage != null ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 48, 
                  height: 48, 
                  child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                )
              else if (_errorMessage != null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.orange, size: 28),
                  onPressed: _setSource,
                  tooltip: _errorMessage,
                )
              else
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.blue, size: 36),
                  onPressed: _togglePlay,
                ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                  value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0),
                  onChanged: (_isLoading || _errorMessage != null) ? null : (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    '${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
