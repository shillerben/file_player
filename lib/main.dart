import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'queue_model.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => QueueModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Player',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.cyan, brightness: Brightness.dark)),
      home: Consumer<QueueModel>(builder: (context, queue, child) {
        return MyHomePage(title: 'File Player', queue: queue);
      }),
    );
  }
}
