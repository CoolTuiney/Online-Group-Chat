import 'package:ProjectCommunicationSystem/enum/view_state.dart';
import 'package:ProjectCommunicationSystem/models/channel.dart';
import 'package:flutter/material.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState _viewState = ViewState.IDLE;
  ViewState get getViewState => _viewState;

  void setToLoading() {
    _viewState = ViewState.LOADING;
    notifyListeners();
  }

  void setToIdle() {
    _viewState = ViewState.IDLE;
    notifyListeners();
  }
}

class ChannelProvider with ChangeNotifier {
  String _displayChannelName = '';
  bool _channelRemoved=true;

  void setDisplayName(String text) {
    _displayChannelName = text;
    notifyListeners();
  }

  void setChannelRemoved(bool channel) {
    _channelRemoved = channel;
    notifyListeners();
  }

  bool get getChannelRemoved => _channelRemoved;

  String get getDisplayName => _displayChannelName;
}

class GroupProvider with ChangeNotifier {
  String _displayGroupName = '';

  void setDisplayName(String text) {
    _displayGroupName = text;
    notifyListeners();
  }

  String get getDisplayName => _displayGroupName;
}
