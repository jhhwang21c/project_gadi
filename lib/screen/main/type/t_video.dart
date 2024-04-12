import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String videoURL;
  final String title;
  final String userID;
  final String nickname;

  Video({required this.videoURL, required this.title, required this.userID, required this.nickname});

  factory Video.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Video(
      videoURL: data['videoURL'] as String? ?? '',
      title: data['title'] as String? ?? '',
      userID: data['userID'] as String? ?? '',
      nickname: data['nickname'] as String? ?? '',
    );
  }
}
