import 'package:flutter/material.dart';
import 'file_manager_progress.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Photos',
      theme: ThemeData(
//        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      home: FileManager2(),
      debugShowCheckedModeBanner: false,
    );
  }
}
