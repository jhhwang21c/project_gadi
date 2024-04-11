import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/tab/home/c_artworkCard.dart';
import 'package:GADI/screen/main/type/t_artwork.dart';
import 'package:flutter/material.dart';

class Recommendation extends StatefulWidget {
  const Recommendation({Key? key}) : super(key: key);

  @override
  _RecommendationState createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  final ScrollController _scrollController = ScrollController();
  List<Artwork> _artworks = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadArtworks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _loadArtworks();
      }
    });
  }

  Future<void> _loadArtworks() async {
    if (!_hasMoreData) return;
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('artworks')
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    } else {
      _hasMoreData = false;
    }

    List<Artwork> newArtworks =
    snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList();

    setState(() {
      _artworks.addAll(newArtworks);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title:Image.asset("assets/image/logo/gadi_white.png",
                height: 20,
              ),
              titlePadding: const EdgeInsets.only(bottom: 250),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _artworks.isNotEmpty
                      ? Image.network(_artworks[0].imageURL, fit: BoxFit.cover)
                      : Image.network("https://fakeimg.pl/600x300?text=+"),
                  Positioned(
                    bottom: 20,
                    right: 15,
                    child: GestureDetector(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: context.appColors.seedColor, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                            child:
                            Icon(Icons.tune)
                        ),

                      ),
                      onTap: () { print("Tapped"); },
                    ),
                  ),
                  const Center(
                    child: Text("RECOMMENDATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40,),),

                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 20,)
          ),

          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return ArtworkCard(artwork: _artworks[index]);
              },
              childCount: _artworks.length,
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!_hasMoreData && _artworks.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: const Text("You've reached the end"),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
