import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/users/user_profile.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserListView extends StatefulWidget {
  Group currentGroup;
  Channel currentChannel;
  bool isUserAdd;
  bool isUserRemove;
  GlobalKey<ScaffoldState> scaffoldKey;
  BuildContext context;
  UserListView(
      {this.currentGroup,
      this.scaffoldKey,
      this.context,
      this.currentChannel,
      this.isUserRemove,
      this.isUserAdd});

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  List usersInGroup;
  FirebaseRepository _repository = FirebaseRepository();
  String currentUser = '';

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      currentUser = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          for (var i = 0; i < snapshot.data.docs.length; i++) {
            var doc = snapshot.data.docs[i];
            if (doc['gid'] == widget.currentGroup.gid) {
              usersInGroup = doc['users'];
            }
          }
          return usersList(usersInGroup);
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
      return ListTile(
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
        subtitle: (widget.currentGroup.admin == uid)
            ? Text(
                'Admin',
                style: TextStyle(color: UniversalVariables.secondaryTextColor),
              )
            : Container(),
        onTap: () {
          if (widget.isUserAdd) {
            addUserToChannel(uid);
            displaySnackBar(widget.context, name);
          } else if (widget.isUserRemove) {
            Navigator.push(
                widget.context,
                MaterialPageRoute(
                    builder: (context) => DisplayUserProfile(
                          uid: uid,
                          userPhoto: snapshot['profilePhoto'],
                          userName: name,
                          currentGroup: widget.currentGroup,
                          currentUser: currentUser,
                        )));
          }
        },
      );
    } else {
      return Container();
    }
  }

  displaySnackBar(BuildContext context, String name) {
    final snackBar = SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black87,
        content: Text('Access Granted To $name',
            style: TextStyle(color: Colors.white)));
    widget.scaffoldKey.currentState.showSnackBar(snackBar);
  }

  addUserToChannel(String uId) {
    List userId = uId.split(':');
    FirebaseFirestore.instance
        .collection('channels')
        .doc(widget.currentChannel.cid)
        .update({'users': FieldValue.arrayUnion(userId)});
  }
}
