import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/fragments/f_art_detail.dart';
import 'package:GADI/screen/main/tab/gallery/f_ar.dart';
import 'package:GADI/screen/main/type/t_artwork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoriteCard extends StatelessWidget {
  final Artwork artwork;

  const FavoriteCard({Key? key, required this.artwork})
      : super(key: key);


  void updateViews() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    DocumentReference documentReference =
    _firestore.collection('artworks').doc(artwork.id);

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);

      if (!snapshot.exists) {
        throw Exception("Artwork does not exist!");
      }

      int newTotalViews = snapshot.get('total_views') + 1;
      int newMonthlyViews = snapshot.get('monthly_views') + 1;

      transaction.update(documentReference, {
        'total_views': newTotalViews,
        'monthly_views': newMonthlyViews,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.4;

    return GestureDetector(
      onTap: () {
        updateViews();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArtDetail(artwork: artwork)),
        );
      },
      child: Center(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: SizedBox(
                  width: cardWidth,
                  height: 190,
                  child: Image.network(
                    artwork.imageURL,
                    fit: BoxFit.cover,
                  )),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: GestureDetector(
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: context.appColors.sub4.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                      child: Icon(
                        Icons.view_in_ar_outlined,
                        color: Colors.white,
                        size: 20,
                      )),
                ),
                onTap: () async {
                  try {
                    final response = await http.get(Uri.parse(artwork.imageURL));
                    if (response.statusCode == 200) {
                      // Proceed to ARFragment with the downloaded image
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ARFragment(
                            imageBytes: response.bodyBytes,
                            height: artwork.height,
                            width: artwork.width,
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
              bottom: 10,
              left: 5,
              child: Container(
                width: cardWidth - 10,
                decoration: BoxDecoration(
                    color: const Color(0x0A0A0A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Text(
                          artwork.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            overflow: TextOverflow.clip,
                            height: 0.9,
                          ),
                        ),
                      ),
                      artwork.artist == ""
                          ? Text(
                        "By ${artwork.artistKorean}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        "By ${artwork.artist}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
