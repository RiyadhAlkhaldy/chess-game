import '../services/audio_service.dart';

class PlaySoundUseCase {
  final AudioPlayerService _audioPlayerService;

  PlaySoundUseCase(this._audioPlayerService);

  Future<void> executeMoveSound() async {
    await _audioPlayerService.playMoveSound();
  }

  Future<void> executeCaptureSound() async {
    await _audioPlayerService.playCaptureSound();
  }

  Future<void> executeCheckSound() async {
    await _audioPlayerService.playCheckSound();
  }

  Future<void> executeResetGameSound() async {
    await _audioPlayerService.playResetGameSound();
  }

  Future<void> executePromoteSound() async {
    await _audioPlayerService.playPromoteSound();
  }
}
