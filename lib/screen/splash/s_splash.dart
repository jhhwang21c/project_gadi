import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:GADI/common/util/async/flutter_async.dart';
import 'package:GADI/screen/main/s_main.dart';
import 'package:flutter/material.dart';
import 'package:nav/nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AfterLayoutMixin{

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset(
      "assets/image/splash/g_white.png",
      width: 288,
      height: 288,
    ));
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    delay((){
      Nav.clearAllAndPush(const MainScreen());
    }, const Duration(milliseconds: 1500));

  }
}
