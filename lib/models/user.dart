class SystemUser {
  String uid;
  String name;
  String email;
  String username;
  String status;
  int state;
  String profilePhoto;
  List groups;

  SystemUser({
    this.uid,
    this.name,
    this.email,
    this.username,
    this.status,
    this.state,
    this.profilePhoto,
    this.groups,
  });

  Map toMap(SystemUser user) {
    var data = Map<String, dynamic>();
    data["uid"] = user.uid;
    data["name"] = user.name;
    data["email"] = user.email;
    data["username"] = user.username;
    data["status"] = user.status;
    data["state"] = user.state;
    data["profilePhoto"] = user.profilePhoto;
    data["groups"] = user.groups;
    return data;
  }

  SystemUser.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData["uid"];
    this.name = mapData["name"];
    this.email = mapData["email"];
    this.username = mapData["username"];
    this.status = mapData["status"];
    this.state = mapData["state"];
    this.profilePhoto = mapData["profilePhoto"];
    this.groups = mapData["groups"];
  }
}
