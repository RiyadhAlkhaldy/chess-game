// import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class MusicController extends GetxController {
  // final player = AudioPlayer();

  @override
  // ignore: unnecessary_overrides
  void onInit() {
    super.onInit();
    // player.setReleaseMode(ReleaseMode.loop);
    // player.play(AssetSource('music.mp3'));
  }

  @override
  void onClose() {
    // player.stop();
    super.onClose();
  }
}
