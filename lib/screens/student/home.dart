import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import './library.dart';
import './examresult.dart';
import '../helper.dart';
import '../login.dart';
import './examtimetable.dart';

class HomePage extends StatefulWidget{

  final int partnerId;
  final List<dynamic> examTimetableData;
  final List<Map<String,dynamic>> examResultData;
  final String sessionId;
  final int userId;

  const HomePage({super.key, required this.partnerId, required this.examResultData, required this.examTimetableData, required this.sessionId, required this.userId});

      @override
      State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage>{

  

  @override
  Widget build(BuildContext context) {

    print("session id in home page is ${widget.sessionId}");

    

    return Scaffold(
        appBar: AppBar(
          title: Text("Hello App"),
        ),
        body: Center(
          child: Column(
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LibraryPage(partnerId: widget.partnerId,sessionId: widget.sessionId,userId: widget.userId)));
                    },
                    child: Text('Library')
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Results(examResultData: widget.examResultData)));
                    },
                    child: Text('Results')
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ExamScreen(examTimetableData: widget.examTimetableData)));
                    },
                    child: Text('Exam time table')
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Helper.saveUserLoggedInSharedPreference(false);
                      Helper.saveBoolDB(false);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()),(route) => false,);
                    },
                    child: Text("Sign out"),
                  ),
                ]
                ,
          ),

        ),
      );
    
  }
}
