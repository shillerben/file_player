import 'package:audio_session/audio_session.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
import 'queue_model.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.playQueue});

  final QueueModel playQueue;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int curIdx = 0;
  bool _paused = false;
  bool _shuffleEnabled = false;
  LoopMode _loopMode = LoopMode.all;
  late AudioPlayer _player;
  late ConcatenatingAudioSource _playlist;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    _playlist = ConcatenatingAudioSource(
        children: widget.playQueue.queue
            .map((element) => AudioSource.uri(element.file.uri,
                tag: MediaItem(
                  id: element.file.path,
                  title: element.file.uri.pathSegments.last,
                )))
            .toList());
    _player.setLoopMode(LoopMode.all).then((value) {
      _player.setAudioSource(_playlist,
          initialIndex: 0, initialPosition: Duration.zero);
    }).then((value) => _player.play());

    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.speech());
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggleShuffle() async {
    setState(() {
      _shuffleEnabled = !_shuffleEnabled;
    });
    await _player.setShuffleModeEnabled(_shuffleEnabled);
  }

  void _toggleLoopMode() async {
    setState(() {
      if (_loopMode == LoopMode.off) {
        _loopMode = LoopMode.all;
      } else if (_loopMode == LoopMode.all) {
        _loopMode = LoopMode.one;
      } else {
        _loopMode = LoopMode.off;
      }
    });
    await _player.setLoopMode(_loopMode);
  }

  void _pause() async {
    setState(() {
      _paused = true;
    });
    await _player.pause();
  }

  void _play() async {
    setState(() {
      _paused = false;
    });
    await _player.play();
  }

  void _next() async {
    await _player.seekToNext();
  }

  void _prev() async {
    await _player.seekToPrevious();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<int?>(
              stream: _player.currentIndexStream,
              builder: ((context, snapshot) {
                final idx = snapshot.data ?? 0;
                final filename =
                    widget.playQueue.at(idx).file.uri.pathSegments.last;
                return Text(filename);
              }),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              child: StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: ((context, snapshot) {
                  final progress = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;
                  final buffered = _player.bufferedPosition;
                  return ProgressBar(
                    progress: progress,
                    buffered: buffered,
                    total: total,
                    onSeek: (duration) => _player.seek(duration),
                  );
                }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: ShapeDecoration(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      color: _shuffleEnabled
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).colorScheme.background),
                  child: IconButton(
                    onPressed: _toggleShuffle,
                    color: _shuffleEnabled
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onBackground,
                    icon: const Icon(Icons.shuffle),
                  ),
                ),
                IconButton(
                    onPressed: _prev, icon: const Icon(Icons.skip_previous)),
                Container(
                  decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: Theme.of(context).colorScheme.onBackground),
                  child: _paused
                      ? IconButton(
                          onPressed: _play,
                          icon: const Icon(Icons.play_arrow),
                          color: Theme.of(context).colorScheme.background,
                        )
                      : IconButton(
                          onPressed: _pause,
                          icon: const Icon(Icons.pause),
                          color: Theme.of(context).colorScheme.background,
                        ),
                ),
                IconButton(onPressed: _next, icon: const Icon(Icons.skip_next)),
                Container(
                  decoration: ShapeDecoration(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      color: _loopMode == LoopMode.off
                          ? Theme.of(context).colorScheme.background
                          : Theme.of(context).colorScheme.onBackground),
                  child: IconButton(
                      onPressed: _toggleLoopMode,
                      color: _loopMode == LoopMode.off
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).colorScheme.background,
                      icon: _loopMode == LoopMode.one
                          ? const Icon(Icons.repeat_one)
                          : const Icon(Icons.repeat)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
