import 'package:firestore/import.dart';
import 'package:firestore/screens/audio_steam/widgets/page.dart';

class AudioStream extends StatelessWidget {
  const AudioStream({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Steam'),
        centerTitle: true,
      ),
      body: const AudioPageStream(),
    );
  }
}
