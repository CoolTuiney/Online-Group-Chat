import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/screen/users/users_list_view.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UsersList extends StatefulWidget {
  Group currentGroup;
  Channel currentChannel;
  UsersList({this.currentGroup, this.currentChannel});
  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: UniversalVariables.backgroundColor,
      appBar: AppBar(
        title: Text('Users List'),
        backgroundColor: UniversalVariables.menuColor,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
        children: [
          Text('(Tap on the user to grant access)'),
          UserListView(
            currentGroup: widget.currentGroup,
            currentChannel: widget.currentChannel,
            isUserAdd: true,
            isUserRemove: false,
            scaffoldKey: _scaffoldKey,
            context: context,
          ),
        ],
      )),
    ));
  }
  
  
}
