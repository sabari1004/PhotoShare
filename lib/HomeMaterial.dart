import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'file_manager.dart';

class HomeMaterial extends StatefulWidget {
  @override
  _HomeMaterialState createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  final _formKey = GlobalKey<FormState>();
  final _user = User();
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeMaterial()),
                );*/
                Fluttertoast.showToast(
                    msg: "Settings Saved",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileManager()),
                );
              },
            ),
          ],
        ),
        body: Container(
            /*padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),*/
            child: Builder(
                builder: (context) => Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          new ListTile(
                            leading: const Icon(Icons.computer),
                            title: new TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'IP Address'),
                                //controller: myController,
                              initialValue: _user.ipAddress,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter IP address';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => _user.ipAddress = val),
                            ),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.folder),
                            title: new TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Folder Path'),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter the path where photos to be copied';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => _user.folderPath = val),
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
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => _user.userName = val)),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.remove_red_eye),
                            title: new TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Password'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => _user.passWord = val)),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.vpn_key),
                            title: new TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'License Key'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter the license key';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => _user.licenseKey = val)),
                          ),
                        ])))));
  }

  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Submitting form')));
  }
}

class User {
  String ipAddress = '';
  String folderPath = '';
  String firstName = '';
  String userName = '';
  String passWord = '';
  String licenseKey = '';

  save() {
    print('saving user using a web service');
  }
}
