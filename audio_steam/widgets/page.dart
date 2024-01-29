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
                }
              );
            },
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
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
