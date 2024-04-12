import 'package:GADI/common/common.dart';
import 'package:GADI/screen/main/tab/community/f_community.dart';
import 'package:GADI/screen/main/tab/gallery/f_gallery.dart';
import 'package:GADI/screen/main/tab/home/f_home.dart';
import 'package:GADI/screen/main/tab/chatbot/f_chatbot.dart';
import 'package:GADI/screen/main/tab/mypage/f_mypage.dart';
import 'package:flutter/material.dart';

// items that are shown in the bottom navigation bar. each item leads to a new page/tab

enum TabItem {
  home(Icons.home_outlined, 'Home', HomeFragment()),
  ranking(Icons.view_in_ar, 'Gallery', GalleryFragment()),
  chatbot(Icons.star, 'GADI', ChatbotFragment(),
      imagePath: 'assets/image/logo/g_gray.svg'),
  community(Icons.video_library_outlined, 'Community', CommunityFragment()),
  mypage(Icons.person_outline, 'Profile', MyPageFragment());

  final IconData activeIcon;
  final IconData inActiveIcon;
  final String tabName;
  final Widget firstPage;
  final String? imagePath;

  const TabItem(this.activeIcon, this.tabName, this.firstPage,
      {IconData? inActiveIcon, this.imagePath})
      : inActiveIcon = inActiveIcon ?? activeIcon;

  BottomNavigationBarItem toNavigationBarItem(BuildContext context,
      {required bool isActivated}) {
    return BottomNavigationBarItem(
      icon: imagePath != null
          ? SvgPicture.asset(
          imagePath!,
          colorFilter: isActivated ? ColorFilter.mode(context.appColors.seedColor, BlendMode.srcIn) : ColorFilter.mode(context.appColors.sub4, BlendMode.srcIn),
          semanticsLabel: 'A red up arrow',
          height: 25,
          width: 25,
      )
          : Icon(
        key: ValueKey(tabName),
        isActivated ? activeIcon : inActiveIcon,
        color: isActivated ? context.appColors.seedColor : context.appColors.sub4,
      ),
      label: tabName,
    );
  }
}