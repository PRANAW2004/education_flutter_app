import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:odoo_rpc/odoo_rpc.dart';

import './profileedit.dart';
import './home.dart';
import './settings.dart';
import '../helper.dart';

class StudentProfilePage extends StatefulWidget {

   final String email;
   final String password;
   final String domain;
   final String selectedDb;

  const StudentProfilePage({super.key, required this.email, required this.password, required this.domain, required this.selectedDb});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePage();
}

class _StudentProfilePage extends State<StudentProfilePage>{

  List<dynamic> dataArray = [];

  late PageController _pageController;
  int partner_id = 0;
  List<dynamic> partner_id1 = [];
  String sessionId = "";
  int userId = 0;
  List<Map> library_data = [];
  late FToast fToast;
  int adminUid = 0;
  int _selectedIndex = 0;

  String dbname = "";

  //to store the exam results
  List<Map<String, dynamic>> examResultData = [];
  List<dynamic> exams = [];


  MemoryImage? profileImage;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    print(widget.domain);
    _pageController = PageController(initialPage: _selectedIndex);
    fToast = FToast();
    fToast.init(context);
    studentData(true);
    
  }


  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }


  //Fetching Student Data
  Future<void> studentData(bool callFetchStudentData) async{
    print("This is student data");
    callFetchStudentData?
    Fluttertoast.showToast(
        msg: "Getting your profile info, please wait",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    ):Fluttertoast.showToast(
        msg: "Fetching your Updated Data, please wait",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    )
    ;

      final client = OdooClient(widget.domain);
      try{  

        final authResult = await client.authenticate(widget.selectedDb,widget.email,widget.password);
        final adminUid = authResult.userId;
        
        print(authResult);

        final res1 = await client.callKw({

            "model" :'res.users',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'context': {'bin_size': false},
              'domain': [['id','=',adminUid]],
              'fields': ['name','last_name','email',"phone",'date_of_birth','partner_id','image_1920'],
              'limit': 80,
            }
          });
          print(res1);

          final partnerId = res1.isNotEmpty ? res1[0]['partner_id'][0] : 0;

          setState((){
            
            dataArray = res1;
            if (dataArray.isNotEmpty && dataArray[0]['image_1920'] != false) {
                profileImage = MemoryImage(base64Decode(dataArray[0]['image_1920']));
            };
            partner_id = partnerId; 
            print("inside fetching the data");
          });
          if(partner_id != 0 && callFetchStudentData){
            fetchStudentData();
          }
          // if (ModalRoute.of(context)?.settings.name == '/profile') {
          //   print("We are on the Profile page");
          // }
                
      }on OdooException catch(e){
         showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error in fetching data from model res.users'),
                    content: Text('$e'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
        print(e);
        client.close();
      }
      }

      Future<void> fetchStudentData() async{
        
        final client = OdooClient(widget.domain);
        final authResult = await client.authenticate(widget.selectedDb,widget.email,widget.password);
        
        List<Map<String, dynamic>> examResultData1 = [];
        List<Map> libraryData1 = [];
        List<dynamic> examtimetableData1 = [];


        try{
          if(partner_id != 0){
          
          try{
          final examres = await client.callKw({
              'model': 'result.subject.line',
              'method': 'search_read',
              'args': [],
              'kwargs': {
                'context': {'bin_size': false},
                'domain': [['result_id.student_id', 'in', [partner_id]]],
                'fields': ['mark', 'pass_mark', 'mark_scored', 'exam_id', 'grade_id', 'subject_id'],
                'limit': 80,
              }
            });
            // print(examres);
           
            examResultData1 = List<Map<String,dynamic>>.from(examres);
          }on OdooException catch(e){
            print(e);
             showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error in fetching data from model result.subject.line'),
                    content: Text('$e'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the popup
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
          }

          // need to compplete
          try{
            print("Inside the exam timetable res");
            final examtimetableres = await client.callKw({
              'model': 'subject.subject.line',
              'method': 'search_read',
              'args': [],
              'kwargs': {
                'context': {'bin_size': false},
                'domain': [
                  ['exam_id.student_ids', 'in', [partner_id]],
                ],
                'fields': [
                  'subject_id', 'date', 'time_from', 'time_to', 'exam_id', 'day',
                ], 
                'limit': 80,
              }
          });
          // print(examtimetableres);
          examtimetableData1 = examtimetableres;
          Fluttertoast.showToast(
                msg: "Successfully retreived exams timetable data",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }on OdooException catch(e){
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error in fetching data from model subject.subject.line'),
                    content: Text('$e'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the popup
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            print(e);
          }
          setState((){
            examResultData = examResultData1;
            exams = examtimetableData1;
          });
        }

      }on OdooException catch(e){
          print(e);
          client.close();
        }
      }


          

  

  //Selecting Bottom navigation tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }
  bool isProfileUpdated = false;


  int _buttonNum = 0;


  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0), // Set your custom height here
        child: AppBar(
          backgroundColor: Color(0xFFA064F1),
        )
      ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            HomePage(partnerId: partner_id, examResultData: examResultData, examTimetableData: exams,sessionId: sessionId,userId: userId),
          Center(child: Text("Discover Page")),
            dataArray.length > 0?SingleChildScrollView(
          child: Container(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    Stack(children: [
   
                      Container(
                        height: 175,
                        
                        // width: screenWidth+10,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                                image: AssetImage('assets/images/svgimage.png'), // Load image from assets
                                fit: BoxFit.fill, // Choose how the image should fit
                              ),
                        ),
                        ),
                      // SizedBox(height: 20),
                      Column(children: [
                          SizedBox(height:0),
                           Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right:25.0),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
                                  child: IconButton(
                                  onPressed: () => {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage())),

                                  },icon:Icon(Icons.settings_outlined,size: 25)) 
                                )
                                ),
                                 
                                
                              ]
                            ),
                           
                            CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.purple,
                            child: CircleAvatar(
                              radius: 65,
                           
                            backgroundImage: profileImage ??
                                AssetImage('assets/images/camera.png') as ImageProvider,
                            )
                            
                          )
                      ,    
                      ] )    
                  ])    , 
                  SizedBox(height: 5),
                  Center(child: Text("Hi, "+dataArray[0]['name']+" ${dataArray[0]['last_name']}",style:TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 30))),
                  Center(child: Text("Joined Aug 2022")),
                  SizedBox(height: 22),
                  Padding(
                    padding: EdgeInsets.only(left:10.0,right:10.0),
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color:Colors.purple.shade100),
                      constraints: BoxConstraints(minHeight: 100,minWidth: 100),
                      child: Column(children: [SizedBox(height:10),Text("Quote of the day",style: TextStyle(color: Colors.purple)),SizedBox(height:20),Padding(padding: EdgeInsets.only(left:20.0,right:20.0),
                      child:Text("The time we spend awake is precious, so is the time we spend asleep",textAlign: TextAlign.center,)), SizedBox(height:10),Text("Lebron James"),SizedBox(height:10)],)

                    )
                  ),
                  SizedBox(height: 30),
                  Padding(padding: EdgeInsets.only(left:30.0,right:30.0),child:Container(
                    constraints: BoxConstraints(minHeight: 100,minWidth: 100),
                    decoration: BoxDecoration(color: Colors.purple,borderRadius: BorderRadius.circular(20)),
                    child: Column(children: [
                      SizedBox(height:20),
                      Padding(padding: EdgeInsets.only(left:20.0,right:20.0), 
                              child: Row(children: [
                                    Text("Zen Master",style:TextStyle(fontWeight: FontWeight.w900,color:Colors.white)),
                                    Spacer(),
                                    Text("200",style:TextStyle(color: Colors.yellow)),
                                    Text("/300",style:TextStyle(color:Colors.white))],),),

                      SizedBox(height:10),
                      Padding(
                        padding:EdgeInsets.only(left:10.0,right:10.0),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 7,minWidth: 300),
                        decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Container(
                            width: 200,
                            height: 7,
                            decoration: BoxDecoration(color: Colors.yellow,borderRadius: BorderRadius.circular(30)),
                          )
                        ],),
                      )),
                      SizedBox(height:10),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0,right: 30.0),
                      child: Row(children: [
                        Text("LV 4", style: TextStyle(color: Colors.white)),
                        Spacer(),
                        Text("LV 5",style: TextStyle(color: Colors.white),),
                      ],)
                      )
                    ],
                    
                    )
                  )),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 50.0,right:20.0),
                    child: Row(children: [
                    ElevatedButton(
                      onPressed: () => {setState(() => {_buttonNum = 0})}, 
                      child: Text("STATS",style: TextStyle(color: Colors.white),),
                       style: ElevatedButton.styleFrom(
                                elevation: 10, 
                                shadowColor: Colors.transparent, 
                                backgroundColor: _buttonNum == 0? Colors.purple:Colors.purple.shade100, 
                                foregroundColor: Colors.black, 
                                padding: EdgeInsets.only(right: 20.0,left: 20.0), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                              ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => {setState(() => {_buttonNum = 1})}, 
                      child: Text("HISTORY",style: TextStyle(color: Colors.white)),
                       style: ElevatedButton.styleFrom(
                                    elevation: 0, 
                                    shadowColor: Colors.transparent, 
                                    backgroundColor: _buttonNum==1?Colors.purple:Colors.purple.shade100, 
                                    foregroundColor: Colors.black, 
                                    padding: EdgeInsets.only(right: 20.0,left: 20.0), 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                                  ),
                      ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => {setState(() => {_buttonNum = 2})}, 
                      child: Text("EDIT",style: TextStyle(color: Colors.white)),
                       style: ElevatedButton.styleFrom(
                                    elevation: 0, 
                                    shadowColor: Colors.transparent, 
                                    backgroundColor: _buttonNum==2?Colors.purple:Colors.purple.shade100, 
                                    foregroundColor: Colors.black, 
                                    padding: EdgeInsets.only(right: 20.0,left: 20.0), 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                                  ),
                      ),
                       
                  ],)
                  ),
                  SizedBox(height: 20),
                  if(_buttonNum==0)Column(children: [
                    Padding(
                    padding: EdgeInsets.only(left:10.0,right:10.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.purple.shade100,borderRadius: BorderRadius.circular(10)),
                      constraints: BoxConstraints(minHeight: 150,minWidth: 100),
                      child: 
                      Padding(padding: EdgeInsets.only(left:30.0,right:27.0),
                      child: Column(children: [
                        SizedBox(height: 20),
                        Row(
                        children: [
                          
                          Column(children: [Text("23",style: TextStyle(color: Colors.purple,fontSize: 20)),
                          SizedBox(height:10),
                          Text("Completed",style: TextStyle(color: Colors.purple)),Text("Sessions",style: TextStyle(color: Colors.purple))],),
                          SizedBox(width:30),
                          Container(
                            width:1,
                            height: 70,
                            decoration: BoxDecoration(color: Colors.purple),
                          ),
                          SizedBox(width:30),
                          Column(children: [Text("94",style: TextStyle(color: Colors.purple,fontSize: 20)),
                          SizedBox(height:10),
                          Text("Minutes",style: TextStyle(color: Colors.purple)),Text("Spent",style: TextStyle(color: Colors.purple))],),
                          SizedBox(width:30),
                          Container(
                            width:1,
                            height: 70,
                            decoration: BoxDecoration(color: Colors.purple),
                          ),
                          SizedBox(width:30),
                          Column(children: [Text("15 days",style: TextStyle(color: Colors.purple,fontSize: 20)),
                          SizedBox(height:10),
                          Text("Longest",style: TextStyle(color: Colors.purple)),Text("Streak",style: TextStyle(color: Colors.purple))],),
                        ]
                      ),

                      Padding(
                        padding: EdgeInsets.only(left:70.0,right:70.0),
                        child: ElevatedButton(
                        onPressed: () => {print("I am pressed")}, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.only(right: 20.0,left: 20.0), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                          minimumSize: Size(20,40),
                        ),
                      child: Row(children: [

                              Icon(Icons.ios_share, color: Colors.white),
                              SizedBox(width:10),
                              Text("Share My Stats",style:TextStyle(color: Colors.white))
                              
                              ])
                              ))
                      ]
                      )
                      )
                    )
                    )
                    ]
                    )else if(_buttonNum==1)Column(children: [
                      Padding(
                        padding: EdgeInsets.only(left:10.0,right:10.0),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.purple.shade100,borderRadius: BorderRadius.circular(10)),
                        constraints: BoxConstraints(minHeight: 150,minWidth: 400),

                          child: Padding(
                            padding: EdgeInsets.only(left:10.0,right:17.0),
                            child: Column(children: [
                              Text("This is history section"),
                            ])
                          )
                        )
                      )
                    ],)
                    else if(_buttonNum==2)Column(children: [
                      Padding(
                        padding: EdgeInsets.only(left:10.0,right:10.0),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.purple.shade100,borderRadius: BorderRadius.circular(10)),
                      constraints: BoxConstraints(minHeight: 150,minWidth: 400),
                          child: Padding(
                            padding: EdgeInsets.only(left:30.0,right:27.0),
                            child: Column(children: [
                              
                              SizedBox(height:40),
                              ElevatedButton(
                                onPressed:  () {
    
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEdit(dataArray: dataArray))).then((_){
                                      // studentData(false);
                                      // print(_);
                                      if(_){
                                        studentData(false);
                                      }
                                    });
     
                                },
                              child: Text("Edit your details",style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ))
                      
                            ])
                          )
                        )
                      )
                    ],)
                
              
              
            ]
          )
        )
              
    ):Center(child: CircularProgressIndicator()),
    ]
    ),
        bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 0?Icons.home:Icons.home_outlined,color: Color(0xFFA064F1)),
                label: 'Home',
                
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex==1?Icons.search:Icons.search_outlined,color: Color(0xFFA064F1)),
                label: 'Discover'
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex==2?Icons.account_circle:Icons.account_circle_outlined,color: Color(0xFFA064F1)),
                label: 'You'
              )
            ],
            currentIndex: _selectedIndex,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900,color: Color(0xFFA064F1)),
            unselectedItemColor: Color(0xFFA064F1),
            // unselectedLabelStyle: TextStyle(color: Colors.green),
            onTap: _onItemTapped,
        )
        
    );
  }

}

