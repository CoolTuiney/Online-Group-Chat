import 'dart:io';

import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/models/message.dart';
import 'package:ProjectCommunicationSystem/models/user.dart';
import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/screen/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference channelReference =
      FirebaseFirestore.instance.collection('channels');

  Reference _firebaseStorage;

  //SystemUser class
  SystemUser user = SystemUser();
  Channel channel = Channel();
  Group group = Group();

  Future<User> getCurrentUser() async {
    User currentUser;
    // ignore: await_only_futures
    currentUser = await _auth.currentUser;
    return currentUser;
  }

  Future<User> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();

    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);

    UserCredential result = await _auth.signInWithCredential(credential);
    User user = result.user;

    return user;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await firestore
        .collection("user")
        .where("email", isEqualTo: user.email) //condition
        .get();
    final List<DocumentSnapshot> docs = result.docs;

    //if user is registered then length of list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDataBase(User currentUser) async {
    String username = Utilities.getUsername(currentUser.email);

    user = SystemUser(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoURL,
      username: username,
      groups: [],
    );

    firestore.collection("users").doc(currentUser.uid).set(user.toMap(user));
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addChannelToDataBase(Channel channel, Group group) async {
    var map = channel.toMap();
    List channelId = channel.cid.split(':');
    FirebaseFirestore.instance
        .collection('groups')
        .doc(group.gid)
        .update({'channels': FieldValue.arrayUnion(channelId)});
    return await firestore.collection('channels').doc(channel.cid).set(map);
  }

  Stream<QuerySnapshot> get channels {
    return channelReference.snapshots();
  }

  Future<void> addMessageToDatabase(Message message) async {
    var map = message.toMap();
    return await firestore
        .collection('messages')
        .doc(message.channelId)
        .collection('msg')
        .add(map);
  }

  Future<void> addGroupToDataBase(Group gname, String currentUserId) async {
    var map = gname.toMap();
    List groupId = gname.gid.split(":");
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({'groups': FieldValue.arrayUnion(groupId)});
    return await firestore.collection('groups').doc(gname.gid).set(map);
  }

  Future<String> uploadImageToStorage(File image) async {
    try {
      _firebaseStorage = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      UploadTask _uploadTask = _firebaseStorage.putFile(image);
      final TaskSnapshot downloadUrl = (await _uploadTask);
      final String url = await downloadUrl.ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setImageMsg(String url, String channelId, String userId, String mid,
      String userPhotoUrl, String time) async {
    Message _message;
    _message = Message.imageMessage(
        message: "IMAGE",
        channelId: channelId,
        userName: userId,
        photourl: url,
        timestamp: FieldValue.serverTimestamp(),
        type: 'image',
        time: time,
        userPhotoUrl: userPhotoUrl,
        mid: mid);
    var map = _message.toImageMap();
    await firestore
        .collection('messages')
        .doc(_message.channelId)
        .collection('msg')
        .add(map);
  }

  void uploadImage(
      File image,
      String channelId,
      String userId,
      ImageUploadProvider imageUploadProvider,
      String mid,
      String userPhotoUrl,
      String time) async {
    imageUploadProvider.setToLoading();
    String url = await uploadImageToStorage(image);
    imageUploadProvider.setToIdle();
    setImageMsg(url, channelId, userId, mid, userPhotoUrl, time);
  }
}
