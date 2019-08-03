import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'file_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeMaterial extends StatefulWidget {
  String ipAddress = '';
  String folderPath = '';
  String userName = '';
  String passWord = '';
  String licenseKey = '';
  @override
  _HomeMaterialState createState() =>
      _HomeMaterialState(ipAddress, folderPath, userName, passWord, licenseKey);
}

class _HomeMaterialState extends State<HomeMaterial> {
  final _formKey = GlobalKey<FormState>();
  String ipAddress;
  String folderPath;
  String userName;
  String passWord;
  String licenseKey;

  static final _databaseName = "upload.db";
  static final _databaseVersion = 1;

  static final table = 'DATA';
  static final columnIp = 'ipAddress';
  static final columnPath = 'folderPath';
  static final columnName = 'userName';
  static final columnPass = 'passWord';
  static final columnKey = 'licenseKey';

  // make this a singleton class
  _HomeMaterialState._privateConstructor();
  static final _HomeMaterialState instance =
      _HomeMaterialState._privateConstructor();

  _HomeMaterialState(this.ipAddress, this.folderPath, this.userName,
      this.passWord, this.licenseKey);

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  // Initially password is obscure
  bool _obscureText = true;

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnIp CHAR(20) PRIMARY KEY,
            $columnPath CHAR(200) NOT NULL,
            $columnName CHAR(50)  NOT NULL,
            $columnPass CHAR(50)  NOT NULL,
            $columnKey CHAR(50)  NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> query() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnIp];
    return await db.update(table, row, where: '$columnIp = ?', whereArgs: [id]);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Profile'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.
                if (_formKey.currentState.validate()) {
                  Fluttertoast.showToast(
                      msg: "Settings Saved",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FileManager()),
                  );
                  _insert();
                }
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
              builder: (context) => Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        new ListTile(
                          leading: const Icon(Icons.computer),
                          title: new TextFormField(
                            //initialValue: ,
                            decoration:
                                InputDecoration(labelText: 'IP Address'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter IP address';
                              } else {
                                ipAddress = value;
                              }
                            },
                            onSaved: (val) => setState(() => ipAddress = val),
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.folder),
                          title: new TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Folder Path'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter the path of the destinatation';
                              } else {
                                folderPath = value;
                              }
                            },
                            onSaved: (val) => setState(() => folderPath = val),
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.person),
                          title: new TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'UserName'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your username';
                                } else {
                                  userName = value;
                                }
                              },
                              onSaved: (val) => setState(() => userName = val)),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.remove_red_eye),
                          title: new TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              //obscureText: _obscureText,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password';
                                } else {
                                  passWord = value;
                                }
                              },
                              onSaved: (val) => setState(() => passWord = val)),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.vpn_key),
                          title: new TextFormField(
                              //obscureText: _obscureText,
                              decoration:
                                  InputDecoration(labelText: 'License Key'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter the license key';
                                } else if (value != "Abcdef@123&") {
                                  return 'Invalid license key';
                                } else {
                                  licenseKey = value;
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => licenseKey = val)),
                        ),
                      ]))),
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment(1, 1),
              image:
                  AssetImage("assets/images/logo.jpg"), // <-- BACKGROUND IMAGE
            ),
          ),
        ));
  }

  // Button onPressed methods

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      _HomeMaterialState.columnIp: ipAddress,
      _HomeMaterialState.columnPath: folderPath,
      _HomeMaterialState.columnName: userName,
      _HomeMaterialState.columnPass: passWord,
      _HomeMaterialState.columnKey: licenseKey
    };
    final id = await insert(row);
    print('inserted row id: $id');
  }
}
