import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../helper.dart';
import 'package:http/http.dart' as http;
import 'dart:math';


class LibraryPage extends StatefulWidget{
  final int partnerId;
  final String sessionId;
  final int userId;

   const LibraryPage({super.key, required this.partnerId, required this.sessionId, required this.userId});

      @override
      State<LibraryPage> createState() => _LibraryPage();
}

class _LibraryPage extends State<LibraryPage>{

  static List<dynamic> librarydata = [];

  @override
  void initState(){
    print(librarydata.length);
    initializeDateFormatting().then((_) async{
        String? locale1 = await Helper.getLocale();
        print("initializing the dob controller now");
        locale = locale1!;
    });

    libraryData();
  }

  String locale = "";
  Random random = Random();

  final List<Color> cardColors = [
    const Color(0xFFFFCCCC), 
    const Color(0xFFFFE0B2),  
    const Color(0xFFCCFFCC), 
    const Color(0xFFE0CCFF),  
    const Color(0xFFCCE5FF),  
    const Color(0xFFFFFFCC),  
    const Color(0xFFE6CCFF), 
    const Color(0xFFCCFFE6),
  ];

  Future<void> libraryData() async{

    print(widget.sessionId);

    int? partnerId = await Helper.getpartnerId();
    int? userId = await Helper.getUserId();
    String? dbname = await Helper.getDB();
    String? password = await Helper.getUserPassword();
    String? domain = await Helper.getDomain();

    print('$partnerId,$userId');

  
      try{

        final libraryData1 = await http.post(
          Uri.parse(domain!+"/jsonrpc"),
          headers: {
            'Content-Type': 'application/json',
          },
          
          body: jsonEncode({
             "jsonrpc": "2.0",
              "method": "call",
              "params": {
                  "service": "object",
                  "method": "execute",
                  "args": [
                      dbname,
                      userId,
                      password,
                      "library.issue.books",
                      "search_read",
                      [["student_id", "=", partnerId]]
                      
                  ],
                  "kwargs": {
                "fields": ["datetime_issue"]  
              }
              }
          }),
        );

        final libraryData = jsonDecode(libraryData1.body)['result'];
        print("library data is ${libraryData[0]['issue_books_image']}");

        List<dynamic> librarydata1 = [];

        
        setState((){

          bool updatevalue = false;


              for(var i=0;i<((librarydata.length>libraryData.length)?librarydata.length:libraryData.length);i++){
                print("in for loop1");
            for(var j=0;j<((librarydata.length>libraryData.length)?libraryData.length:librarydata.length);j++){
              print("in for loop2");
              if(libraryData[(librarydata.length>libraryData.length)?j:i]['issue_books_code'] == librarydata[(librarydata.length>libraryData.length)?i:j]['issue_id']){
                print("inside the value true");
                updatevalue = true;
                break;
              }else{
                print("inside the value false");
                updatevalue=false;
              }
            }
            if(librarydata.length>libraryData.length){
              if(updatevalue==false){
                librarydata.removeAt(i);
              }
            }else{
            if(updatevalue==false){
              librarydata.add({
                    'title': libraryData[i]['display_name'].split(' by ')[0].replaceAll('"', '').trim(),
                    'author': libraryData[i]['display_name'].split(' by ')[1].trim(),
                    'issue_id': libraryData[i]['issue_books_code'],
                    'issue_date': (DateFormat.yMd(locale).format(DateTime.parse(libraryData[i]['datetime_issue'].split(' ')[0]))).replaceAll('/', '-').replaceAll(".",'-'),
                    'due_date': (DateFormat.yMd(locale).format(DateTime.parse(libraryData[i]['date_return'].split(' ')[0]))).replaceAll('/', '-').replaceAll(".",'-'),
                    'image': DecorationImage(image: MemoryImage(base64Decode(libraryData[i]['issue_books_image']))),
                    'color': cardColors[0 + random.nextInt(cardColors.length)],
                  });
            }
            }
            
          }
        });
        print(librarydata);
      

      } on OdooException catch(e){
        print("error in library page is $e");
      }

  }

  @override
  Widget build(BuildContext context){

    final screenHeight = MediaQuery.of(context).size.height;   
    final screenWidth = MediaQuery.of(context).size.width; 

    return Scaffold(
      appBar:AppBar(
        title: Text('Library'),
      ),
      body:RefreshIndicator(
      onRefresh: () async {
        await libraryData();
        setState((){});
      },
      child: ListView(

        // child: Center(
          children: [librarydata.length > 0? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left:10.0,right:10.0),
                child: Container(
                  height: 150,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Color(0xFFA064F1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left:15.0),
                    child: Row(children: [
                      Container(
                      
                        width: screenWidth*0.6,
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text(
                                "Show me a family of readers, and I will show you the people who move the world",
                                style: TextStyle(color: Colors.white),
                                ),
                                Text("-Napolean Bonaparte",style: TextStyle(color:Colors.white)),
                          ]
                        ),
                      ),
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: 1, // Ensures square aspect ratio for the image
                          child: Image.asset(
                            "assets/images/globe.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                     
                    
                      ],)
                  ),
                )
              ),
              SizedBox(height: 40),
             Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left:30.0),
                      child: Text("Books Issued",style: TextStyle(fontSize: 25)),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left:30.0,right: 30.0),
                      child: Column(children: [
                      for(var i=0;i<librarydata.length;i++)
                        
                        _bookContainer(
                          context,
                          color: librarydata[i]['color'],
                          title: librarydata[i]['title'],
                          author: librarydata[i]['author'],
                          issue_id: librarydata[i]['issue_id'],
                          issue_date: librarydata[i]['issue_date'],
                          due_date: librarydata[i]['due_date'],
                          image: librarydata[i]['image']
                          ),
                          
                      ],)
                    ),
                  ],
                ),
           
              
          ]
          ,
          ):SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(child: CircularProgressIndicator()),
        ),],
          // )
      )
    
    ));
  }

  Widget _bookContainer( BuildContext context, {Color? color,String? title, String? author, String? issue_id, String? issue_date, String? due_date, DecorationImage? image}){
    final screenHeight = MediaQuery.of(context).size.height;   
    final screenWidth = MediaQuery.of(context).size.width; 
      return Column(
        children: [Container(
        height: 150,
        // width: 330,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Padding(
            padding: EdgeInsets.only(left:10.0,right:5.0)

          ,child:
          Flexible(child: AspectRatio(aspectRatio:0.6,child: Container(
            // width: screenWidth*0.3,

            decoration: BoxDecoration(
              image: image
          )
          )
          ), 
          )
          

          )
          ,
          Expanded(
          
          child: Padding(
            padding: EdgeInsets.only(left:10.0),
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:10),
                Text(title ?? ''),
                SizedBox(height:5),
                Text("Author: ${author}"),
                SizedBox(height:5),
                Text("Issue ID: ${issue_id}" ),
                SizedBox(height:5),
                Text("Issue Date: $issue_date"),
                SizedBox(height:5),
                Container(
                  color: Color(0xFFC84C4E),
                  child: Text("Due Date: $due_date",style: TextStyle(color:Colors.white)),
                ),
                SizedBox(height:10),
              ],
            )
          // ),
          )
          
        ),
          
        ],)        
        ),
        SizedBox(height:20)]
      );
  }

}