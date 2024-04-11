import 'package:GADI/common/dart/extension/context_extension.dart';
import 'package:flutter/material.dart';

class Auctions extends StatelessWidget {
  const Auctions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.appColors.sub4),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Image.asset(
          "assets/image/logo/gadi_new.png",
          height: 32,
        ),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("거래소", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: context.appColors.seedColor),),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                height: 120,
                width: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0xfff6f6f6)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/image/logo/kAuctionLogo.png"),
                    Text("K-Auction", style: TextStyle(fontSize: 20),),
                  ],
                ),
              ),
              Container(
                height: 120,
                width: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0xfff6f6f6)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/image/logo/mutualArtLogo.png"),
                    Text("Mutual Art", style: TextStyle(fontSize: 20),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
