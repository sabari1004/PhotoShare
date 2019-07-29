import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'file_manager.dart';

class HomeMaterial extends StatefulWidget {
  String ipAddress = '';
  String folderPath = '';
  String userName = '';
  String passWord = '';
  String licenseKey = '';
  @override
  _HomeMaterialState createState() => _HomeMaterialState(ipAddress, folderPath, userName, passWord, licenseKey);
}

class _HomeMaterialState extends State<HomeMaterial> {
  final _formKey = GlobalKey<FormState>();
  String ipAddress = '';
  String folderPath = '';
  String userName = '';
  String passWord = '';
  String licenseKey = '';

  _HomeMaterialState(this.ipAddress,this.folderPath,this.userName,this.passWord,this.licenseKey);

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  // Initially password is obscure
  bool _obscureText = true;

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
                    fontSize: 16.0
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileManager()),
                );
              }
              },
            ),
          ],
        ),
        body: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter IP address';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => ipAddress = val),
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
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => folderPath = val),
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
                                    setState(() => userName = val)),
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
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => passWord = val)),
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
                                  }else if(value!="Abcdef@123&"){
                                    return 'Invalid license key';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => licenseKey = val)
                            ),

                          ),
                        ])))));
  }

}
