import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'file_manager.dart';
import 'file_manager_progress.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  var now = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Photos',
      theme: ThemeData(
//        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      home: FileManager2(),
      //home: _valid(),
      debugShowCheckedModeBanner: false,
    );
  }
}
