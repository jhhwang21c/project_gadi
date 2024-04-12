import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/type/t_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  final String userID;
  const ProfileWidget({super.key, required this.userID});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isUser = false;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      isUser = widget.userID == currentUser.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: context.appColors.seedColor,
          centerTitle: true,
          title: Image.asset(
            "assets/image/logo/gadi_white.png",
            height: 32,
          ),
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Stack(children: [
              Container(
                height: 115,
                color: context.appColors.seedColor,
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: fetchUserData(widget.userID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    var userData = snapshot.data!;
                    return Column(
                      children: [
                        Text(userData['nickname'],
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        ListTile(
                          leading: Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Followers",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white)),
                                Text(
                                  "${userData['followers']}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                if (!isUser)
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print(userData['isFollowing']);
                                        // Implement follow functionality here
                                      },
                                      child: Text(userData['isFollowing'] ? "Following" : "Follow"),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          title: CircleAvatar(
                            backgroundImage: NetworkImage(userData['imageURL']),
                            radius: 60,
                          ),
                          trailing: Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Following",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white)),
                                Text(
                                  "${userData['following']}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                if (!isUser)
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Implement message functionality here
                                      },
                                      child: const Text("Message"),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ]),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(widget.userID)
                    .collection('posts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var posts = snapshot.data!.docs;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: 1,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var post =
                          posts[index].data() as Map<String, dynamic>;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: NetworkImage(post['imageURL']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8, right: 8),
                                child: Text(
                                  post['title'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    backgroundColor:
                                    Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        )
    );
  }
}
