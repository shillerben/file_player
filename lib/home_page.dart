import 'dart:io';
import 'package:file_player/playlist_view.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'player_page.dart';
import 'queue_model.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title, required this.queue});

  final String title;
  final QueueModel queue;

  void _addFileToQueue() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      for (PlatformFile pf in result.files) {
        if (pf.path != null) {
          queue.add(FileInfo(file: File(pf.path!), thumbnail: Uint8List(4)));
        }
      }
    }
  }

  void Function() _play(BuildContext context) {
    return () {
      if (queue.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: false,
              builder: (context) => PlayerScreen(playQueue: queue),
            ));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: queue.clear, icon: const Icon(Icons.delete)),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _play(context),
          ),
        ],
      ),
      body: Center(
        child: queue.isNotEmpty
            ? PlaylistView(queue: queue)
            : const Text(
                "Queue is empty :(",
                textScaleFactor: 1.25,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFileToQueue,
        tooltip: 'Add File',
        child: const Icon(Icons.add),
      ),
    );
  }
}
