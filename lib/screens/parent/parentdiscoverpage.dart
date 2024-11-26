import 'package:flutter/material.dart';

class ParentDiscoverPage extends StatefulWidget{
  
  @override
  State<ParentDiscoverPage> createState() => _ParentDiscoverPage(); 
}

class _ParentDiscoverPage extends State<ParentDiscoverPage>{
  
  @override
  Widget build(BuildContext context){
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
              child: Text("Hello this is parent discover page"),
            )
          ]
        )
      )

    );
  }
}