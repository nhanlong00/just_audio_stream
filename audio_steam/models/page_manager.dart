import 'package:firestore/import.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  static const url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  late AudioPlayer _audioPlayer;

  // instance notifier of ProgressBar
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  // instance init()
  PageManager() {
    _init();
  }

  void _init() async {
    // instance audio
    _audioPlayer = AudioPlayer();

    // set Url audio to network
    await _audioPlayer.setUrl(url);

    // handle listen event state of playerStateStream
    _audioPlayer.playerStateStream.listen((event) {
      final isPlaying = event.playing;
      final processingState = event.processingState;

      if(processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if(!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if(processingState != ProcessingState.completed){
        buttonNotifier.value = ButtonState.playing;
      } else { // complete
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    // positionStream provide update frequently when di ngón tay trên progressbar
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    // bufferedPositionStream provide the upadte không liên tục giữa các quãng, khi có các bước nhảy xảy ra
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    _audioPlayer.durationStream.listen((totalDuration ) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  // dispose when tác vụ bị hủy
  void dispose() {
    _audioPlayer.dispose();
  }

  // start audio
  void playAudio() {
    _audioPlayer.play();
  }

  // pause audio
  void pauseAudio() {
    _audioPlayer.pause();
  }

  // seek a position audio
  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

}


// instance models ProgressBarState
class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}
// instance enum state action
enum ButtonState { paused, loading, playing }