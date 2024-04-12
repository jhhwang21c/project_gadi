import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/tab/community/w_video_player.dart';
import 'package:GADI/screen/main/fragments/w_profile.dart';
import 'package:GADI/screen/main/type/t_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityFragment extends StatefulWidget {
  const CommunityFragment({super.key});

  @override
  State<CommunityFragment> createState() => _CommunityFragmentState();
}

class _CommunityFragmentState extends State<CommunityFragment> {

  Stream<List<Video>> fetchVideos() {
    return FirebaseFirestore.instance
        .collection('video')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Video.fromFirestore(doc))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262A2F),
      appBar: AppBar(
        backgroundColor: context.appColors.seedColor,
        centerTitle: true,
        title: Image.asset(
          "assets/image/logo/gadi_white.png",
          height: 32,
        ),
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<List<Video>>(
        stream: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final videos = snapshot.data!;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Stack(
                children: [
                  Center(
                    child: VideoPlayerWidget(videoUrl: video.videoURL),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: (){Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileWidget(userID: video.userID)),
                      );},
                      child: Text(
                        "${video.title}\nPosted by: ${video.nickname}",
                        style: const TextStyle(
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
