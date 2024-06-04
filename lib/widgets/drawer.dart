import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:incite/api_controller/app_provider.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/utils/app_theme.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/widgets/anim_util.dart';
import 'package:incite/widgets/tap.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_controller/blog_controller.dart';
import '../model/blog.dart';
import '../model/home.dart';
import '../model/user.dart';
import '../utils/image_util.dart';
import '../utils/theme_util.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  bool isDark = false;
  var userProvider = UserProvider();

  List<HomeModel> drawer = [
    HomeModel(
        title: allMessages.value.dashboard ?? 'Dashboard', image: SvgImg.dash),
    HomeModel(
        title: allMessages.value.myProfile ?? 'My Profile',
        image: SvgImg.profile),
    HomeModel(
        title: allMessages.value.myStories ?? 'My Stories',
        image: SvgImg.fillBook),
    HomeModel(title: allMessages.value.myFeed ?? 'My Feed', image: SvgImg.dash),
    HomeModel(
        title: allMessages.value.settings ?? 'Settings', image: SvgImg.setting),
    HomeModel(title: allMessages.value.rateUs ?? 'Rate Us', image: SvgImg.star),
    HomeModel(
        title: allMessages.value.logout ?? 'Sign Out', image: SvgImg.logout),
    HomeModel(title: allMessages.value.login ?? 'Sign in', image: SvgImg.lock),
    HomeModel(title: allMessages.value.darkMode ?? 'Dark Mode', image: ''),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context, listen: false);
    return Drawer(
        width: size(context).width * 0.75,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: languageCode.value.pos == 'rtl'
              ? Radius.zero
              : const Radius.circular(20),
          bottomRight: languageCode.value.pos == 'rtl'
              ? Radius.zero
              : const Radius.circular(20),
          topLeft: languageCode.value.pos == 'rtl'
              ? const Radius.circular(20)
              : Radius.zero,
          bottomLeft: languageCode.value.pos == 'rtl'
              ? const Radius.circular(20)
              : Radius.zero,
        )),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(20, 24),
                  blurRadius: 50,
                  color: Color.fromRGBO(6, 0, 45, 0.25))
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 5, sigmaY: 5), // Adjust blur radius as needed
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: languageCode.value.pos == 'rtl'
                      ? Radius.zero
                      : const Radius.circular(20),
                  bottomRight: languageCode.value.pos == 'rtl'
                      ? Radius.zero
                      : const Radius.circular(20),
                  topLeft: languageCode.value.pos == 'rtl'
                      ? const Radius.circular(20)
                      : Radius.zero,
                  bottomLeft: languageCode.value.pos == 'rtl'
                      ? const Radius.circular(20)
                      : Radius.zero,
                ),
                color: dark(context)
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Colors.white, // Set desired drawer color and opacity
              ),
              padding: const EdgeInsets.only(
                  left: 24, top: 16, bottom: 16, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        const Hero(
                          tag: 'Drawer',
                          child: ProfileWidget(),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimationFadeSlide(
                              dx: 0.5,
                              duration: 300,
                              child: Text(
                                  currentUser.value.id == null
                                      ? 'Guest'
                                      : currentUser.value.name ?? 'Rahul',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: dark(context)
                                          ? ColorUtil.white
                                          : ColorUtil.textblack)),
                            ),
                            currentUser.value.id == null
                                ? const SizedBox()
                                : const SizedBox(height: 8),
                            currentUser.value.id == null
                                ? const SizedBox()
                                : AnimationFadeSlide(
                                    dx: 0.65,
                                    duration: 400,
                                    child: Text(
                                        currentUser.value.email ??
                                            'guest@mail.com',
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 13,
                                            color: dark(context)
                                                ? ColorUtil.lightGrey
                                                : ColorUtil.textgrey)),
                                  ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: Divider(
                          height: 0,
                          thickness: 0.5,
                          color: dark(context)
                              ? Theme.of(context).dividerColor
                              : ColorUtil.textgrey),
                    ),
                    ...drawer.asMap().entries.map((e) => (e.key == 3 ||
                                e.key == 1 ||
                                e.key == 2) &&
                            currentUser.value.id == null
                        ? const SizedBox()
                        : e.key == 6 && currentUser.value.id == null
                            ? const SizedBox()
                            : e.key == 7 && currentUser.value.id != null
                                ? const SizedBox()
                                : DrawWrap(
                                    pos: e.key,
                                    title: e.value.title,
                                    suffix: e.value.title == 'Dark Mode'
                                        ? ToggleButton(
                                            isON: appThemeModel
                                                .value.isDarkModeEnabled.value)
                                        : null,
                                    image: e.value.image,
                                    onTap: () {
                                      switch (e.key) {
                                        case 8:
                                          toggleDarkMode(!appThemeModel
                                              .value.isDarkModeEnabled.value);
                                          setState(() {});
                                          break;
                                        case 0:
                                          Navigator.pop(context);
                                          break;
                                        case 1:
                                          Navigator.pushNamed(
                                              context, '/UserProfile',
                                              arguments: true);
                                          break;
                                        case 3:
                                          Navigator.pushNamed(
                                              context, '/SaveInterests',
                                              arguments: true);
                                          break;
                                        case 2:
                                          blogListHolder2.clearList();
                                          blogListHolder2.setList(DataModel(
                                              blogs: provider.bookmarks));
                                          blogListHolder2
                                              .setBlogType(BlogType.bookmarks);
                                          setState(() {});
                                          Navigator.pushNamed(
                                                  context, '/SavedPage')
                                              .then((value) {});
                                          break;
                                        case 4:
                                          Navigator.pushNamed(
                                              context, '/SettingPage');
                                          break;
                                        case 5:
                                          redirectToPlayStore();
                                          break;
                                        case 7:
                                          Navigator.pushNamed(
                                              context, '/LoginPage');
                                          break;
                                        case 6:
                                          userProvider.logout(context);
                                          setState(() {});
                                          break;
                                        default:
                                      }
                                    })),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<List<SocialMedia>>(
                        valueListenable: socialMedia,
                        builder: (context, value, child) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 16,

                            ///  mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ...List.generate(
                                  value.length,
                                  (index) => InkResponse(
                                        onTap: () {
                                          openWhatsApp(value[index]
                                              .url!
                                              .split('=')
                                              .last);
                                        },
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                              getTabIcons(
                                                  value[index].name.toString()),
                                              size: 28),
                                        ),
                                      ))
                            ],
                          );
                        }),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  IconData? getTabIcons(String icon) {
    IconData? iconData;

    switch (icon.toLowerCase()) {
      case "facebook":
        iconData = TablerIcons.brand_facebook;
        return iconData;
      case "fb":
        iconData = TablerIcons.brand_facebook;
        return iconData;
      case "instagram":
        iconData = TablerIcons.brand_instagram;
        return iconData;
      case "youtube":
        iconData = TablerIcons.brand_youtube;
        return iconData;
      case "pintrest":
        iconData = TablerIcons.brand_pinterest;
        return iconData;
      case "pinterest":
        iconData = TablerIcons.brand_pinterest;
        return iconData;
      case "linkedin":
        iconData = TablerIcons.brand_linkedin;
        return iconData;
      case "snapchat":
        iconData = TablerIcons.brand_snapchat;
        return iconData;
      case "twitter":
        iconData = TablerIcons.brand_twitter;
        return iconData;
      case "skype":
        iconData = TablerIcons.brand_skype;
        return iconData;
      case "whatsapp":
        iconData = TablerIcons.brand_whatsapp;
        return iconData;
      case "telegram":
        iconData = TablerIcons.brand_telegram;
        return iconData;
      case "reddit":
        iconData = TablerIcons.brand_reddit;
        return iconData;
      case "tiktok":
        iconData = TablerIcons.brand_tiktok;
        return iconData;
      case "github":
        iconData = TablerIcons.brand_github;
        return iconData;
      case "discord":
        iconData = TablerIcons.brand_discord;
        return iconData;
      // case "thread":
      //    iconData = TablerIcons.brand_;
      //   return iconData;
      default:
        // Handle unknown cases or provide a default icon
        break;
    }
  }

  IconData? getIcons(String icon) {
    switch (icon) {
      case "&#xec74;":
        return TablerIcons.brand_whatsapp;
      case "&#xec20;":
        return TablerIcons.brand_instagram;
      case "&#xec1a;":
        return TablerIcons.brand_facebook;
      case "&#xec8c;":
        return TablerIcons.brand_linkedin;
      case "&#xec26;":
        return TablerIcons.brand_telegram;
      case "&#xeae5;":
        return TablerIcons.mail;
      case "&#xec25;":
        return TablerIcons.brand_snapchat;
      case "&#xec1c;":
        return TablerIcons.brand_github;
      case "&#xf7e7;":
        return TablerIcons.brand_github_filled;
      case "brand-youtube":
        return TablerIcons.brand_youtube;
      default:
    }
  }

  void openWhatsApp(String text) async {
    final url = text;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void redirectToPlayStore() async {
    // Create the Play Store deep link URL
    final String url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.newspepper.app'
        : allMessages.value.rateUsIos.toString();

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

Color generateRandomColor() {
  Random random = Random();
  int r = random.nextInt(256);
  int g = random.nextInt(256);
  int b = random.nextInt(256);
  return Color.fromRGBO(r, g, b, 1);
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    this.onTap,
    this.radius,
    this.size,
  });
  final VoidCallback? onTap;
  final double? radius, size;

  @override
  Widget build(BuildContext context) {
    return TapInk(
      onTap: currentUser.value.id == null
          ? onTap ??
              () {
                Navigator.pushNamed(context, '/LoginPage');
              }
          : onTap ??
              () {
                Navigator.pushNamed(context, '/UserProfile');
              },
      child: currentUser.value.id != null && currentUser.value.photo != ''
          ? CircleAvatar(
              radius: radius ?? 35,
              backgroundImage:
                  CachedNetworkImageProvider(currentUser.value.photo),
            )
          : currentUser.value.id != null
              ? CircleAvatar(
                  radius: radius ?? 35,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                  child: Text(
                      currentUser.value.name != ''
                          ? currentUser.value.name!.split(' ').first[0]
                          : 'G',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: size ?? 28,
                          color: isBlack(Theme.of(context).primaryColor)
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600)),
                )
              : CircleAvatar(
                  radius: radius ?? 35,
                  backgroundImage: CachedNetworkImageProvider(
                      "${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}")),
    );
  }
}

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    super.key,
    required this.isON,
  });

  final bool isON;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      width: 44,
      height: 24,
      alignment: isON == false ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isON
              ? dark(context)
                  ? darkPrimaryGradient(context)
                  : primaryGradient(context)
              : null,
          color: isON
              ? dark(context)
                  ? Colors.black
                  : Colors.white
              : dark(context)
                  ? Colors.black.withOpacity(0.4)
                  : ColorUtil.lightGrey),
      child: const CircleAvatar(backgroundColor: ColorUtil.white, radius: 9),
    );
  }
}

class DrawWrap extends StatelessWidget {
  const DrawWrap({
    super.key,
    this.title,
    required this.onTap,
    this.image,
    this.pos = 1,
    this.suffix,
  });

  final String? title, image;
  final VoidCallback onTap;
  final int pos;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return AnimationFadeSlide(
      dx: 0.4,
      duration: 130 * pos,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: dark(context)
                      ? Theme.of(context).cardColor
                      : ColorUtil.whiteGrey),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12.5),
              child: Row(
                children: [
                  image == ''
                      ? const SizedBox()
                      : SvgPicture.asset(
                          image ?? SvgImg.dash,
                          width: 24,
                          height: 24,
                          color: dark(context)
                              ? ColorUtil.white
                              : ColorUtil.textblack,
                        ),
                  image == '' ? const SizedBox() : const SizedBox(width: 15),
                  Text(title ?? 'data',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  image == '' ? const Spacer() : const SizedBox(),
                  suffix ?? const SizedBox()
                ],
              ),
            ),
            Positioned.fill(
                child: TapInk(
                    onTap: onTap,
                    splash: Theme.of(context).primaryColor,
                    radius: 50,
                    child: const SizedBox()))
          ],
        ),
      ),
    );
  }
}
