import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final nameCon = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  FirebaseRepository _repository = FirebaseRepository();
  String currentUserId;

  var uid = Uuid();

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      currentUserId = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.backgroundColor,
      appBar: AppBar(
          title: Text('Create Group'),
          backgroundColor: UniversalVariables.menuColor),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: TextFormField(
                controller: nameCon,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Group Name',
                    hintText: 'Enter Text'),
                textAlign: TextAlign.left,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'TextField can\'t be Empty';
                  }
                  return null;
                },
              ),
            ),
            RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    addGroup();

                    Navigator.pop(context);
                  }
                },
                child: Text("Create")),
          ],
        ),
      ),
    );
  }

  addGroup() {
    var text = nameCon.text;
    String id = uid.v1().substring(0, 7);
    String currentUser = currentUserId;

    Group _group =
        Group(name: text, gid: id, users: [currentUser], admin: currentUserId);
    _repository.addGroupToDataBase(_group,currentUserId);
  }
}
