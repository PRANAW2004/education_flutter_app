import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import './parentprofile.dart';
import './parentdiscoverpage.dart';
import '../helper.dart';
import '../login.dart';

class ParentHomePage extends StatefulWidget{

  final String email;
   final String password;
   final String domain;
   final String selectedDb;

   const ParentHomePage({super.key, required this.email, required this.password, required this.domain, required this.selectedDb});
  
  @override
  State<ParentHomePage> createState() => _ParentHomePage(); 
}

class _ParentHomePage extends State<ParentHomePage>{

  int _selectedIndex = 0;

  late PageController _pageController;

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    parentData();
  }

   @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  Future<void> parentData() async{    
    print('${widget.email},${widget.password}');
      final client = OdooClient(widget.domain);
      try{  

        final authResult = await client.authenticate(widget.selectedDb,widget.email,widget.password);
        final adminUid = authResult.userId;
        print(adminUid);
        print(authResult);
         final userData = await client.callKw({
            "model": 'res.users',
            'method': 'read',
            'args': [adminUid],
            'kwargs': {
              'fields': ['partner_id','name','student_ids'],
            }
          });

          print(userData);

          //student_ids
       
        final studentDetails = await client.callKw({
            "model" :'res.partner',
            'method': 'read',
            'args': [userData[0]['partner_id'][0]],
            'kwargs': {
              // 'context': {'bin_size': false},
              // 'domain': [['id','=',userData[0]['partner_id'][0]]],
              'fields': ['name','standard'],
              // 'limit': 80,
            }
          });
        print(studentDetails);

          
      }on OdooException catch(e){
        
        print(e);
        client.close();
      }
      }








  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  
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
            Column(
              children: [
                Center(child: Text("This is the home page")),
                ElevatedButton(
                    onPressed: (){
                      Helper.saveUserLoggedInSharedPreference(false);
                      Helper.saveBoolDB(false);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()),(route) => false,);
                    },
                    child: Text("Sign out"),
                  ),
              ]
            ),
            ParentDiscoverPage(),
            ParentProfilePage(),
          ],  
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

//date