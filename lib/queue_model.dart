import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FileInfo {
  const FileInfo({required this.thumbnail, required this.file});

  final Uint8List thumbnail;
  final File file;
}

class QueueModel extends ChangeNotifier {
  final List<FileInfo> _queue = [];

  UnmodifiableListView<FileInfo> get queue => UnmodifiableListView(_queue);

  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  int get length => _queue.length;

  FileInfo at(int idx) {
    return _queue[idx];
  }

  void add(FileInfo item) {
    _queue.add(item);

    notifyListeners();
  }

  void removeAt(int idx) {
    _queue.removeAt(idx);

    notifyListeners();
  }

  void clear() {
    _queue.clear();
    notifyListeners();
  }

  void moveItemAt(int idxStart, int idxEnd) {
    if (idxStart < idxEnd) {
      idxEnd -= 1;
    }
    var elem = _queue.removeAt(idxStart);
    _queue.insert(idxEnd, elem);

    notifyListeners();
  }
}
