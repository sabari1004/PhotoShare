import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'file_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:android_multiple_identifier/android_multiple_identifier.dart';
import 'package:intl/intl.dart';

const APP_ID = "ca-app-pub-9235592812404140~4860822167";

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
  String clientCode;
  String serialNumber;
  String _platformVersion = 'Unknown';
  String _imei = 'Unknown';
  String _serial = 'Unknown';
  String _androidID = 'Unknown';
  String validLicense = "";
  String outputMsg = "";
  int countData;
  int countLicense;

  Map _idMap = Map();

  static final _databaseName = "upload.db";
  static final _databaseVersion = 1;

  static final table = 'DATA';
  static final licensetable = 'license';
  static final columnIp = 'ipAddress';
  static final columnRowId = 'rowId';
  static final columnPath = 'folderPath';
  static final columnName = 'userName';
  static final columnPass = 'passWord';
  static final columnKey = 'licenseKey';
  static final columnCode = 'clientCode';

  // make this a singleton class
  _HomeMaterialState._privateConstructor();
  static final _HomeMaterialState instance =
      _HomeMaterialState._privateConstructor();

  _HomeMaterialState(this.ipAddress, this.folderPath, this.userName,
      this.passWord, this.licenseKey);

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

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
            $columnRowId CHAR(10) UNIQUE,
            $columnPath CHAR(200) NOT NULL,
            $columnName CHAR(50)  NOT NULL,
            $columnPass CHAR(50)  NOT NULL,
            $columnKey CHAR(50)  NOT NULL,
            $columnCode CHAR(50)  NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $licensetable (
            fdClientID CHAR(20) PRIMARY KEY,
            fdLicenseSince DATE NOT NULL,
            fdLicValidTill DATE NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> insertLicense(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(licensetable, row);
  }

  Future<int> query() async {
    Database db = await instance.database;
    countData =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> queryData() async {
    Database db = await instance.database;
    int count;
    // get all rows
    List<Map> result = await db.rawQuery('SELECT * FROM $table');
    // print the results
    if (!result.isEmpty) {
      ipAddress = result[0]["ipAddress"];
      folderPath = result[0]["folderPath"];
      userName = result[0]["userName"];
      passWord = result[0]["passWord"];
      licenseKey = result[0]["licenseKey"];
      count = 1;
    }
    return count;
  }

  Future<int> queryLicense() async {
    Database db = await instance.database;
    countLicense = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $licensetable'));
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $licensetable'));
  }

  Future<int> queryLicenseData() async {
    Database db = await instance.database;
    // get all rows
    List<Map> result = await db.rawQuery('SELECT * FROM $licensetable');
    // print the results
    result.forEach((row) => print(row));
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $licensetable'));
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
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    String imei;
    String serial;
    String androidID;
    Map idMap;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await AndroidMultipleIdentifier.platformVersion;
    } on Exception {
      platformVersion = 'Failed to get platform version.';
    }

    bool requestResponse = await AndroidMultipleIdentifier.requestPermission();
    print("NEVER ASK AGAIN SET TO: ${AndroidMultipleIdentifier.neverAskAgain}");

    try {
      // imei = await AndroidMultipleIdentifier.imeiCode;
      // serial = await AndroidMultipleIdentifier.serialCode;
      // androidID = await AndroidMultipleIdentifier.androidID;

      idMap = await AndroidMultipleIdentifier.idMap;
    } catch (e) {
      idMap = Map();
      idMap["imei"] = 'Failed to get IMEI.';
      idMap["serial"] = 'Failed to get Serial Code.';
      idMap["androidId"] = 'Failed to get Android id.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _idMap = idMap;
      _imei = _idMap["imei"];
      _serial = _idMap["serial"];
      _androidID = _idMap["androidId"];
    });
  }

  Future<String> downloadData() async {
    //   var response =  await http.get('https://getProjectList');

    Database db = await instance.database;
    countData =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
    // get all rows
    List<Map> result = await db.rawQuery('SELECT * FROM $table');
    // print the results
    if (!result.isEmpty) {
      ipAddress = result[0]["ipAddress"];
      folderPath = result[0]["folderPath"];
      userName = result[0]["userName"];
      passWord = result[0]["passWord"];
      licenseKey = result[0]["licenseKey"];
      clientCode = result[0]["clientCode"];
    }
    return Future.value(countData.toString()); // return your response
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: downloadData(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else {
            //return Center(child: new Text('${snapshot.data}'));
            return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                title: Text('Profile'),
                actions: <Widget>[
                  // action button
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false
                      // otherwise.
                      if (_formKey.currentState.validate()) {
                        await _verifyLicense(validLicense);
                        if (outputMsg == "Success") {
                          Fluttertoast.showToast(
                              msg:
                                  "License Registration Successful \n Settings Saved",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else if (outputMsg == "QuotaReached") {
                          Fluttertoast.showToast(
                              msg:
                                  "License quota reached. Please apply for new license",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else if (outputMsg == "LicenseExpired") {
                          Fluttertoast.showToast(
                              msg:
                                  "License Expired. Please contact Administrator",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else if (outputMsg == "InvalidClientID") {
                          Fluttertoast.showToast(
                              msg:
                                  "Invalid Client ID. Please contact Administrator",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else if (outputMsg == "UserRegisteredAlready") {
                          Fluttertoast.showToast(
                              msg: "User already registered for License",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else if (outputMsg == "InactiveUser") {
                          Fluttertoast.showToast(
                              msg:
                                  "Inactive Device. Please contact Administrator",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        } else {
                          Fluttertoast.showToast(
                              msg: "License Registration Unsuccessful",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FileManager()),
                        );
                      }
                    },
                  ),
                ],
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Builder(
                    //future: queryData(),
                    builder: (context) => Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              new ListTile(
                                leading: const Icon(Icons.computer),
                                title: new TextFormField(
                                  initialValue: ipAddress,
                                  //controller: TextEditingController(text: snapshot.data),
                                  decoration:
                                      InputDecoration(labelText: 'IP Address'),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter IP address';
                                    } else {
                                      ipAddress = value;
                                    }
                                  },
                                  onSaved: (val) =>
                                      setState(() => ipAddress = val),
                                ),
                              ),
                              new ListTile(
                                leading: const Icon(Icons.folder),
                                title: new TextFormField(
                                  initialValue: folderPath,
                                  decoration:
                                      InputDecoration(labelText: 'Folder Path'),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter the path of the destinatation';
                                    } else {
                                      folderPath = value;
                                    }
                                  },
                                  onSaved: (val) =>
                                      setState(() => folderPath = val),
                                ),
                              ),
                              new ListTile(
                                leading: const Icon(Icons.person),
                                title: new TextFormField(
                                    initialValue: userName,
                                    decoration:
                                        InputDecoration(labelText: 'UserName'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter your username';
                                      } else {
                                        userName = value;
                                      }
                                    },
                                    onSaved: (val) =>
                                        setState(() => userName = val)),
                              ),
                              new ListTile(
                                leading: const Icon(Icons.remove_red_eye),
                                title: new TextFormField(
                                    initialValue: passWord,
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
                                    onSaved: (val) =>
                                        setState(() => passWord = val)),
                              ),
                              new ListTile(
                                leading: const Icon(Icons.vpn_key),
                                title: new TextFormField(
                                    //obscureText: _obscureText,
                                    initialValue: licenseKey,
                                    decoration: InputDecoration(
                                        labelText: 'License Key'),
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
                              new ListTile(
                                leading: const Icon(Icons.account_balance),
                                title: new TextFormField(
                                    //obscureText: _obscureText,
                                    initialValue: clientCode,
                                    decoration:
                                        InputDecoration(labelText: 'Client ID'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter the Client ID';
                                      } else {
                                        clientCode = value;
                                      }
                                    },
                                    onSaved: (val) =>
                                        setState(() => clientCode = val)),
                              ),
                            ]))),
              ),
              floatingActionButton:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                FloatingActionButton.extended(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      await _verifyLicense(validLicense);
                      if (outputMsg == "Success") {
                        Fluttertoast.showToast(
                            msg:
                                "License Registration Successful \n Settings Saved",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else if (outputMsg == "QuotaReached") {
                        Fluttertoast.showToast(
                            msg:
                                "License quota reached. Please apply for new license",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else if (outputMsg == "LicenseExpired") {
                        Fluttertoast.showToast(
                            msg:
                                "License Expired. Please contact Administrator",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else if (outputMsg == "InvalidClientID") {
                        Fluttertoast.showToast(
                            msg:
                                "Invalid Client ID. Please contact Administrator",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else if (outputMsg == "UserRegisteredAlready") {
                        Fluttertoast.showToast(
                            msg: "User already registered for License",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else if (outputMsg == "InactiveUser") {
                        Fluttertoast.showToast(
                            msg:
                                "Inactive Device. Please contact Administrator",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else {
                        Fluttertoast.showToast(
                            msg: "License Registration Unsuccessful",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      }
                    }
                  },
                  icon: Icon(
                    Icons.verified_user,
                  ),
                  label: Text("Validate License"),
                  heroTag: "btn1",
                ),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton.extended(
                  onPressed: () {
                    _onAlertWithCustomImagePressed(context);
                  },
                  icon: Icon(
                    Icons.info_outline,
                  ),
                  label: Text("About"),
                  tooltip: "First",
                  heroTag: "btn2",
                )
              ]),
              /*floatingActionButton: new FloatingActionButton.extended(
        onPressed: () {
          _onAlertWithCustomImagePressed(context);
        },
        icon: Icon(
          Icons.info_outline,
        ),
        label: Text("About"),
        tooltip: "First",
      ),*/
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          }
        }
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Upload Success"),
      content: Text("Photo Upload Successfully"),
      //image: Image.asset("assets/images/logo.jpg"),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Alert custom images
  _onAlertWithCustomImagePressed(context) {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 200.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(5.0),
                child: Image.asset("assets/images/logo.jpg")),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'For License, Please contact: info@schedartech.com',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                '@Copyright: Schedar Technologies',
                style: TextStyle(color: Colors.black, fontSize: 10.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'App Version = 1.3.0',
                style: TextStyle(color: Colors.black, fontSize: 10.0),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      _HomeMaterialState.columnIp: ipAddress,
      _HomeMaterialState.columnRowId: "1",
      _HomeMaterialState.columnPath: folderPath,
      _HomeMaterialState.columnName: userName,
      _HomeMaterialState.columnPass: passWord,
      _HomeMaterialState.columnKey: licenseKey,
      _HomeMaterialState.columnCode: clientCode
    };
    final id = await insert(row);
    print('inserted row id: $id');
  }

  Future<String> _verifyLicense(String validLicense) async {
    // row to insert
    String clientID;
    DateTime licenseSince;
    int licenseTotal;
    DateTime licenseTill;
    int totalUsers;
    int activeUser;
    var alreadyRegistered;
    final date2 = DateTime.now();

    try {
      var settings = new ConnectionSettings(
          host: '192.145.238.16',
          port: 3306,
          user: 'amtbug5_UserPhotoLic',
          password: "SchedarTech@1234\$",
          db: 'amtbug5_dbPhotoShareLic');
      var conn = await MySqlConnection.connect(settings);

      var results = await conn.query(
          'select * from tbClientMaster where fdClientID = "' +
              clientCode +
              '"');

      if (results != null) {
        print('Query Result: $results');

        for (var row in results) {
          clientID = row[0];
          licenseSince = row[6];
          licenseTotal = row[7];
          licenseTill = row[8];
          print(
              'Client ID : ${row[0]}, License Since : ${row[6]}, Total License: ${row[7]}, License Till: ${row[8]}');
        }

        //number of used license
        var countResults = await conn.query(
            'select count(*) from tbUserMaster where fdCllientID = "' +
                clientCode +
                '"');

        if (countResults != null) {
          for (var row in countResults) {
            totalUsers = row[0];
            print('totalUsers : ${row[0]}');
          }
          alreadyRegistered = await conn.query(
              'select * from tbUserMaster where tbMacID = "' + _imei + '"');
          if (alreadyRegistered != null) {
            for (var row in alreadyRegistered) {
              activeUser = row[6];
              print('activeUser : ${row[6]}');
            }
          }
        }

        //the license date verification
        if (licenseTill != null) {
          final difference = licenseTill.difference(date2).inDays;
          if (difference >= 0) {
            if (licenseTotal >= totalUsers &&
                activeUser != 1 &&
                activeUser != 0) {
              var insertResult = await conn.query(
                  'insert into tbUserMaster (fdUserID, fdCllientID, tbPassword, tbIP, tbLicKey, tbMacID, tbUserActiveStatus) values (?, ?, ?, ?, ?, ?, ?)',
                  [
                    userName,
                    clientCode,
                    passWord,
                    ipAddress,
                    licenseKey,
                    _imei,
                    1
                  ]);
              print("Inserted ID: ${insertResult.insertId}");

              query();
              if (countData != 0) {
              } else {
                var insertResultTxn = await conn.query(
                    'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
                    [userName, _imei, date2.toUtc(), clientCode, "Success"]);
                print("Inserted ID: ${insertResultTxn.insertId}");
                _insert();
              }
              // row to insert
              queryLicense();
              if (countLicense != null) {
              } else {
                Map<String, dynamic> row = {
                  "fdClientID": clientID,
                  "fdLicenseSince":
                      DateFormat('yyyy-MM-dd').format(licenseSince),
                  "fdLicValidTill":
                      DateFormat('yyyy-MM-dd').format(licenseTill),
                };
                final id = await insertLicense(row);
                print('inserted row id: $id');
              }
              print("License Verified Successfully");
              outputMsg = "Success";
              return 'Success';
            } else if (activeUser == 1) {
              var insertResult = await conn.query(
                  'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
                  [
                    userName,
                    _imei,
                    date2.toUtc(),
                    clientCode,
                    "UserRegisteredAlready"
                  ]);
              print("Inserted ID: ${insertResult.insertId}");
              print("User already registered");
              outputMsg = "UserRegisteredAlready";
              return "UserRegisteredAlready";
            } else if (activeUser == 0) {
              var insertResult = await conn.query(
                  'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
                  [userName, _imei, date2.toUtc(), clientCode, "InactiveUser"]);
              print("Inserted ID: ${insertResult.insertId}");
              print("Inactive User");
              outputMsg = "InactiveUser";
              return "InactiveUser";
            } else {
              var insertResult = await conn.query(
                  'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
                  [
                    userName,
                    _imei,
                    date2.toUtc(),
                    clientCode,
                    "LicenseQuotaExceeded"
                  ]);
              print("Inserted ID: ${insertResult.insertId}");
              print("License quota reached. Please apply for new license");
              outputMsg = "QuotaReached";
              return "QuotaReached";
            }
          } else {
            var insertResult = await conn.query(
                'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
                [userName, _imei, date2.toUtc(), clientCode, "LicenseExpired"]);
            print("Inserted ID: ${insertResult.insertId}");
            print("License Expired. Please contact Administrator");
            outputMsg = "LicenseExpired";
            return "LicenseExpired";
          }
        } else {
          var insertResult = await conn.query(
              'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
              [userName, _imei, date2.toUtc(), clientCode, "InvalidClientID"]);
          print("Inserted ID: ${insertResult.insertId}");
          print("License not available for the mentioned client ID");
          outputMsg = "InvalidClientID";
          return ("InvalidClientID");
        }
      } else {
        var insertResult = await conn.query(
            'insert into tbUserTrxn (fdUserID, fdMacID, fdDateTime, tbClientID, fdTrxnStatus) values (?, ?, ?, ?, ?)',
            [userName, _imei, date2.toUtc(), clientCode, "InvalidClientID"]);
        print("Inserted ID: ${insertResult.insertId}");
        print("License not available for the mentioned client ID");
        outputMsg = "InvalidClientID";
        return ("InvalidClientID");
      }
    } catch (e) {
      print(e.toString());
      return "failed";
    }
  }
}
