import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  const AudioPlayerWidget({super.key, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.setUrl(widget.url);
      await _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: _playPause,
    );
  }
}
