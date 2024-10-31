import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:odoo_rpc/odoo_rpc.dart';
import './screens/profile.dart';

// main() async{
//   final client = OdooClient("http://educationv17.odoo.com");
//   try{
//     await client.authenticate("neha-klientinformatics-education-main-15796936",'admin','a');
//     final res = await client.callRPC('/web/session/modules','call',{});
//     print('$res');
//   } on OdooException catch(e){
//     print(e);
//     client.close();
//     exit(-1);
//   }
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}


