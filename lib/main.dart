import 'package:ProjectCommunicationSystem/provider/image_upload_provider.dart';
import 'package:ProjectCommunicationSystem/resources/firebase_repository.dart';
import 'package:ProjectCommunicationSystem/screen/home_screen.dart';
import 'package:ProjectCommunicationSystem/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseRepository _repository = FirebaseRepository();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageUploadProvider>(
          create: (context) => ImageUploadProvider(),
        ),
        ChangeNotifierProvider<ChannelProvider>(
          create: (context) => ChannelProvider(),
        ),
        ChangeNotifierProvider<GroupProvider>(
          create: (context) => GroupProvider(),
        )
      ],
      child: MaterialApp(
          title: "PCS",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
          ),
          home: FutureBuilder(
            builder: (context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
            future: _repository.getCurrentUser(),
          )),
    );
  }
}
