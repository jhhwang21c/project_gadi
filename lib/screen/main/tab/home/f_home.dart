import 'package:GADI/auth_checker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GADI/common/dart/extension/context_extension.dart';
import 'package:GADI/screen/main/tab/home/f_best.dart';
import 'package:GADI/screen/main/tab/home/f_recommendation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {

  final _productsSearcher = HitsSearcher(applicationID: 'LSLPKC60FN',
      apiKey: '4bad0586f30077a4b49e3a1d55d181cb',
      indexName: 'gadi_artworks');
  final _searchTextController = TextEditingController();

  Stream<SearchMetadata> get _searchMetadata => _productsSearcher.responses.map(SearchMetadata.fromResponse);


  Future<String> getTopArtworkUrl() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('artworks')
        .orderBy('monthly_views', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['imageURL'] as String;
    } else {
      return 'https://via.placeholder.com/200';
    }
  }

  Future<String> getRecUrl() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('artworks').limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['imageURL'] as String;
    } else {
      return 'https://via.placeholder.com/200'; // Placeholder image URL in case of no data
    }
  }

  Future<String> getExchangeRate() async {
    CurrencyRate rate = await LiveCurrencyRate.convertCurrency("USD", "KRW", 1);
    final res = rate.result.toStringAsFixed(2);
    return res != '0.00' ? res : '1352.61';
  }

  Future<List<String>> getEventImageUrls() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    return snapshot.docs
        .map((doc) => doc.data()['imageURL'] as String)
        .toList();
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Reset the isSignedIn flag in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false);

    // Optionally, navigate the user to the sign-in screen or another appropriate screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthChecker()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(() => _productsSearcher.query(_searchTextController.text));
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final width1 = MediaQuery.of(context).size.width * 0.90;
    final width2 = MediaQuery.of(context).size.width * 0.43;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            signOut(context);
          },
          child: Image.asset(
            "assets/image/logo/gadi_new.png",
            height: 32,
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        // Allows the body to be scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              width: width1,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                controller: _searchTextController,
                decoration: InputDecoration(
                  hintText: "검색어를 입력하세요",
                  fillColor: context.appColors.sub1,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),
            if (_searchTextController.text.isNotEmpty)
              StreamBuilder<SearchMetadata>(
                stream: _searchMetadata,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${snapshot.data!.nbHits} hits'),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MonthlyBest()),
                  );
                },
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: FutureBuilder<String>(
                      future: getTopArtworkUrl(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 185,
                            width: width1,
                            color: Colors.grey, // Placeholder color
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        }
                        return Image.network(
                          snapshot.data!,
                          height: 185,
                          width: width1,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(
                            0.4), // This sets the background color of the container
                        borderRadius: BorderRadius.circular(
                            4), // Optional: if you want rounded corners
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.0),
                        child: Text(
                          'MONTHLY BEST',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Recommendation()),
                  );
                },
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: FutureBuilder<String>(
                      future: getRecUrl(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 185,
                            width: width1,
                            color: Colors.grey, // Placeholder color
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        }
                        return Image.network(
                          snapshot.data!,
                          height: 185,
                          width: width1,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.0),
                        child: Text(
                          'RECOMMENDATION',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Container(
                  width: width1,
                  child:
                      Image.asset(
                        "assets/image/icon/news_horizontal.png",
                        width: width1,
                        fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20),
              child: Center(
                child: Container(
                  width: width1,
                  child:
                  Image.asset(
                    "assets/image/icon/auction_schedule.png",
                    width: width1,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            FutureBuilder<List<String>>(
              future: getEventImageUrls(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 80,
                      aspectRatio: 871 / 179,
                      viewportFraction: 1,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: const Duration(seconds: 5),
                    ),
                    items: snapshot.data!.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          );
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return const Text('No Information');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SearchMetadata {
  final int nbHits;

  const SearchMetadata(this.nbHits);

  factory SearchMetadata.fromResponse(SearchResponse response) =>
      SearchMetadata(response.nbHits);
}

class Product {
  final String name;
  final String image;

  Product(this.name, this.image);

  static Product fromJson(Map<String, dynamic> json) {
    return Product(json['name'], json['image_urls'][0]);
  }
}
