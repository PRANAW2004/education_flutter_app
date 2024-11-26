import 'package:flutter/material.dart';

class ParentProfilePage extends StatefulWidget{
  
  @override
  State<ParentProfilePage> createState() => _ParentProfilePage(); 
}

class _ParentProfilePage extends State<ParentProfilePage>{

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
  
  @override
  Widget build(BuildContext context){

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0), // Set your custom height here
        child: AppBar(
          backgroundColor: Color(0xFFA064F1),
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                radius: 70,
                backgroundColor: Color(0xFFA064F1),
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage: AssetImage('assets/images/camera.png') as ImageProvider,
                )
              ),
              SizedBox(height: 20),
              Text("Hello Gunadeep",style: TextStyle(color: Color(0xFFA064F1),fontSize: 30,fontWeight: FontWeight.w500)),
              SizedBox(height:20),
              _profileDetail(
                context,
                label: 'Name',
                content: 'GunaDeep',
                icon: Icons.badge 
                ),
              SizedBox(height: 20),
              _profileDetail(
              context,
              label: 'Mobile Number',
              content: '+919897379865',
              icon: Icons.contact_page_sharp 
              ),
              SizedBox(height: 20),
              _profileDetail(
              context,
              label: 'email',
              content: 'mm@odoo.com',
              icon: Icons.email 
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 20.0,right:20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text("Children", style: TextStyle(color: Color(0xFFA064F1),fontSize: 15))])),
              for(var i=0;i<3;i++)
              Padding(
                padding: EdgeInsets.only(left: 20.0,right: 20.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height:20),
                  
                  Container(
                    width: screenWidth,
                    height:80,
                    decoration: BoxDecoration(color: cardColors[i%cardColors.length],borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.only(left:10.0,right:10.0),
                      child: Center(child: Row(children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/images/camera.png'),
                      ),
                      SizedBox(width:15),
                      Text("Pranaw",style: TextStyle(color: Colors.black,fontSize: 20)),
                      Spacer(),
                      ElevatedButton(
                        onPressed: (){
                          print("I am pressed");
                        },
                        child: Text("View", style: TextStyle(color: Colors.green))
                      ),

                    ],)
                    )),
                  ),
                  SizedBox(height:5),
              ],)
              ),
              

              ]
              ),
            )
          ]
        )
      )

    );
  }

  Widget _profileDetail(BuildContext context,{String? label, String? content, IconData? icon}){
    return Padding(
                padding: EdgeInsets.only(left:20.0,right:20.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("$label",style: TextStyle(color: Color(0xFFA064F1), fontSize: 15)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    height:60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Expanded(child: Text("$content")),
                      Icon(icon, color: Color(0xFFA064F1))
                    ],)
                  ),
                  
                ]
              )
              );
  }
}