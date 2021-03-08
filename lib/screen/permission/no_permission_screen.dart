import 'package:flutter/material.dart';

class ChatScreenDisable extends StatelessWidget {
  String text;
  ChatScreenDisable({this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Align(
            alignment: Alignment.center,
            child: Text(
        text,
        style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white70,),textAlign: TextAlign.center,
      ),
          )),
    );
  }
}
