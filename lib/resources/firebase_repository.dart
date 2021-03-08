import 'dart:io';
import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/models/message.dart';
import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<User> signIn() => _firebaseMethods.signIn();

  Future<bool> authenticateUser(User user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addDataToDataBase(User user) =>
      _firebaseMethods.addDataToDataBase(user);

  Future<bool> signOut() => _firebaseMethods.signOut();

  Future<void> addChannelToDataBase(Channel name, Group group) =>
      _firebaseMethods.addChannelToDataBase(name, group);

  Stream<QuerySnapshot> get channels => _firebaseMethods.channels;

  Future<void> addMessageToDataBase(Message message) =>
      _firebaseMethods.addMessageToDatabase(message);

  Future<void> addGroupToDataBase(Group name,String currentUserId) =>
      _firebaseMethods.addGroupToDataBase(name,currentUserId);

  void uploadImage(
          {@required File image,
          @required String channelId,
          @required userId,
          @required ImageUploadProvider imageUploadProvider,
          @required String mid,
          @required String userPhotoUrl,
          @required String time}) =>
      _firebaseMethods.uploadImage(image, channelId, userId,
          imageUploadProvider, mid, userPhotoUrl, time);
}
