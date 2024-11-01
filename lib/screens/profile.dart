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

  int _buttonNum = 0;

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
              )else if(_selectedIndex == 2) Center(
                child: Column(
                  children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://st2.depositphotos.com/1337688/5718/i/450/depositphotos_57188137-stock-photo-smiling-young-boy-in-a.jpg')
                  ),
                  SizedBox(height: 20),
                  Text("Hi, Precious",style:TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 30)),
                  Text("Joined Aug 2022"),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left:10.0,right:10.0),
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color:Colors.purple.shade100),
                      constraints: BoxConstraints(minHeight: 100,minWidth: 100),
                      child: Column(children: [SizedBox(height:10),Text("Quote of the day",style: TextStyle(color: Colors.purple)),SizedBox(height:20),Padding(padding: EdgeInsets.only(left:20.0,right:20.0),
                      child:Text("The time we spend awake is precious, so is the time we spend asleep",textAlign: TextAlign.center,)), SizedBox(height:10),Text("Lebron James"),SizedBox(height:10)],)

                    )
                  ),
                  SizedBox(height: 40),
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
                  if(_buttonNum==0)Column(children: [Padding(
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
                    )])else if(_buttonNum==1)Column(children: [],)else if(_buttonNum==2)Column(children: [],)
                ]
              )
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