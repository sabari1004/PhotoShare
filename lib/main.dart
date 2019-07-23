import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'file_manager.dart';

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
      home: FileManager(),
      //home: _valid(),
      debugShowCheckedModeBanner: false,
    );
  }
}
