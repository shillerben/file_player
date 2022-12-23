import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FileInfo {
  const FileInfo({required this.thumbnail, required this.file});

  final Uint8List thumbnail;
  final File file;
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.playQueue});

  final List<FileInfo> playQueue;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  var _curIdx = 0;
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    final opts = VideoPlayerOptions(allowBackgroundPlayback: true);

    File fileToPlay = widget.playQueue[_curIdx].file;

    _controller =
        VideoPlayerController.file(fileToPlay, videoPlayerOptions: opts);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _chewieController = ChewieController(
              videoPlayerController: _controller,
              aspectRatio: _controller.value.aspectRatio,
              autoInitialize: false,
              autoPlay: true,
            );
            return Chewie(controller: _chewieController);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
