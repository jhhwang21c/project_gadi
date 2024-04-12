import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/fragments/w_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPageFragment extends StatefulWidget {
  const MyPageFragment({super.key});

  @override
  State<MyPageFragment> createState() => _MyPageFragmentState();
}

class _MyPageFragmentState extends State<MyPageFragment> {
  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return ProfileWidget(userID: userID,);
  }

}