import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/tab/gallery/c_favoriteCard.dart';
import 'package:GADI/screen/main/type/t_artwork.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryFragment extends StatefulWidget {
  const GalleryFragment({super.key});

  @override
  State<GalleryFragment> createState() => _GalleryFragmentState();
}

class _GalleryFragmentState extends State<GalleryFragment> {
  Stream<List<Artwork>> streamFavoriteArtworks(String userId) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection('favorites').doc(userId).snapshots().asyncMap((snapshot) async {
      List<Artwork> artworks = [];
      if (snapshot.exists) {
        List<dynamic> favoriteArtworkIds = snapshot.get('favorites');
        for (String artworkId in favoriteArtworkIds) {
          DocumentSnapshot artworkSnapshot = await db.collection('artworks').doc(artworkId).get();
          artworks.add(Artwork.fromFirestore(artworkSnapshot));
        }
      }
      return artworks;
    });
  }
  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          "assets/image/logo/gadi_new.png",
          height: 32,
        ),
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<List<Artwork>>(
        stream: streamFavoriteArtworks(userID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Artwork> artworks = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 20.0,
                ),
                itemCount: artworks.length,
                itemBuilder: (context, index) {
                  Artwork artwork = artworks[index];
                  return FavoriteCard(artwork: artwork);
                },
              ),
            );
          } else {
            return const Center(child: Text('No favorite artworks found'));
          }
        },
      ),
    );
  }
}
