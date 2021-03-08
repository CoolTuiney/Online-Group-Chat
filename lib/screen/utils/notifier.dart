import 'package:flutter/foundation.dart';

class GroupInfo extends ChangeNotifier {
  String groupName='';
  String getGroupName() => groupName;

  updateGroupName(name){
    groupName = name;
    notifyListeners();
  }
}
