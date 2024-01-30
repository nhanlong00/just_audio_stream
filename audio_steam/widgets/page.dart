import 'dart:ffi';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:firestore/import.dart';
import 'package:firestore/screens/audio_steam/models/page_manager.dart';

class AudioPageStream extends StatefulWidget {
  const AudioPageStream({super.key});

  @override
  State<AudioPageStream> createState() => _AudioPageStreamState();
}

class _AudioPageStreamState extends State<AudioPageStream> {
  late final PageManager pageManager;

  @override
  void initState() {
    super.initState();
    pageManager = PageManager();
  }

  @override
  void dispose() {
    pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(),
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: pageManager.progressNotifier,
            builder: (BuildContext ctx, value, __) {
              return ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: (value) {
                  pageManager.seek(value);
                },
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: pageManager.onPreviousSongButtonPressed,
                icon: const Icon(Icons.skip_previous),
              ),
              ValueListenableBuilder<ButtonState>(
                valueListenable: pageManager.buttonNotifier,
                builder: (_, value, __) {
                  switch (value) {
                    case ButtonState.loading:
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 32.0,
                        height: 32.0,
                        child: const CircularProgressIndicator(),
                      );
                    case ButtonState.paused:
                      return IconButton(
                        onPressed: pageManager.playAudio,
                        icon: const Icon(Icons.play_arrow),
                      );
                    case ButtonState.playing:
                      return IconButton(
                        onPressed: pageManager.pauseAudio,
                        icon: const Icon(Icons.pause),
                      );
                  }
                },
              ),
              IconButton(
                onPressed: pageManager.onNextSongButtonPressed,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: pageManager.speedSongNotifier,
                builder: (_, value, __) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    width: 65,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: InkWell(
                      onTap: () {
                        pageManager.onSpeedButtonPress();
                      },
                      child: Text('$value x', style: const TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: pageManager.isShuffleModeEnabledNotifier,
                builder: (_, isShuffle, __) {
                  return IconButton(
                    onPressed: pageManager.onShuffleButtonPressed,
                    icon: (isShuffle)
                        ? const Icon(Icons.shuffle)
                        : Icon(Icons.shuffle, color: Colors.red[600]),
                  );
                },
              ),
              ValueListenableBuilder<LoopState> (
                valueListenable: pageManager.loopNotifier,
                builder: (_, value, __) {
                  Icon icon;
                  switch (value) {
                    case LoopState.off:
                      // TODO: Handle case off.
                      icon = const Icon(Icons.repeat);
                      break;
                    case LoopState.all:
                      // TODO: Handle case all.
                      icon = Icon(Icons.repeat, color: Colors.red[600]);
                      break;
                    case LoopState.one:
                      // TODO: Handle case one.
                      icon = Icon(Icons.repeat_one, color: Colors.red[600]);
                      break;
                  }
                  return IconButton(
                    icon: icon,
                    onPressed: pageManager.onRepeatButtonPressed,
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: pageManager.volumeSongNotifier,
                builder: (_, value, __) {
                  print('value volume check :>>>>>>>> ${value.volumeMax}');
                  return SizedBox(
                    width: 100,
                    child: Slider(
                      value: value.volumeMax - value.volumeBuffered,
                      max: value.volumeMax,
                      min: value.volumeMin,
                      onChanged: (value) {
                         pageManager.onVolumeProgressBar();                    // Half as loud
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
