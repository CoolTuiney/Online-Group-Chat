import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/screen/users/users_list.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChannelSetting extends StatefulWidget {
  Channel currentChannel;
  Group currentGroup;
  ChannelSetting({this.currentChannel, this.currentGroup});

  @override
  _ChannelSettingState createState() => _ChannelSettingState();
}

class _ChannelSettingState extends State<ChannelSetting> {
  final nameCon = new TextEditingController();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  ChannelProvider _channelProvider;

  List usersInChannel;
  bool isdata = false;

  @override
  Widget build(BuildContext context) {
    _channelProvider = Provider.of<ChannelProvider>(context);
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: UniversalVariables.backgroundColor,
        appBar: AppBar(
          title: Text('Channels'),
          backgroundColor: UniversalVariables.menuColor,
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: TextFormField(
                        controller: nameCon,
                        textCapitalization: TextCapitalization.sentences,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Rename Channel',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                renameChannel();
                                _channelProvider.setDisplayName(nameCon.text);
                                Navigator.pop(context);
                              }
                            },
                            child: Text("Rename")),
                        RaisedButton(
                            color: Colors.redAccent,
                            onPressed: () {
                              alertBox();
                            },
                            child: Text("Delete Channel")),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white30,
                height: 20,
                thickness: 5,
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Add Users who can access this Channel',
                            style: TextStyle(
                                fontSize: 20,
                                color: UniversalVariables.primaryTextColor,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.white70,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UsersList(
                                            currentGroup: widget.currentGroup,
                                            currentChannel:
                                                widget.currentChannel,
                                          )));
                            })
                      ],
                    ),
                    userList(),
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<Widget> alertBox() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: UniversalVariables.bottomGradient,
            title: Text('Accept'),
            content: Text('Do you want to delete current channel?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  _channelProvider.setDisplayName('');
                  _channelProvider.setChannelRemoved(true);
                  deleteChannel();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Yes'),
              )
            ],
          );
        });
  }

  deleteChannel() {
    FirebaseFirestore.instance
        .collection('channels')
        .doc(widget.currentChannel.cid)
        .delete();
    // FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(widget.currentChannel.cid)
    //     .delete();
  }

  renameChannel() {
    var name = nameCon.text;

    FirebaseFirestore.instance
        .collection('channels')
        .doc(widget.currentChannel.cid)
        .update({'name': name});
  }

  Widget userList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('channels').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          for (var i = 0; i < snapshot.data.docs.length; i++) {
            var doc = snapshot.data.docs[i];
            if (doc['cid'] == widget.currentChannel.cid) {
              usersInChannel = doc['users'];
            }
          }
          return usersList(usersInChannel);
        });
  }

  Widget usersList(List users) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return userItems(snapshot.data.docs[index], users);
            });
      },
    );
  }

  Widget userItems(DocumentSnapshot snapshot, List users) {
    String uid = snapshot['uid'];
    String name = snapshot['name'];
    if (users == null) {
      return Container();
    } else if (users.contains(uid)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          leading: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(snapshot['profilePhoto']),
              ),
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
                fontSize: 18, color: UniversalVariables.primaryTextColor),
          ),
          subtitle: Text('(tap to deny access)',
              style: TextStyle(color: UniversalVariables.secondaryTextColor)),
          onTap: () {
            removeUser(uid);
            displaySnackBar(context, name);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  removeUser(String user) {
    List removeUser = [];
    removeUser.add(user);
    FirebaseFirestore.instance
        .collection('channels')
        .doc(widget.currentChannel.cid)
        .update({'users': FieldValue.arrayRemove(removeUser)});
  }

  displaySnackBar(BuildContext context, String name) {
    final snackBar = SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black87,
        content: Text('Access Denied To $name',
            style: TextStyle(color: Colors.white)));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
