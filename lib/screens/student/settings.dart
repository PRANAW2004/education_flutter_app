import 'package:education_project/screens/login.dart';
import 'package:flutter/material.dart';
import '../helper.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hello App"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => {
              Helper.saveUserLoggedInSharedPreference(false),
              Helper.saveBoolDB(false),
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()),(route) => false,),
            },
            child: Text("SIGN OUT")
          ),
        ),
      );
  }
}
