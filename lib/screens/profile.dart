import 'package:flutter/material.dart';

import 'dart:io';
import 'package:odoo_rpc/odoo_rpc.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {

  
  int _selectedIndex = 1;

  @override
  void initState(){
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final client = OdooClient("http://educationv17.odoo.com");
    try{
    await client.authenticate("neha-klientinformatics-education-main-15796936",'admin','a');
    final res = await client.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': false},
          'domain': [['student_uid','=','SI/2024/10/5']],
          'fields': [ 'name', 'last_name','street','phone','mobile','email'],
          'limit': 80,
        }});
    print('$res');
  } on OdooException catch(e){
    print(e);
    client.close();
    exit(-1);
  }
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(

      ),
        body: Container(
          // constraints: BoxConstraints(minHeight = 10.0),
        // alignment: Alignment(0,-1),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(_selectedIndex == 0)Column(
                children: [
                  Center(child: Text("This is Home page")),
                ]
              )
              else if(_selectedIndex == 1) Column(
                children: [
                  Center(child: Text("This is Discover page")),
                ]
              )else if(_selectedIndex == 2) Column(
                children: [
                  Center(child: Text("This is You page")),
                ]
              )
            ]
          )
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 0?Icons.home:Icons.home_outlined,color: Colors.purple),
                label: 'Home',
                
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex==1?Icons.search:Icons.search_outlined,color: Colors.purple),
                label: 'Discover'
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex==2?Icons.account_circle:Icons.account_circle_outlined,color: Colors.purple),
                label: 'You'
              )
            ],
            currentIndex: _selectedIndex,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900,color: Colors.purple),
            unselectedItemColor: Colors.purple,
            // unselectedLabelStyle: TextStyle(color: Colors.green),
            onTap: (int index) => {
              setState(() => {
                _selectedIndex = index,
                print("selected index is $_selectedIndex"),
              })
            }
        )
        
    );
  }

}