import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String nickname;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.nickname,

  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      firstName: data['first_name'],
      lastName: data['last_name'],
      nickname: data['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
    };
  }

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      nickname: json['nickname'],
    );
  }

}


Future<Map<String, dynamic>> fetchUserData(userID) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userDoc = await _firestore.collection('users').doc(userID).get();
  var userData = userDoc.data() as Map<String, dynamic>;

  var followersDoc = await _firestore
      .collection('users')
      .doc(userID)
      .collection('follow')
      .doc('followers')
      .get();
  var followersData = followersDoc.data() as Map<String, dynamic>;
  var followersCount = followersData['UID']?.length ?? 0;

  var followingDoc = await _firestore
      .collection('users')
      .doc(userID)
      .collection('follow')
      .doc('following')
      .get();
  var followingData = followingDoc.data() as Map<String, dynamic>;
  var followingCount = followingData['UID']?.length ?? 0;

  // Check if current user's ID is in followers list
  final currentUser = FirebaseAuth.instance.currentUser;
  var isFollowing = followersData['UID'].contains(currentUser?.uid);

  return {
    'nickname': userData['nickname'],
    'imageURL': userData['imageURL'],
    'followers': followersCount,
    'following': followingCount,
    'isFollowing': isFollowing
  };
}