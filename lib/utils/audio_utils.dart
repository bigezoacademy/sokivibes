import 'package:just_audio/just_audio.dart';

class AudioUtils {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
