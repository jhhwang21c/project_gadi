import 'package:cloud_firestore/cloud_firestore.dart';

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
