import 'package:file_player/queue_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.queue});

  final QueueModel queue;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
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
            child:
                ListTile(title: Text(queue.at(idx).file.uri.pathSegments.last)),
          );
        }
        return const ListTile();
      },
    );
  }
}
