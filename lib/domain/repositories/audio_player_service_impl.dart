import 'package:audioplayers/audioplayers.dart';

import '../../core/constants/app_images_sounds.dart';
import '../services/audio_service.dart';

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playMoveSound() async {
    await _audioPlayer.play(AssetSource(Assets.soundsMoveSelf));
  }

  @override
  Future<void> playCaptureSound() async {
    await _audioPlayer.play(AssetSource(Assets.soundsCapture));
  }

  @override
  Future<void> playCheckSound() async {
    await _audioPlayer.play(AssetSource(Assets.soundsMoveCheck));
  }

  @override
  Future<void> playPromoteSound()async {
      await _audioPlayer.play(AssetSource(Assets.soundsPromote));

  }

  @override
  Future<void> playResetGameSound()async{ 
    await _audioPlayer.play(AssetSource(Assets.sounds58595905RummagingSoundsAccompanyChessPiecesGoingIntoACaseByVadisoundlibraryPreview));

  }
}
