import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'queue_model.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.playQueue});

  final QueueModel playQueue;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  var _curIdx = 0;
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  late Future<void> _initializeVideoPlayerFuture;
  final _videoPlayerOpts = VideoPlayerOptions(allowBackgroundPlayback: true);

  @override
  void initState() {
    super.initState();

    File fileToPlay = widget.playQueue.at(_curIdx).file;

    _controller = VideoPlayerController.file(fileToPlay,
        videoPlayerOptions: _videoPlayerOpts);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void _newVideo() {
    setState(() {
      _controller.dispose();
      _chewieController.dispose();

      File fileToPlay = widget.playQueue.at(_curIdx).file;

      _controller = VideoPlayerController.file(fileToPlay,
          videoPlayerOptions: _videoPlayerOpts);
      _initializeVideoPlayerFuture = _controller.initialize();
    });
  }

  void _next() {
    if (_curIdx + 1 < widget.playQueue.length) {
      _curIdx++;
      _newVideo();
    }
  }

  void _prev() {
    if (_curIdx > 0) {
      _curIdx--;
      _newVideo();
    }
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
              // controlsSafeAreaMinimum: const EdgeInsets.only(bottom: 25.0),
            );
            return Container(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Chewie(controller: _chewieController),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: _prev, child: const Text("Previous")),
                      TextButton(onPressed: _next, child: const Text("Next")),
                      // IconButton(onPressed: _prev, icon: const Icon(Icons.skip_previous)),
                      // IconButton(onPressed: _next, icon: const Icon(Icons.skip_next)),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
