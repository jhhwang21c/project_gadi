import 'dart:ui';
import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/fragments/f_auctions.dart';
import 'package:GADI/screen/main/tab/gallery/f_ar.dart';
import 'package:GADI/screen/main/type/t_artwork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ArtDetail extends StatefulWidget {
  final Artwork artwork;

  const ArtDetail({required this.artwork, super.key});

  @override
  State<ArtDetail> createState() => _ArtDetailState();
}

class _ArtDetailState extends State<ArtDetail> {
  bool isFavorite = false;
  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkIfFavorite(userID);
  }

  void checkIfFavorite(String userID) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot userFavorites =
        await db.collection('favorites').doc(userID).get();

    if (userFavorites.exists) {
      List<dynamic> favorites = userFavorites.get('favorites');
      setState(() {
        isFavorite = favorites.contains(widget.artwork.id);
      });
    }
  }

  void toggleFavorite(String userId, String artworkId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference favoritesRef = db.collection('favorites').doc(userId);

    // Optimistically update the UI
    bool wasFavorite = isFavorite;
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      DocumentSnapshot docSnapshot = await favoritesRef.get();

      if (docSnapshot.exists) {
        List<dynamic> favorites = docSnapshot.get('favorites');
        if (favorites.contains(artworkId)) {
          await favoritesRef.update({
            'favorites': FieldValue.arrayRemove([artworkId]),
          });
        } else {
          await favoritesRef.update({
            'favorites': FieldValue.arrayUnion([artworkId]),
          });
        }
      } else {
        await favoritesRef.set({
          'favorites': [artworkId],
        });
      }
    } catch (e) {
      // If there's an error, revert the UI change
      setState(() {
        isFavorite = wasFavorite;
      });
      print('Error updating favorite status: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 600,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: FlexibleSpaceBar(
          title: Image.asset(
            "assets/image/logo/gadi_white.png",
            height: 20,
          ),
          titlePadding: const EdgeInsets.only(bottom: 550),
          centerTitle: true,
          background: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.artwork.imageURL, fit: BoxFit.cover),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Container(
                              constraints: const BoxConstraints(
                                  maxHeight: 300, maxWidth: 300),
                              child: Image.network(widget.artwork.imageURL))),
                      Positioned(
                        left: 15,
                        top: 15,
                        child: GestureDetector(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                                child: Icon(
                              Icons.view_in_ar,
                              color: context.appColors.seedColor,
                            )),
                          ),
                          onTap: () async {
                            try {
                              final response = await http.get(Uri.parse(widget.artwork.imageURL));
                              if (response.statusCode == 200) {
                                // Proceed to ARFragment with the downloaded image
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ARFragment(
                                      imageBytes: response.bodyBytes,
                                      height: widget.artwork.height,
                                      width: widget.artwork.width,
                                    ),
                                  ),
                                );
                              } else {
                                print('Failed to download the image');
                                // Handle error or show a message
                              }
                            } catch (e) {
                              print('Error downloading the image: $e');
                              // Handle error or show a message
                            }
                          },

                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 15,
                        child: GestureDetector(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Icon(
                                isFavorite
                                    ? Icons.star
                                    : Icons.star_border_outlined,
                                color: context.appColors.seedColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            toggleFavorite(userID, widget.artwork.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.artwork.artist != ""
                          ? Text(
                              widget.artwork.artist,
                              style: const TextStyle(color: Colors.white),
                            )
                          : Text(
                              widget.artwork.artistKorean,
                              style: const TextStyle(color: Colors.white),
                            ),
                      Container(
                        width: 250,
                        child: Text(
                          widget.artwork.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: 250,
                        height: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: 125,
                                  child: RichText(
                                    text: TextSpan(children: [
                                      const WidgetSpan(
                                          child: Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.brush,
                                          color: Colors.white,
                                        ),
                                      )),
                                      TextSpan(
                                          text: widget.artwork.medium,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ))
                                    ]),
                                  )),
                              Container(
                                  width: 125,
                                  child: RichText(
                                    text: TextSpan(children: [
                                      const WidgetSpan(
                                          child: Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.schedule,
                                          color: Colors.white,
                                        ),
                                      )),
                                      TextSpan(
                                          text: widget.artwork.year != ""
                                              ? widget.artwork.year
                                              : "unknown",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ))
                                    ]),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  width: 125,
                                  child: RichText(
                                    text: TextSpan(children: [
                                      const WidgetSpan(
                                          child: Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.aspect_ratio,
                                          color: Colors.white,
                                        ),
                                      )),
                                      TextSpan(
                                          text:
                                              "${widget.artwork.width} x ${widget.artwork.height}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ))
                                    ]),
                                  )),
                              Container(
                                  width: 125,
                                  child: RichText(
                                    text: TextSpan(children: [
                                      const WidgetSpan(
                                          child: Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.format_paint,
                                          color: Colors.white,
                                        ),
                                      )),
                                      TextSpan(
                                          text: widget.artwork.style[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ))
                                    ]),
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "작품 설명",
                      style: TextStyle(
                          fontSize: 16, color: context.appColors.seedColor),
                    ),
                  ),
                  Text(widget.artwork.description),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    color: context.appColors.sub1,
                    height: 50,
                    width: screenWidth * 0.95,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Estimated Price",
                          style: TextStyle(
                              fontSize: 16, color: context.appColors.seedColor),
                        ),
                        Text(
                          "₩ ${widget.artwork.price}",
                          style: TextStyle(
                              fontSize: 16, color: context.appColors.seedColor),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Auctions()),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                          color: context.appColors.seedColor,
                          borderRadius: BorderRadius.circular(15)),
                      height: 50,
                      width: screenWidth * 0.95,
                      child: Center(
                        child: Text(
                          "거래하기",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
    ]));
  }
}
