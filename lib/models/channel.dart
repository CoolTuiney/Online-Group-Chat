class Channel {
  String name;
  String cid;
  String groupId;
  List users;

  Channel({this.name,this.users,this.groupId, this.cid});

  //channel data object into a map
  Map toMap() {
    var map = Map<String, dynamic>();
    map['name'] = this.name;
    map['cid'] = this.cid;
    map['groupId'] = this.groupId;
    map['users'] = this.users;
    return map;
  }

  //returns channel object from a map varaible
  Channel fromMap(Map<String, dynamic> map) {
    Channel _channel = Channel();
    _channel.name = map['name'];
    _channel.cid = map['cid'];
    _channel.users = map['users'];
    _channel.groupId = map['groupId'];
    return _channel;
  }
}
