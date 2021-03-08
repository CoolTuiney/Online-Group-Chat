import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:flutter/material.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:ProjectCommunicationSystem/screen/home_screen.dart';
import 'package:provider/provider.dart';

class GroupSetting extends StatefulWidget {
  Group currentGroup;
  GroupSetting({this.currentGroup});

  @override
  _GroupSettingState createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSetting> {
  final nameCon = TextEditingController();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  GroupProvider _groupProvider;
  HomeScreen homeScreen = HomeScreen();
  @override
  Widget build(BuildContext context) {
    _groupProvider = Provider.of<GroupProvider>(context);
    return Scaffold(
        backgroundColor: UniversalVariables.backgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Group Setting',
          ),
        ),
        body: Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: TextFormField(
                        controller: nameCon,
                        textCapitalization: TextCapitalization.sentences,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Rename Group',
                        ),
                        textAlign: TextAlign.left,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'TextField can\'t be Empty';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          renameGroup();
                          _groupProvider.setDisplayName(nameCon.text);
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Rename")),
                  Divider(
                    color: Colors.white30,
                    height: 20,
                    thickness: 5,
                  ),
                  Text(
                    'Group invitation Code:',
                    style: TextStyle(
                        fontSize: 20,
                        color: UniversalVariables.primaryTextColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        Text(
                          widget.currentGroup.gid,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: UniversalVariables.primaryTextColor),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '(tap to copy code)',
                          style: TextStyle(
                              color: UniversalVariables.secondaryTextColor),
                        )
                      ],
                    ),
                    onTap: () {
                      Clipboard.setData(
                          new ClipboardData(text: widget.currentGroup.gid));
                      _displaySnackBar(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: RaisedButton(
                        color: Colors.redAccent,
                        onPressed: () {
                          alertBox();
                        },
                        child: Text("Delete Group")),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<Widget> alertBox() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: UniversalVariables.bottomGradient,
            title: Text('Accept'),
            content: Text('Do you want to Delete current Group?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  _groupProvider.setDisplayName('');
                  deleteChannel();
                  deleteGroup();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Yes'),
              )
            ],
          );
        });
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black87,
        content: Text('Text copied', style: TextStyle(color: Colors.white)));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  renameGroup() {
    var name = nameCon.text;

    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.currentGroup.gid)
        .update({'name': name});
  }

  Future deleteChannel() async {
    List channelList;
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.currentGroup.gid)
        .get()
        .then((val) {
      if (val['channels'] != null) {
        channelList = val['channels'];
        print(channelList);
        for (var i = 0; i < channelList.length; i++) {
          FirebaseFirestore.instance
              .collection('channels')
              .doc(channelList[i])
              .delete();
        }
      } else {
        return print('channel is null');
      }
    });
  }

  deleteGroup() {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.currentGroup.gid)
        .delete();
  }
}
