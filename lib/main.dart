import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Player',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: 'File Player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _queue = <FileInfo>[];

  void _addFileToQueue() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      for (PlatformFile pf in result.files) {
        setState(() {
          if (pf.path != null) {
            _queue.add(FileInfo(file: File(pf.path!), thumbnail: Uint8List(4)));
          }
        });
      }
    }
  }

  void _play() {
    if (_queue.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: false,
            builder: (context) => PlayerScreen(playQueue: _queue),
          ));
    }
  }

  void _reorderQueue(int idxStart, int idxEnd) {
    setState(() {
      if (idxStart < idxEnd) {
        idxEnd -= 1;
      }
      var elem = _queue.removeAt(idxStart);
      _queue.insert(idxEnd, elem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _play,
          ),
        ],
      ),
      body: Center(
        child: _queue.isNotEmpty
            ? ReorderableListView.builder(
                itemCount: _queue.length,
                onReorder: _reorderQueue,
                itemBuilder: (context, idx) {
                  if (idx < _queue.length) {
                    return ListTile(
                      key: Key('$idx'),
                      title: Text(_queue[idx].file.path),
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
