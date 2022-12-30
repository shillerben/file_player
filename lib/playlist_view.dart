import 'package:file_player/queue_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.queue, this.startIdx = 0});

  final QueueModel queue;
  final int startIdx;

  @override
  Widget build(BuildContext context) {
    /// Need to add the startIdx to onReorder call
    void Function(int, int) genMoveFunc() {
      return ((p0, p1) => queue.moveItemAt(startIdx + p0, startIdx + p1));
    }

    return ReorderableListView.builder(
      itemCount: queue.length - startIdx,
      onReorder: genMoveFunc(),
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
                    queue.removeAt(startIdx + idx);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                )
              ],
            ),
            child: ListTile(
                title:
                    Text(queue.at(startIdx + idx).file.uri.pathSegments.last)),
          );
        }
        return const ListTile();
      },
    );
  }
}
