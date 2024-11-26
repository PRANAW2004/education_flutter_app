import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static String userLoggedInKey = "USERLOGGEDIN";
  

  static Future<void> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(userLoggedInKey, isUserLoggedIn);
  }


  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<void> saveUserEmailId(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }


  static Future<String?> getUserEmailId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<void> saveUserPassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }


  static Future<String?> getUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }

  static Future<void> saveDomain(String domain) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('domain', domain);
  }

  static Future<String?> getDomain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('domain');
  }

  static Future<void> saveDB(String db) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('db', db);
  }

  static Future<String?> getDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('db');
  }

  static Future<void> saveBoolDB(bool db) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dbbool', db);
  }


  static Future<bool?> getBoolDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dbbool');
  }

  static Future<void> saveUser(String db) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', db);
  }


  static Future<String?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user');
  }

  static Future<void> saveUserId(int db) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userid', db);
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userid');
  }

  static Future<void> savepartnerId(int db) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('partnerid', db);
  }
  static Future<int?> getpartnerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('partnerid');
  }

  static Future<void> saveLocale(String db) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', db);
  }


  static Future<String?> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('locale');
  }

}