import 'package:flutter/material.dart';

import 'file_manager.dart';

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
      home: FileManager(),
      debugShowCheckedModeBanner: false,
    );
  }
}
