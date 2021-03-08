import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: UniversalVariables.backgroundColor,
    appBarTheme: AppBarTheme(
      color: UniversalVariables.menuColor,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: UniversalVariables.topGradient,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.white, fontSize: 20),
      subtitle2: TextStyle(color: Colors.white70, fontSize: 18),
    ),
  );
}
