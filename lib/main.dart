import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_app_usage/datahandler/appdata.dart';
import 'package:real_app_usage/screens/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_app_usage/themes.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

var firestoreInstance = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      builder: (context, provider){
      return MaterialApp(
        themeMode: Provider.of<AppData>(context).themeMode,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: MyHomePage(),
      );}
    );
  }
}

