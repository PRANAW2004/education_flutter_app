// import 'dart:ffi';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui'; 
import 'dart:convert';
import 'dart:io';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';


class ProfileEdit extends StatefulWidget {

   final List< dynamic> dataArray;

  const ProfileEdit({super.key, required this.dataArray}) ;
  

  @override
  State<ProfileEdit> createState() => _ProfileEdit();

}

class _ProfileEdit extends State<ProfileEdit> {

  
  late FToast fToast;

  static MemoryImage? profileImage;
  String locale = "";
  String countryCode = "";
  int nationalNumberLengths = 0;

 
  @override
    void initState() {
    super.initState();
    
    print("inside the profile edit page, ${widget.dataArray[0]['country']}");
    fToast = FToast();
    fToast.init(context);
    initializeDateFormatting().then((_) async{
         print("initializing the dob controller now");

        String? locale1 = await Helper.getLocale();
        setState((){
        locale = locale1!;
          if (widget.dataArray.isNotEmpty && widget.dataArray[0]['image_1920'] != false) {
                profileImage = MemoryImage(base64Decode(widget.dataArray[0]['image_1920']));
      };
          dobController = TextEditingController(text: widget.dataArray[0]['date_of_birth'] is String?(DateFormat.yMd(locale).format(DateTime.parse(widget.dataArray[0]['date_of_birth']))).replaceAll('/', '-').replaceAll(".",'-'):"");
        });

    });
    
    _initializeControllers();
  }

  bool _editBool = true;

  String _updateEmail = "";
  String _updateName = "";
  String _updateLastName = "";
  String _updatePhone = "";
  String _updateDOB = "";
  
  bool _isUpdatedBool = false;

  bool _isSendBackUpdate = false;

  bool _imageUploadBool1 = false;
  static bool _imageUploadBool = false;

  String countryIsoCode = "";

  bool recordUpdatingStatus = false;
  Map<String, dynamic> updateFields = {};

  final ImagePicker _picker = ImagePicker();
  static File? _selectedImage;
  static String? _base64Image;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _base64Image = base64Encode(_selectedImage!.readAsBytesSync());
        _imageUploadBool = true;
        _imageUploadBool1 = true;
      });
    }
  }

  


   static late TextEditingController emailController;
   
  static late TextEditingController firstnameController;
  static late TextEditingController lastnameController;
  static late TextEditingController phoneController;
  static late TextEditingController dobController;


  void _initializeControllers() async {

      print('inside the initialize controllers');
     SystemChannels.navigation.setMethodCallHandler((call) async {
        if (call.method == "popRoute") {
          setState((){
            if(_editBool == false){
              _editBool = !_editBool;
              phoneController.text = widget.dataArray[0]['phone'];
              firstnameController.text = widget.dataArray[0]['name'];
              lastnameController.text = widget.dataArray[0]['last_name'];
              
                dobController.text = (DateFormat.yMd(locale).format(DateTime.parse(widget.dataArray[0]['date_of_birth']))).replaceAll('/', '-').replaceAll(".",'-');

            }else{
              Navigator.pop(context,_isSendBackUpdate);
               if(_isSendBackUpdate){
              setState((){
              _isSendBackUpdate = false;
            });
            }
            }
          });
        }
        return Future.value(null);
      });

    emailController = TextEditingController(text: widget.dataArray[0]['email'] is String ?widget.dataArray[0]['email']:"");
    firstnameController = TextEditingController(text: widget.dataArray[0]['name'] is String?widget.dataArray[0]['name']:"");
    lastnameController = TextEditingController(text: widget.dataArray[0]['last_name'] is String?widget.dataArray[0]['last_name']:"");
    phoneController = TextEditingController(text: widget.dataArray[0]['phone'] is String ?widget.dataArray[0]['phone']:"");
            // dobController = TextEditingController(text: widget.dataArray[0]['date_of_birth'] is String?(DateFormat.yMd(locale).format(DateTime.parse(widget.dataArray[0]['date_of_birth']))).replaceAll('/', '-').replaceAll(".",'-'):"");

  }

  Future<void> _updateRecord() async {
    _updateEmail = emailController.text.trim();
    _updateName = firstnameController.text.trim();
    _updateLastName = lastnameController.text.trim();
    _updatePhone = phoneController.text.trim();
    _updateDOB =dobController.text.trim();    
    print(_updatePhone == widget.dataArray[0]['phone']);

    if((_updatePhone == widget.dataArray[0]['phone'] || 
    _updatePhone.isEmpty) && (_updateEmail == widget.dataArray[0]['email'] || _updateEmail.isEmpty) && 
    (_updateName == widget.dataArray[0]['name'] || _updateName.isEmpty)&& (_updateLastName == widget.dataArray[0]['last_name'] || _updateLastName.isEmpty)&& (
      DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_updateDOB)) == widget.dataArray[0]['date_of_birth'] || _updateDOB.isEmpty
      ) &&(_imageUploadBool == false || widget.dataArray[0]['image_1920'] == _base64Image) ){
      setState(()  {
        _isUpdatedBool = false;
      });
      print("no");
    }else{
      setState(()  {
        _isUpdatedBool = true;
        recordUpdatingStatus = true;
      });
      print("yes");
    }

    final domain = await Helper.getDomain();
    final email = await Helper.getUserEmailId();
    final password = await Helper.getUserPassword();
    final dbname = await Helper.getDB();
    
    if(_isUpdatedBool){
      Fluttertoast.showToast(
        msg: "Updating the Record",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );

    if(_updateName != widget.dataArray[0]['name']){
      updateFields['name'] = _updateName;
    }
    if(_updateLastName != widget.dataArray[0]['last_name']){
      updateFields['last_name'] = _updateLastName;
    }
    if(_updateEmail != widget.dataArray[0]['email']){
      updateFields['email'] = _updateEmail;
      
    }
    if(_updatePhone != widget.dataArray[0]['phone']){
      updateFields['phone'] = _updatePhone; 
    }
    if(_imageUploadBool){
      if(_base64Image != widget.dataArray[0]['image_1920']){
       updateFields['image_1920'] = _base64Image;
      }
    }
    
    if(DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_updateDOB)) != widget.dataArray[0]['date_of_birth']){
      updateFields['date_of_birth'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_updateDOB));
    }

    final client = OdooClient(domain as String);
    try{
    await client.authenticate(dbname as String,email as String,password as String);
    
    _updateDOB = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_updateDOB));

    await client.callKw({'model':'res.partner', "method":'write', "args":[[widget.dataArray[0]['partner_id'][0]],updateFields],'kwargs': {}});
      
    print("record successfully updated");

    updateFields.clear();
    setState((){
      widget.dataArray[0]['name'] = _updateName;
      widget.dataArray[0]['last_name'] = _updateLastName;
      widget.dataArray[0]['phone'] = _updatePhone;
      widget.dataArray[0]['email']=  _updateEmail;
      widget.dataArray[0]['date_of_birth']= _updateDOB;
      _isSendBackUpdate = true;
      recordUpdatingStatus = false;
      
    });
    if(_imageUploadBool){
      if(_base64Image != widget.dataArray[0]['image_1920']){
        widget.dataArray[0]['image_1920'] = _base64Image;
       
      }
    }

    Fluttertoast.showToast(
        msg: "Record Successfully updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );
    } on OdooException catch(e){
      setState((){
        firstnameController.text = widget.dataArray[0]['name'];
        lastnameController.text = widget.dataArray[0]['last_name'];
      phoneController.text = widget.dataArray[0]['phone'];
      emailController.text = widget.dataArray[0]['email'];
      dobController.text = widget.dataArray[0]['date_of_birth'];
      _selectedImage = null;
        _base64Image = null;
      });
      

       showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error in updating profile data for the login $email'),
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
    }else{
      Fluttertoast.showToast(
        msg: "No new Data to update",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );
    }
  }

Future<void> _datePicker() async{
  DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    print(pickedDate);
    dobController.text = DateFormat.yMd(locale).format(pickedDate!).replaceAll('/', '-').replaceAll('.','-');
}

// bool validateIndianPhoneNumber(String phoneNumber) {
//   String regexPattern = r"^\+" + countryCode + r"\d{"+nationalNumberLengths.toString()+r"}$";
//   print(regexPattern);
//   // final regExp = RegExp(r'^\+91\d{10}$');
//   final regExp = RegExp(regexPattern);
//   return regExp.hasMatch(phoneNumber);
// }

  @override
  Widget build(BuildContext context){

      final screenHeight = MediaQuery.of(context).size.height;    

    return  Scaffold(
      backgroundColor: Color(0xFFE8EAF6),
      appBar: AppBar(
        backgroundColor: Color(0xFFA784F2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _isSendBackUpdate);
            if(_isSendBackUpdate){
              setState((){
              _isSendBackUpdate = false;
            });
            }
            
          },
        ),
        title: Text("Your Profile",style: TextStyle(color: Colors.white)),
        actions: [IconButton(
          onPressed: () => {print("I am pressed")},
          icon: Icon(Icons.settings,color: Colors.white),
        )],
        iconTheme: IconThemeData(
                  color: Colors.white, 
                )
      ),
      
      body:Container(
          
          decoration: BoxDecoration(color: Color(0xFFA784F2)),
          // child: SingleChildScrollView(
            
            child: Container(
            height: screenHeight,
            decoration: BoxDecoration(
              color: Colors.white,borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40))
              ),
            child: widget.dataArray.length>0?SingleChildScrollView(
              child: Container(
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40))),
              alignment: Alignment(0,-1),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFFA784F2),
                    child: _editBool?CircleAvatar(
                      radius: 55,
                      backgroundImage: 
                      _imageUploadBool && _selectedImage != null?
                      FileImage(_selectedImage!):
                      (widget.dataArray[0]['image_1920'] is String &&
                      widget.dataArray[0]['image_1920'].isNotEmpty)?
                      profileImage
                      :                    
                      AssetImage('assets/images/camera.png') as ImageProvider
                    ):ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA784F2),
                      padding: EdgeInsets.only(left:5.0,right:5.0),
                    ),
                      onPressed: () => {
                        _pickImage(),
                      },
                      child: _imageUploadBool1!=false?CircleAvatar(radius: 80,backgroundImage: FileImage(_selectedImage!)):Text("Upload Image",style: TextStyle(color: Colors.white)),
                    )
                  ),
                  SizedBox(height: 15),
                  Text(widget.dataArray[0]['name']!=false && widget.dataArray[0]['last_name'] != false?widget.dataArray[0]['name']+ " "+widget.dataArray[0]['last_name']:widget.dataArray[0]['name'],style: TextStyle(color: Color(0xFFA784F2),fontSize: 28, fontWeight: FontWeight.w700)),
                  Text("UI/UX Designer",style: TextStyle(fontSize: 17)),
                  SizedBox(height:20),
                  _ProfileInfoWidget(
                    context,
                    label: 'Your Email',
                    // info: widget.dataArray[0]['email'],
                    hintTextBool: false,
                    isEnabled: false,
                    controller: emailController,
                    icon: Icons.email,
                  ),
                  SizedBox(height:20),
                  _ProfileInfoWidget(
                    context,
                    label: 'First name',
                    // info: widget.dataArray[0]['name'] + " "+widget.dataArray[0]['last_name'],
                    isEnabled: true,
                    controller: firstnameController,
                    hintTextBool: false,
                    icon: Icons.badge,
                  ),
                  SizedBox(height:20),
                  _ProfileInfoWidget(
                    context,
                    label: 'Last name',
                    // info: widget.dataArray[0]['name'] + " "+widget.dataArray[0]['last_name'],
                    isEnabled: true,
                    controller: lastnameController,
                    hintTextBool: false,
                    icon: Icons.badge,
                  ),
                  SizedBox(height:20),
                  _ProfileInfoWidget(
                    context,
                    label: 'phone',
                    // info: widget.dataArray[0]['phone'],
                    isEnabled: true,
                    controller: phoneController,
                    hintTextBool: false,
                    icon: Icons.contact_page_sharp,
                  ),
                  SizedBox(height:20),
                  _ProfileInfoWidget(
                    context,
                    label: 'DOB',
                    isEnabled: true,
                    hintTextBool: true,
                    controller: dobController,
                    icon: Icons.calendar_month,
                  ),
                  SizedBox(height:30),
                  recordUpdatingStatus==false?
                  ElevatedButton(
                    onPressed: () => {

                      setState((){
                        if((firstnameController.text).isNotEmpty && (lastnameController.text).isNotEmpty && (phoneController.text).isNotEmpty){
                          
                          
                          // phoneController.text = (phoneController.text).startsWith("+$countryCode")?(phoneController.text).trim():"+$countryCode${phoneController.text}".trim();
                          // print(phoneController.text);

                          // bool isValid = validateIndianPhoneNumber(phoneController.text);
                          // print(isValid);
                          
                          
                            if(_editBool == false){
                              _updateRecord();
                              _imageUploadBool1 = false;

                            };
                          
                              _editBool = !_editBool;
                          
                          

                        }else{
                          Fluttertoast.showToast(
                              msg: ((firstnameController.text).isEmpty && (phoneController.text).isEmpty && (lastnameController.text).isEmpty)?
                              "Please enter valid name and phone number":
                              ((firstnameController.text).isEmpty && (lastnameController.text).isEmpty)?"Please enter valid first name and last name":
                              ((phoneController.text).isEmpty && (lastnameController.text).isEmpty)?"Please enter valid last name and mobile number":
                              ((firstnameController.text).isEmpty && (phoneController.text).isEmpty)?"Please enter valid first name and mobile number":
                              ((firstnameController.text).isEmpty)?"Please enter valid first name":
                              ((lastnameController.text).isEmpty)?"Please enter valid last name":
                              ((phoneController.text).isEmpty)?"Please enter valid mobile number": "",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        } 
                      })
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA784F2),
                    ),
                    child: _editBool?Text("Edit",style: TextStyle(color: Colors.white)):Text("Save",style: TextStyle(color: Colors.white)),
                  ):CircularProgressIndicator(),
                  SizedBox(height:10)
                ]
              )
            )):Center(child: CircularProgressIndicator())
          )
      // )
      ),
      
    
    );

  }

  Widget _ProfileInfoWidget(BuildContext context, {String? label, String? info, IconData? icon, TextEditingController? controller,bool? hintTextBool,bool? isEnabled}){
    return Padding(
      padding: EdgeInsets.only(left: 15.0,right:15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 14),),
           SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height:60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _editBool?Text(
                    controller!.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ):TextField(
                    enabled: isEnabled,
                    readOnly: label=='DOB'?true:false,
                    onTap: ((){
                      if(label == 'DOB'){
                        
                        _datePicker();
                      }
                    }),
                    
                  
                          controller: controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: hintTextBool!?'yyyy-MM-DD':"",
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          
                        )
                ),
                Icon(icon, color: Colors.grey[600]),
              ],
            ),
          )
        ]

      )
    );
  }

}


//Country(alpha2: IN, alpha3: IND, continent: Continent(wireName: Asia), countryCode: 91, currencyCode: INR, gec: IN, geo: GeoData(coordinate: Coordinate(latitude: 20.5937, longitude: 78.9629), maxCoordinate: Coordinate(latitude: 37.6, longitude: 97.4), minCoordinate: Coordinate(latitude: 6.75, longitude: 68.15), boundary: Boundary(northeast: Coordinate(latitude: 37.6, longitude: 97.4), southwest: Coordinate(latitude: 6.75, longitude: 68.15))), internationalPrefix: 00, ioc: IND, isoLongName: Republic of India, isoShortName: India, languagesOfficial: [hi, en], languagesSpoken: [hi, en, ta, bn, te], nationalDestinationCodeLengths: [2, 3], nationalNumberLengths: [10], nationalPrefix: 0, nationality: Indian, number: 91, postalCode: true, postalCodeFormat: null, region: Region(wireName: Asia), startOfWeek: Week(wireName: monday), subregion: Southern Asia, unLocode: IN, unofficialNames: [India, भारत], worldRegion: WorldRegion(wireName: APAC))
