import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _play(context),
          ),
        ],
      ),
      body: Center(
        child: queue.isNotEmpty
            ? ReorderableListView.builder(
                itemCount: queue.length,
                onReorder: queue.moveItemAt,
                itemBuilder: (context, idx) {
                  if (idx < queue.length) {
                    return Slidable(
                      key: Key('$idx'),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.2,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              queue.removeAt(idx);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          )
                        ],
                      ),
                      child: ListTile(
                          title:
                              Text(queue.at(idx).file.uri.pathSegments.last)),
                    );
                  }
                  return const ListTile();
                },
              )
            : const Text("Queue is empty :("),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFileToQueue,
        tooltip: 'Add File',
        child: const Icon(Icons.add),
      ),
    );
  }
}
