import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/file_manager1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'selection_icon.dart';
import 'click_effect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'HomeMaterial.dart';

class FileManager2 extends StatefulWidget {
  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager2> {
  List<FileSystemEntity> files = [];
  MethodChannel _channel = MethodChannel('openFileChannel');
  MethodChannel _uploadChannel = MethodChannel('uploadChannel');
  Directory parentDir;
  ScrollController controller = ScrollController();
  int count = 0;
  String sDCardDir;
  List<double> position = [];
  bool conn = false;
  bool _saving = false;
  bool _progressBarActive = false;
  static const platform = const MethodChannel('flutter.native/helper');
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*final HomeMaterial homeMaterial;

    // In the constructor, require a Person
  _FileManagerState({Key key, @required this.homeMaterial}) : super();*/

  @override
  void initState() {
    super.initState();
    getPermission();
    getConnectionStatus();
  }

  void _submit() {
    // dismiss keyboard during async call
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _saving = true;
    });
  }

  getConnectionStatus() {
    Connectivity connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        setState(() {
          conn = true;
        });
      } else {
        setState(() {
          conn = false;
        });
      }
    });
  }

  bool isDataAvailable = true;

  _checkWifi() async {
    _submit();
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      Fluttertoast.showToast(
          msg: "Please connect to FEWA Wifi Network",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1);
      print("Please connect to FEWA Wifi Network");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Wifi Connected");
      _uploadPhoto();
      // stop the modal progress HUD
      _progressBarActive = false;
    }
  }

  _uploadPhoto() {
    uploadFile(sDCardDir);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new FileManager2();
    }));
    Fluttertoast.showToast(
        msg: "Upload Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  Future<void> getPermission() async {
    if (Platform.isAndroid) {
      bool permission1 = await SimplePermissions.checkPermission(
          Permission.ReadExternalStorage);
      bool permission2 = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
      if (!permission1) {
        await SimplePermissions.requestPermission(
            Permission.ReadExternalStorage);
      }
      if (!permission2) {
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
      }
      getSDCardDir();
    } else if (Platform.isIOS) {
      getSDCardDir();
    }
  }

  Future<void> getSDCardDir() async {
    sDCardDir = (await getExternalStorageDirectory()).path + "/Pictures";
    parentDir = Directory(sDCardDir);
    initDirectory(sDCardDir);
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator =_progressBarActive ? new Container(
      color: Colors.grey[300],
      width: 70.0,
      height: 70.0,
      child: new Padding(padding: const EdgeInsets.all(5.0),child: new Center(child: new CircularProgressIndicator())),
    ):new Container();
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          parentDir?.path == sDCardDir
              ? 'Upload Photos'
              : parentDir.path.substring(parentDir.parent.path.length + 1),
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.4,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: parentDir?.path == sDCardDir
            ? Container()
            : IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: () {
              if (parentDir.path != sDCardDir) {
                initDirectory(parentDir.parent.path);
                jumpToPosition(false);
              } else {
                Navigator.pop(context);
              }
            }),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(choices[0].icon),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeMaterial()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xfff3f3f3),
      floatingActionButton: new FloatingActionButton.extended(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Text(
                        "\nUploading Photos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        )
                    )
                  ],
                );
                //Center(child: CircularProgressIndicator(),);
              });
          await loginAction();
          Navigator.pop(context);
          //_checkWifi();
        },
        icon: Icon(
          Icons.file_upload,
        ),
        label: Text("Upload"),
        tooltip: "First",
      ),
      body: Scrollbar(
        child: ListView.builder(
          controller: controller,
          itemCount: files.length != 0 ? files.length : 1,
          itemBuilder: (BuildContext context, int index) {
            if (files.length != 0)
              return buildListViewItem(files[index]);
            else
              return Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2 -
                        MediaQuery.of(context).padding.top -
                        56.0),
                child: Center(
                  child: Text('The folder is empty'),
                ),
              );
          },
        ),
      ),
    );
  }

  Future<bool> loginAction() async {
    //replace the below line of code with your login request
    await new Future.delayed(
      const Duration(seconds: 15),
    );
    _checkWifi();
    return true;
  }

  removePointBegin(Directory path) {
    var dir = Directory(path.path).listSync();
    int num = dir.length;

    for (int i = 0; i < dir.length; i++) {
      if (dir[i]
          .path
          .substring(dir[i].parent.path.length + 1)
          .substring(0, 1) ==
          '.') num--;
    }
    return num;
  }

  buildListViewItem(FileSystemEntity file) {
    var isFile = FileSystemEntity.isFileSync(file.path);

    if (file.path.substring(file.parent.path.length + 1).substring(0, 1) ==
        '.') {
      count++;
      if (count != files.length) {
        return Container();
      } else {
        return Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 2 -
                  MediaQuery.of(context).padding.top -
                  56.0),
          child: Center(
            child: Text('The folder is empty'),
          ),
        );
      }
    }

    int length = 0;
    if (!isFile) length = removePointBegin(file);

    return ClickEffect(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset(selectIcon(isFile, file)),
            title: Row(
              children: <Widget>[
                Expanded(
                    child:
                    Text(file.path.substring(file.parent.path.length + 1))),
                isFile
                    ? Container()
                    : Text(
                  '$length',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            subtitle: isFile
                ? Text(
              '${getFileLastModifiedTime(file)}  ${getFileSize(file)}',
              style: TextStyle(fontSize: 12.0),
            )
                : null,
            trailing: isFile ? null : Icon(Icons.chevron_right),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Divider(
              height: 1.0,
            ),
          )
        ],
      ),
      onTap: () {
        if (!isFile) {
          position.insert(position.length, controller.offset);
          initDirectory(file.path);
          jumpToPosition(true);
        } else
          openFile(file.path);
      },
    );
  }

  void _onLoading() {
    showDialog(
      child: new CircularProgressIndicator(),
    );
  }

  void jumpToPosition(bool isEnter) {
    if (isEnter)
      controller.jumpTo(0.0);
    else {
      controller.jumpTo(position[position.length - 1]);
      position.removeLast();
    }
  }

  Future<void> initDirectory(String path) async {
    try {
      setState(() {
        var directory = Directory(path);
        count = 0;
        parentDir = directory;
        files.clear();
        files = directory.listSync();
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  getFileSize(FileSystemEntity file) {
    int fileSize = File(file.resolveSymbolicLinksSync()).lengthSync();
    if (fileSize < 1024) {
      // b
      return '${fileSize.toStringAsFixed(2)}B';
    } else if (1024 <= fileSize && fileSize < 1048576) {
      // kb
      return '${(fileSize / 1024).toStringAsFixed(2)}KB';
    } else if (1048576 <= fileSize && fileSize < 1073741824) {
      // mb
      return '${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
    }
  }

  getFileLastModifiedTime(FileSystemEntity file) {
    DateTime dateTime =
    File(file.resolveSymbolicLinksSync()).lastModifiedSync();

    String time =
        '${dateTime.year}-${dateTime.month < 10 ? 0 : ''}${dateTime.month}-${dateTime.day < 10 ? 0 : ''}${dateTime.day} ${dateTime.hour < 10 ? 0 : ''}${dateTime.hour}:${dateTime.minute < 10 ? 0 : ''}${dateTime.minute}';
    return time;
  }

  openFile(String path) {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    _channel.invokeMethod('openFile', args);
  }

  uploadFile(String path) {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    _uploadChannel.invokeMethod('uploadFile', args);
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
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Car', icon: Icons.settings),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }

}
