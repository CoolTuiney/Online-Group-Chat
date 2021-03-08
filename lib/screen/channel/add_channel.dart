import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddChannel extends StatefulWidget {
  Group currentGroup;
  AddChannel({this.currentGroup});

  @override
  _AddChannelState createState() => _AddChannelState();
}

class _AddChannelState extends State<AddChannel> {
  final nameCon = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  FirebaseRepository _repository = FirebaseRepository();

  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.backgroundColor,
      appBar: AppBar(
        title: Text('Create Channel'),
        backgroundColor: UniversalVariables.menuColor,
      ),
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
                    labelText: 'Enter Channel Name',
                    hintText: 'Enter Text'),
                textAlign: TextAlign.left,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Text is Empty';
                  }
                  return null;
                },
              ),
            ),
            RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    addChannel();

                    Navigator.pop(context);
                  }
                },
                child: Text("Create")),
          ],
        ),
      ),
    );
  }

  addChannel() {
    var text = nameCon.text;
    String id = uuid.v1();
    String gid = widget.currentGroup.gid;

    Channel _channel = Channel(name: text, cid: id, groupId: gid);
    _repository.addChannelToDataBase(_channel, widget.currentGroup);
  }
}
