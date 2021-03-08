import 'dart:io';

import 'package:ProjectCommunicationSystem/enum/view_state.dart';
import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/message.dart';
import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/chat/widgets/cached_image.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:ProjectCommunicationSystem/screen/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  Channel currentChannel;
  ChatScreen({this.currentChannel});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final FirebaseRepository _repository = FirebaseRepository();
var uuid = Uuid();

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController _listScrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  ImageUploadProvider _imageUploadProvider;

  bool isWriting = false;
  bool showEmojiPicker = false;

  String _currentUserName;
  String _currentUserPhotoUrl;

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      _currentUserName = user.displayName;
      _currentUserPhotoUrl = user.photoURL;
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();
  hideKeyboard() => textFieldFocus.unfocus();
  hideEmojiController() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiController() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Column(
      children: <Widget>[
        Flexible(
          child: messageList(),
        ),
        _imageUploadProvider.getViewState == ViewState.LOADING
            ? Container(
                margin: EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator())
            : Container(),
        chatControls(),
        showEmojiPicker ? Container(child: emojiContainer()) : Container(),
      ],
    );
  }

  pickImage({@required ImageSource source}) async {
    File selectedImage = await Utilities.pickImage(source: source);
    String mid = uuid.v1();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.jm().add_E().format(now);

    _repository.uploadImage(
        image: selectedImage,
        channelId: widget.currentChannel.cid,
        userId: _currentUserName,
        imageUploadProvider: _imageUploadProvider,
        mid: mid,
        userPhotoUrl: _currentUserPhotoUrl,
        time: formattedDate);
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Colors.black38,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });
        textEditingController.text = textEditingController.text + emoji.emoji;
      },
    );
  }

  Widget messageList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.currentChannel.cid)
            .collection('msg')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }
          // SchedulerBinding.instance.addPostFrameCallback((_) {
          //   _listScrollController.animateTo(
          //       _listScrollController.position.minScrollExtent,
          //       duration: Duration(milliseconds: 250),
          //       curve: Curves.easeInOutSine);
          // });
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              reverse: true,
              controller: _listScrollController,
              itemBuilder: (context, index) {
                return messageLayout(snapshot.data.docs[index]);
              });
        });
  }

  Widget messageLayout(DocumentSnapshot snapshot) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: ListTile(
        leading: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(snapshot['userPhotoUrl']),
            ),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              snapshot['userName'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Text(
              snapshot['time'],
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
        subtitle: snapshot['type'] != 'image'
            ? Text(snapshot['message'])
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CachedImage(
                  url: snapshot['photourl'],
                  name: snapshot['userName'],
                  time: snapshot['time'],
                ),
              ),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    return Container(
      padding: EdgeInsets.all(13),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              pickImage(source: ImageSource.camera);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: Icon(Icons.camera_alt),
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              pickImage(source: ImageSource.gallery);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: Icon(Icons.image_outlined),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Stack(alignment: Alignment.centerRight, children: [
              TextField(
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                focusNode: textFieldFocus,
                onTap: () => hideEmojiController(),
                style: TextStyle(color: Colors.white),
                onChanged: (val) {
                  (val.length > 0 && val.trim() != "")
                      ? setWritingTo(true)
                      : setWritingTo(false);
                },
                decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: UniversalVariables.greyColor),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.bottomGradient),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(Icons.face),
                onPressed: () {
                  if (!showEmojiPicker) {
                    hideKeyboard();
                    showEmojiController();
                  } else {
                    showKeyboard();
                    hideEmojiController();
                  }
                },
              ),
            ]),
          ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 20,
                      ),
                      onPressed: () => sendMessage()),
                )
              : Container(),
        ],
      ),
    );
  }

  sendMessage() {
    var text = textEditingController.text;
    String channelid = widget.currentChannel.cid;
    String mid = uuid.v1();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.jm().add_E().format(now);

    Message _message = Message(
        type: 'text',
        message: text,
        timestamp: FieldValue.serverTimestamp(),
        channelId: channelid,
        time: formattedDate,
        userName: _currentUserName,
        userPhotoUrl: _currentUserPhotoUrl,
        mid: mid);
    setState(() {
      isWriting = false;
    });
    textEditingController.text = '';
    _repository.addMessageToDataBase(_message);
  }
}
