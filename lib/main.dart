import 'dart:async';

import 'package:flutter/material.dart';

import './screens/login.dart';
import './screens/student/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './screens/helper.dart';
import './screens/parent/parenthomepage.dart';
import 'screens/student/home.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      home: MyApp(),
  //  theme: ThemeData(primarySwatch: Colors.green),
 ));;
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
 State<MyApp> createState() => _myAppState();
}

class _myAppState extends State<MyApp> {
  bool? userIsLoggedIn;

  String? email;
  String? password;
  String? domain;
  String? dbname;
  String? userDesignation;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

 getLoggedInState() async {
   final value = await Helper.getUserLoggedInSharedPreference();
   final email1 = await Helper.getUserEmailId();
   final password1 = await Helper.getUserPassword();
   final domain1 = await Helper.getDomain();
   final dbname1 = await Helper.getDB();
   final userDesignation1 = await Helper.getUser();
   print('$userDesignation1');
    print("Value of helper is $value");
     setState(() {
       userIsLoggedIn = value;
       email = email1;
       password = password1;
       domain = domain1;
       dbname = dbname1;
       userDesignation = userDesignation1;
     }
     );
 }

 @override
 void initState() {
   super.initState();
 
   getLoggedInState().then((_) {
   Timer(
     Duration(seconds: 3),
     () => Navigator.pushReplacement(
       context,
       MaterialPageRoute(
           builder: (context) => userIsLoggedIn != null
               ? userIsLoggedIn!
                   ? userDesignation == "student"?
                   StudentProfilePage(email: email ?? "",password: password ?? "",domain: domain ?? '',selectedDb: dbname ?? ''):
                    ParentHomePage(email: email ?? "",password: password ?? "",domain: domain ?? '',selectedDb: dbname ?? '')
                  //  ? ProfilePage(email: 'admin',password: 'a',domain:  'https://educationv17.odoo.com')
                   : LoginPage()
               : LoginPage()),
     ),
   );
   });
 }
 
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
//       debugShowCheckedModeBanner: false,

     title: "Education Project",
     debugShowCheckedModeBanner: false,
     home: Scaffold(
         body: Center(
       child: CircularProgressIndicator(),
     )),
   );
 }

}


