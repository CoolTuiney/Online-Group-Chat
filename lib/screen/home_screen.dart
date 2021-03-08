import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:ProjectCommunicationSystem/models/group.dart';
import 'package:ProjectCommunicationSystem/models/user.dart';
import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/channel/add_channel.dart';
import 'package:ProjectCommunicationSystem/screen/group/group_setting.dart';
import 'package:ProjectCommunicationSystem/screen/chat/chat_screen.dart';
import 'package:ProjectCommunicationSystem/screen/group/add_group.dart';
import 'package:ProjectCommunicationSystem/screen/group/create_group.dart';
import 'package:ProjectCommunicationSystem/screen/login_screen.dart';
import 'package:ProjectCommunicationSystem/screen/permission/no_permission_screen.dart';
import 'package:ProjectCommunicationSystem/screen/users/users_list_view.dart';
import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'channel/channelSetting.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Channel channel = Channel();

  Group group = Group();
  SystemUser systemUser = SystemUser();
  FirebaseRepository _repository = FirebaseRepository();
  ChannelProvider _channelProvider;
  GroupProvider _groupProvider;

  String currentChatChannelName = '';
  String currentChatChannelId = '';
  String currentGroupName = '';
  String currentGroupId = '';
  String currentUser = '';
  String currentUserName = '';
  String currentUserPhoto = '';
  String admin = '';

  bool isSelected = false;
  int selectedIndex;

  List usersInChannel = [];

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      currentUser = user.uid;
      setState(() {
        currentUserName = user.displayName;
        currentUserPhoto = user.photoURL;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _channelProvider = Provider.of<ChannelProvider>(context);
    _groupProvider = Provider.of<GroupProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.menuColor,
        elevation: 0,
        title: Text(_channelProvider.getDisplayName),
        actions: [
          (admin == currentUser && currentChatChannelId.isNotEmpty)
              ? IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChannelSetting(
                                  currentChannel: channel,
                                  currentGroup: group,
                                )));
                  },
                )
              : Container(),
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          })
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              color: UniversalVariables.backgroundColor,
              child: DrawerHeader(
                child: Column(
                  children: [
                    Text(
                      "You",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white38,
                          child: CircleAvatar(
                              radius: 29,
                              backgroundImage: NetworkImage(currentUserPhoto)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            currentUserName,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                        IconButton(
                            tooltip: 'Logout',
                            icon: Icon(Icons.logout),
                            onPressed: () => alertBox())
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: UniversalVariables.menuColor,
                    border: Border.all(width: 0)),
              ),
            ),
            Container(
              color: UniversalVariables.backgroundColor,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Members:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: UniversalVariables.primaryTextColor)),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: UniversalVariables.backgroundColor,
                child: (currentGroupId.isEmpty)
                    ? Container()
                    : UserListView(
                        context: context,
                        isUserAdd: false,
                        currentGroup: group,
                        isUserRemove: true,
                      ),
              ),
            ),
            (currentGroupId.isNotEmpty)
                ? Expanded(
                    flex: 0,
                    child: Container(
                      color: UniversalVariables.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.60,
                            child: RaisedButton(
                              color: Colors.redAccent,
                              child: Text('Leave Group',
                                  style: TextStyle(
                                      fontSize: 18, letterSpacing: 0.8)),
                              onPressed: () {
                                alertBoxForLeaveGroup(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              color: UniversalVariables.backgroundColor,
              height: MediaQuery.of(context).size.height * 0.13,
              child: DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (_groupProvider.getDisplayName.isEmpty)
                        ? GestureDetector(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Create Group',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                            onTap: () => groupContolBottomSheet(),
                          )
                        : Row(
                            children: [
                              Text(
                                _groupProvider.getDisplayName,
                                style: TextStyle(fontSize: 20),
                              ),
                              groupSettingControl()
                            ],
                          ),
                    IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          groupContolBottomSheet();
                        })
                  ],
                ),
                decoration: BoxDecoration(color: UniversalVariables.menuColor),
              ),
            ),
            Expanded(
              child: Container(
                color: UniversalVariables.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: ListTile(
                          tileColor: UniversalVariables.bottomGradient,
                          leading: Text(
                            'Select/View Groups',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: UniversalVariables.primaryTextColor),
                          ),
                          onTap: () => groupListView(),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Channels',
                              style: TextStyle(
                                  color: UniversalVariables.primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            (admin == currentUser)
                                ? IconButton(
                                    tooltip: 'create channel',
                                    color: UniversalVariables.primaryTextColor,
                                    alignment: Alignment.topRight,
                                    icon: Icon(
                                      Icons.add,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AddChannel(
                                                  currentGroup: group)));
                                    },
                                  )
                                : Container(),
                          ]),
                      channelList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: pageControl(),
      backgroundColor: UniversalVariables.backgroundColor,
    );
  }

  Future<Widget> alertBoxForLeaveGroup(BuildContext bc) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: UniversalVariables.bottomGradient,
            title: Text('Accept'),
            content: Text('Do you want to leave current group?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  leaveGroup();
                  _groupProvider.setDisplayName('');
                  _channelProvider.setDisplayName('');
                  setState(() {
                    currentGroupId = '';
                    channel = Channel();
                  });
                  Navigator.pop(context);
                  Navigator.pop(bc);
                },
                child: Text('Yes'),
              )
            ],
          );
        });
  }

  Future<Widget> alertBox() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: UniversalVariables.bottomGradient,
            title: Text('Accept'),
            content: Text('Do you want to logout?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  signOut();
                },
                child: Text('Yes'),
              )
            ],
          );
        });
  }

  void groupContolBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        child: ListTile(
                          tileColor: UniversalVariables.bottomGradient,
                          leading: Text(
                            "Create Group",
                            style: TextStyle(
                                fontSize: 20,
                                color: UniversalVariables.primaryTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateGroup()));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        child: ListTile(
                          tileColor: UniversalVariables.bottomGradient,
                          leading: Text(
                            "Join Group",
                            style: TextStyle(
                                fontSize: 20,
                                color: UniversalVariables.primaryTextColor,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddGroup()));
                          },
                        ),
                      ),
                    )
                  ],
                )),
          );
        });
  }

  Widget channelList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('channels').snapshots(),
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
              return channelItems(snapshot.data.docs[index], index);
            });
      },
    );
  }

  Widget channelItems(DocumentSnapshot snapshot, int index) {
    String name = snapshot['name'];
    String channelid = snapshot['cid'];

    if (currentGroupId == snapshot['groupId']) {
      return ListTileTheme(
        selectedTileColor: UniversalVariables.bottomGradient,
        child: ListTile(
          selected: selectedIndex == index ? true : false,
          title: Text('#  $name',
              style: TextStyle(
                  fontSize: 17,
                  color: UniversalVariables.secondaryTextColor,
                  letterSpacing: 0.3)),
          onTap: () {
            _channelProvider.setDisplayName(name);
            _channelProvider.setChannelRemoved(false);
            setState(
              () {
                selectedIndex = index;
                currentChatChannelName = name;
                currentChatChannelId = channelid;
                channel = Channel(cid: channelid, name: name);
                Navigator.pop(context);
              },
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget usersList() {
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
              return userItems(snapshot.data.docs[index]);
            });
      },
    );
  }

  Widget userItems(DocumentSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(snapshot['profilePhoto']),
            ),
          ),
        ),
        title: Text(
          snapshot['name'],
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
    );
  }

  Widget groupList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
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
              return groupListBuild(snapshot.data.docs[index]);
            });
      },
    );
  }

  Widget groupListBuild(DocumentSnapshot snapshot) {
    String name = snapshot['name'];
    String groupId = snapshot['gid'];
    String groupAdmin = snapshot['admin'];
    List users = snapshot['users'];
    List channels = snapshot['channels'];

    if (users.isEmpty) {
      return Container();
    } else {
      for (var i = 0; i < users.length; i++) {
        if (users[i] == currentUser) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: UniversalVariables.bottomGradient,
              child: ListTile(
                title: Text(snapshot['name']),
                onTap: () {
                  _groupProvider.setDisplayName(name);
                  _channelProvider.setChannelRemoved(true);
                  _channelProvider.setDisplayName('');
                  setState(() {
                    currentGroupName = name;
                    currentGroupId = groupId;
                    admin = groupAdmin;

                    group = Group(
                        gid: groupId,
                        name: name,
                        channels: channels,
                        admin: groupAdmin);
                    Navigator.pop(context);
                  });
                },
              ),
            ),
          );
        }
      }
    }

    return Container();
  }

  void groupListView() {
    showModalBottomSheet(
        backgroundColor: UniversalVariables.backgroundColor,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.50,
            child:
                Padding(padding: const EdgeInsets.all(8.0), child: groupList()),
          );
        });
  }

  pageControl() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('channels').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          for (var i = 0; i < snapshot.data.docs.length; i++) {
            var doc = snapshot.data.docs[i];
            if (channel.cid == null ||
                _channelProvider.getChannelRemoved == true) {
              return ChatScreenDisable(
                text: 'Select a Group/Channel to enter into chat room',
              );
            } else if (doc['cid'] == channel.cid) {
              usersInChannel = doc['users'];
            }
          }
          return userCheck(usersInChannel);
        });
  }

  userCheck(List users) {
    if (users == null) {
      return ChatScreen(currentChannel: channel);
    } else if (users.isEmpty) {
      return ChatScreen(currentChannel: channel);
    } else if (users.contains(currentUser)) {
      return ChatScreen(currentChannel: channel);
    }
    return ChatScreenDisable(
      text: 'You Dont Have A Permission To This Channel',
    );
  }

  signOut() async {
    final bool isLoggedOut = await _repository.signOut();

    if (isLoggedOut) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }

  groupSettingControl() {
    return (currentUser == admin)
        ? IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupSetting(
                            currentGroup: group,
                          )));
            },
          )
        : Container();
  }

  leaveGroup() {
    List user = currentUser.split(":");
    List groupId = group.gid.split(':');
    FirebaseFirestore.instance
        .collection('groups')
        .doc(group.gid)
        .update({'users': FieldValue.arrayRemove(user)});
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .update({'groups': FieldValue.arrayRemove(groupId)});
  }
}
