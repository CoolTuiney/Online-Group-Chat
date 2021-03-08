class Group {
  String name;
  String gid;
  List users;
  List channels;
  String admin;

  Group({this.name, this.users, this.channels, this.admin, this.gid});

  //group data object into a map
  Map toMap() {
    var map = Map<String, dynamic>();
    map['name'] = this.name;
    map['gid'] = this.gid;
    map['users'] = this.users;
    map['admin'] = this.admin;
    map['channels'] = this.channels;
    return map;
  }

  //returns group object from a map varaible
  Group fromMap(Map<String, dynamic> map) {
    Group _group = Group();
    _group.name = map['name'];
    _group.gid = map['gid'];
    _group.users = map['users'];
    _group.admin = map['admin'];
    _group.channels = map['channels'];
    return _group;
  }
}
