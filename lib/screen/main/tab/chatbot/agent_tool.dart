import 'dart:async';
import 'package:GADI/common/common.dart';
import 'package:langchain/langchain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


FutureOr<String> runNoSqlQuery(String queryText,
    {Map<String, dynamic>? queryParameters, ToolOptions? options}) async {
  //final db = sqlite3.open('assets/art_auction.sqlite');

  FirebaseFirestore db = FirebaseFirestore.instance;

  // Reference to the collection
  CollectionReference collection = db.collection('artworks');

  // Adjust this part based on your specific query needs
  Query query = collection;
  if (queryParameters != null) {
    for (var field in queryParameters.keys) {
      var value = queryParameters[field];
      // Example of how to add conditions; adjust as needed
      query = query.where(field, isEqualTo: value);
    }
  }

  // Get the data
  QuerySnapshot querySnapshot = await query.get();
  List<QueryDocumentSnapshot> documents = querySnapshot.docs;

  // Use a StringBuffer to concatenate strings efficiently
  StringBuffer sb = StringBuffer();

  for (final doc in documents) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    sb.writeAll(data.values, ' | '); // Separate each value with ' | '
    sb.writeln(); // Add a new line after each document
  }

  return sb.toString(); // Convert the StringBuffer content to String // Convert the StringBuffer content to String
}

final runQueryTool = Tool.fromFunction(
  name: "runNoSqlQuery",
  description:'''
Run a Firestore query. Only answer asked data. Provide the collection path and optional query parameters. Firestore organizes data into documents within collections, not tables. Example fields in documents might include:
  title (String): title of artwork, artist (String): name in English, artist_in_korean (String): name in Korean, year (String): year of creation, currency (String): currency of price, price (int): estimated price, height (double): height, width (double): width, medium (String): medium, description (String): description, auction_name (String): name of the auction that the artwork is listed on, auction_date (String): scheduled auction date, total_views (int): total views of the artwork in the website, monthly_views (int): monthly views; 
  Specify query parameters as a Map<String, dynamic> representing field-value pairs for filtering documents.''',
  func: runNoSqlQuery,
);
