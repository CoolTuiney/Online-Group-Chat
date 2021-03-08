import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayUserProfile extends StatefulWidget {
  Group currentGroup;
  String currentUser;
  String userPhoto;
  String userName;
  String uid;
  DisplayUserProfile(
      {this.currentGroup,
      this.currentUser,
      this.userName,
      this.userPhoto,
      this.uid});
  @override
  _DisplayUserProfileState createState() => _DisplayUserProfileState();
}

class _DisplayUserProfileState extends State<DisplayUserProfile> {
  List userCurrentGroupList;
  List userSelectedGroupList;
  bool isdropdown = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.menuColor,
        title: Text('User Profile'),
      ),
      body: Container(
        color: UniversalVariables.backgroundColor,
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white38,
                      child: CircleAvatar(
                        radius: 59,
                        backgroundImage: NetworkImage(widget.userPhoto),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.userName,
                      style: TextStyle(
                          color: UniversalVariables.primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: UniversalVariables.secondaryTextColor,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Groups In Common',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon((isdropdown == true)
                      ? Icons.arrow_drop_down
                      : Icons.arrow_drop_up),
                  onPressed: () => fetchData(),
                  iconSize: 40,
                )
              ],
            ),
            Expanded(
                child: (isdropdown == true) ? commonGroupList() : Container()),
            (widget.currentUser == widget.currentGroup.admin &&
                    widget.uid != widget.currentGroup.admin)
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.90,
                      child: RaisedButton(
                        child: Text('Kick',
                            style: TextStyle(fontSize: 18, letterSpacing: 0.8)),
                        onPressed: () {
                          alertBox(widget.uid, context);
                        },
                        color: Colors.redAccent,
                      ),
                    ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget commonGroupList() {
    List commonGroupList = [];
    if (userSelectedGroupList != null && userCurrentGroupList != null) {
      for (var e1 in userCurrentGroupList) {
        for (var e2 in userSelectedGroupList) {
          if (e1 == e2) {
            commonGroupList.add(e1);
          }
        }
      }
    }
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null || userSelectedGroupList == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return groupListBuild(snapshot.data.docs[index], commonGroupList);
            });
      },
    );
  }

  Widget groupListBuild(DocumentSnapshot snapshot, List commonGroupList) {
    if (userSelectedGroupList.contains(snapshot['gid'])) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: UniversalVariables.bottomGradient,
          child: ListTile(
            title: Text(snapshot['name']),
            onTap: () {},
          ),
        ),
      );
    }
    return Container();
  }

  Future<void> fetchData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        userCurrentGroupList = snapshot['groups'];

        isdropdown = !isdropdown;
      });
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        userSelectedGroupList = snapshot['groups'];
      });
    });
  }

  Future<Widget> alertBox(String uid, BuildContext bc) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: UniversalVariables.bottomGradient,
            title: Text('Accept'),
            content: Text('Do you want to remove this user?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  removeUser(uid);
                  Navigator.pop(context);
                  Navigator.pop(bc);
                },
                child: Text('Yes'),
              )
            ],
          );
        });
  }

  removeUser(String userToRemove) {
    List user = userToRemove.split(":");
    List groupId = widget.currentGroup.gid.split(':');
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.currentGroup.gid)
        .update({'users': FieldValue.arrayRemove(user)});
    FirebaseFirestore.instance
        .collection('users')
        .doc(userToRemove)
        .update({'groups': FieldValue.arrayUnion(groupId)});
  }
}
