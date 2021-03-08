import 'package:flutter/material.dart';

class UniversalVariables {
  static final Color blueColor = Color(0xff2b9ed4);
  static final Color blackColor = Color(0xff19191b);
  static final Color greyColor = Color(0xff8f8f8f);
  static final Color gradientColorStart = Color(0xff00b6f3);
  static final Color gradientColorEnd = Color(0xff0184dc);
  static final Color backgroundColor = Color(0xff121212);
  static final Color menuColor = Color(0xff181818);
  static final Color bottomGradient = Color(0xff282828);
  static final Color topGradient = Color(0xff404040);
  static final Color primaryTextColor = Color(0xffffffff);
  static final Color secondaryTextColor = Color(0xffb3b3b3);
  static final Color senderColor = Color(0xff2b343b);
  static final Color purpleColor = Color(0xffbb86fc);
  static final Color tealColor = Color(0xff03dac5);
  

  static final Gradient fabGradient = LinearGradient(
      colors: [gradientColorStart, gradientColorEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);
}
