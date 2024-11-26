
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './student/profile.dart';
import './helper.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_country_utility/flutter_country_utility.dart';


import './parent/parenthomepage.dart';


class LoginPage extends StatefulWidget {
      const LoginPage({super.key});

      @override
      State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {


  bool passwordBool1 = false;

  late FToast fToast;


  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  List<dynamic> dataArray = [];

  String email = "";
  String password = "";
  String domain = "";
  String locale = "";

  String sessionId = '';

  List<dynamic> dbList = [];

  Future<void> dbData() async{
    try{

        String normalizedDomain = domain.startsWith("http") ? domain : "https://$domain";
        normalizedDomain = normalizedDomain.endsWith('/') ? normalizedDomain.substring(0, normalizedDomain.length - 1) : normalizedDomain;
        final url = Uri.parse('$normalizedDomain/web/database/list');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({}),
          );
       
        final response1 = jsonDecode(response.body);
        final dbarray = response1['result'];
        setState((){
          dbList = dbarray;
        });
        showDatabaseSelectionDialog();

    }on OdooException catch(e){
      print(e);
    }
  }

  void showDatabaseSelectionDialog() {
     SystemChannels.navigation.setMethodCallHandler((call) async {
        if (call.method == "popRoute") {
          SystemNavigator.pop();
        }
        return Future.value(null);
      });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
          title: Text("Select a Database"),
          content: dbList.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(left:10.0,right:10.0),
                child:  Container(
                  width: 300,
                  height: 200,
                  child: SingleChildScrollView(child: Column(
                    children: [
                      for(var i=0;i<dbList.length;i++)Column(children: [
                        ElevatedButton(
                          onPressed: (){
                            Helper.saveDB(dbList[i]);
                            Helper.saveBoolDB(true);
                            authenticate(dbList[i]);
                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();

                          },
                          child: Text(dbList[i]),
                        ),
                        SizedBox(height: 20),
                      ],)
                    ]
                  )
                  )
                )
                
              )
              : Center(child: CircularProgressIndicator()),
        )
    );
      },
    );
  }

  Future<bool> authenticate(dbname) async {

    Fluttertoast.showToast(
          msg: "Authenticating your details, please wait",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );

     String normalizedDomain = domain.startsWith("http") ? domain : "https://$domain";

    normalizedDomain = normalizedDomain.endsWith('/') ? normalizedDomain.substring(0, normalizedDomain.length - 1) : normalizedDomain;

    final url = Uri.parse('$normalizedDomain/web/session/authenticate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {
          'db': dbname,
          'login': email,
          'password': password,
        }
      }),
    );
    print(jsonDecode(response.body));

    final responseData = jsonDecode(response.body)['result'];
    final adminUid = responseData["user_id"][0];


    final client = OdooClient(normalizedDomain);

    final authResult = await client.authenticate(dbname,email,password);
    final userDesignation = await client.callKw({
            "model" :'res.partner',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'context': {'bin_size': false},
              'domain': [['id','=',responseData['partner_id']]],
              'fields': ['is_student','is_parent'],
              'limit': 80,
            }
          });
          print(userDesignation);

          print(userDesignation[0]['is_student']);
          print(userDesignation[0]['is_parent']);


    if (response.statusCode == 200) {

      final responseError = json.decode(response.body);
      if (responseError.containsKey("error")) {
        Fluttertoast.showToast(
          msg: "Check your email and password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return false;
      } else {
        Fluttertoast.showToast(
          msg: "Login Successfull",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );
      try{
        final country1 = await client.callKw({
            "model" :'res.country',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'context': {'bin_size': false},
              'domain': [['id','=',adminUid]],
              'fields': ['name'],
              'limit': 80,
            }
          });
          for(final country in Countries.values){
          if(country1[0]['name'] == country.isoShortName){
            print("${country.languagesSpoken[0]}-${country.alpha2}");
            setState((){
                locale = "${country.languagesSpoken[0]}-${country.alpha2}";
                
            });
          }
    }
      } on OdooException catch(e){
        locale = 'en-US';
        print(e);
      }

      

        Helper.saveUserEmailId(email);
        Helper.saveUserPassword(password);
        Helper.saveDomain(normalizedDomain);
        Helper.saveUserId(adminUid);
        Helper.savepartnerId(responseData['partner_id']);
        Helper.saveUserLoggedInSharedPreference(true);
        Helper.saveLocale(locale);
        if(userDesignation[0]['is_student']){
          Helper.saveUser("student");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => StudentProfilePage(email: email,password: password,domain: normalizedDomain,selectedDb: dbname)),(route) => false);
        } else if(userDesignation[0]['is_parent']){
          Helper.saveUser("parent");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ParentHomePage(email: email,password: password,domain: normalizedDomain,selectedDb: dbname)), (route) => false);
        }
        return true;
      }
  }
    else {
      return false;
    }
  }

    final TextEditingController emailEditController = TextEditingController(text: "");
    final TextEditingController passwordEditController = TextEditingController(text: "");
    final TextEditingController domainEditController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context){
    final screenHeight = MediaQuery.of(context).size.height;   
    final screenWidth = MediaQuery.of(context).size.width;    
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Color(0xFFA064F1),
          )
        ),
        body: Container(
            height: screenHeight,
            child: SingleChildScrollView(
            
              child: Column(
             children: [
              Container(
                // height: 400,
                // color: Colors.green,
                width: screenWidth,
                // color: Colors.grey,
                child:SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      
                         Image.asset(
                            height: 200,
                            width: screenWidth,
                              "assets/images/cimage.png",
                              fit: BoxFit.cover,
                            ), 
              
                      
                               
             ])
                )
                
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
              // child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left:30,right:30),
                      child: Text("Login",style: TextStyle(color: Color(0xFFA064F1),fontSize: 30,fontWeight: FontWeight.bold)),
                         
                      ),
                      SizedBox(height: 30),
                      _loginWidget(
                    context,
                    label: "domain",
                    controller: domainEditController,
                    icon: Icons.domain,
                    passwordBool: false,
                    name: 'domain',
                  ),
                  SizedBox(height: 40,),
                  _loginWidget(
                    context,
                    label: "email",
                    controller: emailEditController,
                    icon: Icons.email,
                    passwordBool: false,
                    name: 'email',
                  ),
                  SizedBox(height: 40,),
                  _loginWidget(
                    context,
                    label: "password",
                    controller: passwordEditController,
                    icon: passwordBool1?Icons.lock_open:Icons.lock,
                    passwordBool: passwordBool1?false:true,
                    name: 'password',
                  ),
                  SizedBox(height: 20),
                 
                  Stack(
                    children: [
                      
                    
                       Image.asset(
                      height: 200,
                      width: screenWidth,
                      'assets/images/cimage2.png',
                      fit: BoxFit.cover,
                      )
                    
                   
                     ,
                    Padding(
                      padding: EdgeInsets.only(top:100,right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            if(email.isEmpty || password.isEmpty || domain.isEmpty){
                              Fluttertoast.showToast(
                                  msg: "Please enter valid details",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }else{
                              dbData();
                            }
                          },
                          child: Text("Login"),
                        ),
                      ]
                    ),
                    ),
                    
                    ]
                  ),
                  
                
                ],)
              // )
            )
             ]
            
        )
            )
        
        )
       
      );
  }

  Widget _loginWidget(BuildContext context, {String? label, TextEditingController? controller,IconData? icon,bool? passwordBool,String? name}){
    final screenWidth = MediaQuery.of(context).size.width;    
    return Padding(
      padding: EdgeInsets.only(left: 30.0,right:30.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [   
        Text(
            label ?? '',
            style: TextStyle(
              color: Color(0xFFA064F1),
              fontSize: 16,
            ),
          ),
      Container(
        width: screenWidth,
        // color: Colors.grey,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10)
        

        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                  onChanged: (e) => {
                    // print(label),
                    if(label == 'email'){
                      email = e.trim(),
                    }else if(label =='password'){
                      password = e,
                    }else if(label == 'domain'){
                      domain = e.trim(),
                    }
                  },
                  controller: controller,
                  obscureText: passwordBool!,
                  decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                  style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                ),
            ),

            name == 'password'?IconButton(
              padding: EdgeInsets.zero,
              icon:Icon(icon,color:Color(0XFFA064F1)),
               onPressed: () { 
                  print("I am pressed");
                  setState(() => {
                    passwordBool1 = !passwordBool1,
                  });
                },
              constraints: BoxConstraints(maxWidth: 3.0),
               ):Icon(icon,color:Color(0XFFA064F1)),
 
          ],
        )
        )
        ]),
      
    );
  }
}