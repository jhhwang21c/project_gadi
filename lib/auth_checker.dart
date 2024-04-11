import 'dart:convert';

import 'package:GADI/screen/main/s_main.dart';
import 'package:GADI/screen/main/s_signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GADI/screen/main/type/t_user.dart';

class AuthChecker extends StatefulWidget {
  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedIn = prefs.getBool('isSignedIn') ?? false;

    if (!isSignedIn) {
      // Ensuring FirebaseAuth instance is also signed out
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    }

    setState(() {
      _isSignedIn = isSignedIn;
    });

    print('SignInStatus: $_isSignedIn');
  }

  late AppUser appUser;


  Future<void> _fetchAndStoreUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        appUser = AppUser.fromFirestore(docSnapshot);

        // Store the user info as JSON in SharedPreferences
        final String userJson = json.encode(appUser.toJson());
        await prefs.setString('appUser', userJson);
      }
    }
  }

  Future<AppUser?> _getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('appUser');

    if (userJson != null) {
      return AppUser.fromJson(json.decode(userJson));
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    return _isSignedIn ? MainScreen() : SignInScreen(onSignIn: _onSignIn);
  }

  void _onSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', true);
    await _fetchAndStoreUserInfo();

    setState(() {
      _isSignedIn = true;
    });

  }
}
