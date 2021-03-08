import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class AddGroup extends StatefulWidget {
  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final nameCon = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  FirebaseRepository _repository = FirebaseRepository();
  String currentUserId;

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
          title: Text('Join Group'),
          backgroundColor: UniversalVariables.menuColor),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: TextFormField(
                maxLength: 7,
                controller: nameCon,
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-z0-9]"))
                ],
              ),
            ),
            RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    addGroup();
                  }
                },
                child: Text("Join")),
          ],
        ),
      ),
    );
  }

  addGroup() async {
    var text = nameCon.text;
    List groupId = text.split(':');
    String currentUser = currentUserId;
    List userList = currentUser.split(':');
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('groups').doc(text).get();
      if (snapshot.exists) {
        FirebaseFirestore.instance
            .collection('groups')
            .doc(text)
            .update({'users': FieldValue.arrayUnion(userList)});
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .update({'groups': FieldValue.arrayUnion(groupId)});
        Navigator.pop(context);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => invalidGroup()));
      }
    } catch (e) {
      print(e);
    }
  }

  Widget invalidGroup() {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Group Not Found\n Invalid Group Code\n',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: UniversalVariables.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
            RaisedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
