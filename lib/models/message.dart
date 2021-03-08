import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String channelId;
  String userName;
  String userPhotoUrl;
  String type;
  String message;
  String mid;
  String time;
  FieldValue timestamp;
  String photourl;

  Message(
      {this.channelId,
      this.userPhotoUrl,
      this.userName,
      this.type,
      this.time,
      this.message,
      this.timestamp,
      this.mid});

  //will be only called when you want to send an image
  Message.imageMessage(
      {this.channelId,
      this.userName,
      this.userPhotoUrl,
      this.type,
      this.time,
      this.message,
      this.timestamp,
      this.photourl,
      this.mid});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['channelId'] = this.channelId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['mid'] = this.mid;
    map['userName'] = this.userName;
    map['time'] = this.time;
    map['userPhotoUrl'] = this.userPhotoUrl;

    return map;
  }

  Message formMap(Map<String, dynamic> map) {
    Message _message = Message();
    _message.channelId = map['channelId'];
    _message.type = map['type'];
    _message.message = map['message'];
    _message.timestamp = map['timestamp'];
    _message.mid = map['mid'];
    _message.userName = map['userName'];
    _message.time = map['time'];
    _message.userPhotoUrl = map['userPhotoUrl'];
    return _message;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['channelId'] = this.channelId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['mid'] = this.mid;
    map['userName'] = this.userName;
    map['time'] = this.time;
    map['userPhotoUrl'] = this.userPhotoUrl;
    map['photourl'] = this.photourl;

    return map;
  }
}
