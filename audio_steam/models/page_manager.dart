import 'package:firestore/import.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  static const url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  late AudioPlayer _audioPlayer;

  final currentSongTitleNotifier = ValueNotifier<String>(''); // get currentTitleSong
  final playlistNotifier = ValueNotifier<List<String>>([]); // get list Play
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final speedSongNotifier = ValueNotifier<double>(1.0);

  // instance notifier of ProgressBar
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  final volumeSongNotifier = ValueNotifier<VolumeProgressBarState>(
      VolumeProgressBarState(
          volumeMin: 0.0,
          volumeBuffered: 0.0,
          volumeMax: 1.0
      )

  );

  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final loopNotifier = ValueNotifier<LoopState>(LoopState.off);

  // instance init()
  PageManager() {
    _init();
  }

  void _init() async {
    // instance audio
    _audioPlayer = AudioPlayer();

    _listenForChangesInSequenceState();
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
        // _audioPlayer.setVolume(0.1);
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

  // back to previous song
  void onPreviousSongButtonPressed() {
    _audioPlayer.seekToPrevious();
  }

  // next to song
  void onNextSongButtonPressed() {
    _audioPlayer.seekToNext();
  }

  // loop
  void onRepeatButtonPressed() {
    LoopState currentLoopState = loopNotifier.value;

    switch (currentLoopState) {
      case LoopState.off:
        _audioPlayer.setLoopMode(LoopMode.all);
        loopNotifier.value = LoopState.all;
        break;
      case LoopState.all:
        _audioPlayer.setLoopMode(LoopMode.one);
        loopNotifier.value = LoopState.one;
        break;
      case LoopState.one:
        _audioPlayer.setLoopMode(LoopMode.off);
        loopNotifier.value = LoopState.off;
        break;
    }
  }

  // speed
  void onSpeedButtonPress() async {
    double currentSpeed = speedSongNotifier.value;

    if (!empty(currentSpeed) && currentSpeed < 2.0) {
      currentSpeed += 0.25;
    } else {
      currentSpeed = 1.0;
    }

    await _audioPlayer.setSpeed(currentSpeed);
    speedSongNotifier.value = currentSpeed;
  }

  // volume
  void onVolumeProgressBar() async {
    double currentVolume = volumeSongNotifier.value.volumeMin;
    currentVolume = volumeSongNotifier.value.volumeMax - volumeSongNotifier.value.volumeBuffered;
    await _audioPlayer.setVolume(currentVolume);
    print('currentVolume $currentVolume');
  }

  // shuffle
  void onShuffleButtonPressed() async {
    final enable = !_audioPlayer.shuffleModeEnabled;

    if(enable) {
      await  _audioPlayer.shuffle();
    }
    await _audioPlayer.setShuffleModeEnabled(enable);
  }



  void _listenForChangesInSequenceState() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      // update current song title
      // final currentItem = sequenceState.currentSource;
      // final title = currentItem?.tag as String?;
      // currentSongTitleNotifier.value = title ?? '';

      // update playlist
      // final playlist = sequenceState.effectiveSequence;
      // final titles = playlist.map((item) => item.tag as String).toList();
      // playlistNotifier.value = titles;

      // update shuffle mode
      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;

      // update previous and next buttons
      // if (playlist.isEmpty || currentItem == null) {
      //   isFirstSongNotifier.value = true;
      //   isLastSongNotifier.value = true;
      // } else {
      //   isFirstSongNotifier.value = playlist.first == currentItem;
      //   isLastSongNotifier.value = playlist.last == currentItem;
      // }
    });
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

// instance models VolumeProgressBarState
class VolumeProgressBarState {
  VolumeProgressBarState({
    required this.volumeMin,
    required this.volumeBuffered,
    required this.volumeMax,
  });

  final double volumeMin;
  final double volumeBuffered;
  final double volumeMax;
}

// instance enum state action
enum ButtonState { paused, loading, playing }

// instance enum state loop action
enum LoopState {off, all, one}

