import 'package:cloud_firestore/cloud_firestore.dart';

class Artwork {
  final String id;
  final String title;
  final String artist;
  final String artistKorean;
  final String year;
  final int price;
  final String imageURL;
  final String description;
  final String auctionDate;
  final String auctionName;
  final String medium;
  final int monthlyViews;
  final int totalViews;
  final double height;
  final double width;
  final List<dynamic> style;

  Artwork({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistKorean,
    required this.year,
    required this.price,
    required this.imageURL,
    required this.medium,
    required this.description,
    required this.auctionDate,
    required this.auctionName,
    required this.monthlyViews,
    required this.totalViews,
    required this.height,
    required this.width,
    required this.style,
  });

  factory Artwork.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Artwork(
      id: doc.id,
      title: data['title'],
      artist: data['artist'],
      imageURL: data['imageURL'],
      monthlyViews: data['monthly_views'],
      artistKorean: data['artist_in_korean'],
      year: data['year'],
      price: data['price'],
      medium: data['medium'],
      description: data['description'],
      auctionDate: data['auction_date'],
      auctionName: data['auction_name'],
      totalViews: data['total_views'],
      height: data['height'].toDouble(),
      width: data['width'].toDouble(),
      style: data['style'],
    );
  }
}
