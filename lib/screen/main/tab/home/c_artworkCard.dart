import 'package:GADI/screen/main/fragments/f_art_detail.dart';
import 'package:GADI/screen/main/type/t_artwork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArtworkCard extends StatelessWidget {
  final Artwork artwork;
  final int? rank;

  const ArtworkCard({Key? key, required this.artwork, this.rank})
      : super(key: key);

  String getRankSuffix(int rank) {
    if (rank >= 11 && rank <= 13) {
      return 'th';
    }

    switch (rank % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

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
            SizedBox(
              width: cardWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (rank != null)
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: Text(
                          "$rank${getRankSuffix(rank!)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                      child: Container(
                    height: 30,
                  )),
                  Container(
                    margin: const EdgeInsets.only(right: 10, top: 10),
                    decoration: BoxDecoration(
                        color: const Color(0x555555).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.visibility_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: " ${artwork.monthlyViews}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
