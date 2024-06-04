import 'package:flutter/cupertino.dart';
import 'package:incite/main.dart';
import 'package:incite/pages/auth/forgot_password.dart';
import 'package:incite/pages/auth/otp.dart';
import 'package:incite/pages/auth/reset_password.dart';
import 'package:incite/pages/auth/signup.dart';
import 'package:incite/pages/e_news.dart';
import 'package:incite/pages/interests/save_insterests.dart';
import 'package:incite/pages/main/blog_wrap.dart';
import 'package:incite/pages/main/web_view.dart';
import 'package:incite/utils/nav_util.dart';

import '../pages/auth/login.dart';
import '../pages/bookmark/bookmark.dart';
import '../pages/language/language_select.dart';
import '../pages/main/blog.dart';
import '../pages/main/dashboard.dart';
import '../pages/main/live_news.dart';
import '../pages/main/widgets/blog_ad.dart';
import '../pages/profile/user_profile.dart';
import '../pages/search/search_page.dart';
import '../pages/setting/settings.dart';
import '../splash_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    dynamic args = settings.arguments;
    switch (settings.name) {
      case '/SplashScreen':
        return PagingTransform(widget: const SplashScreen());
      case '/SignUpPage':
        return PagingTransform(widget: const SignUpPage());
      case '/LanguageSelection':
        return PagingTransform(
          widget: LanguagePage(isSetting: args ?? false),
        );
      case '/MainPage':
        return PagingTransform(
            widget:
                DashboardPage(index: args != null && args is int ? args : 0));
      case '/SaveInterests':
        return PagingTransform(widget: SaveInterest(isDrawer: args));
      case '/ReadBlog':
        return PagingTransform(
            widget: BlogPage(
          model: args[0],
          currIndex: 0,
          onTap: args[1],
          isSingle: args.length > 2 ? args[2] : false,
        ));
      // case '/BlogWrap':
      // return PagingTransform(widget: BlogWrapPage());
      case '/LoginPage':
        return PagingTransform(widget: const LoginPage());
      case '/UserProfile':
        return PagingTransform(
            widget: UserProfile(
          isDash: args ?? false,
        ));
      case '/weburl':
        return PagingTransform(widget: CustomWebView(url: args));
      case '/OTP':
        return PagingTransform(widget: OtpScreen(mail: args));
      case '/SearchPage':
        return PagingTransform(widget: const SearchPage());
      case '/SettingPage':
        return PagingTransform(widget: const SettingPage());
      case '/SavedPage':
        return PagingTransform(widget: const BookmarkPage());
      case '/ResetPage':
        return PagingTransform(
            widget: ResetPassword(isChange: args[0], mail: args[1]));
      case '/BlogWrap':
        return CupertinoPageRoute(
            builder: (context) => BlogWrapPage(
                key: ValueKey(args.length > 3 ? args[3] : 0),
                index: args[0],
                onChanged: (value) {},
                isBookmark: args[1],
                type: args.length > 4 ? args[4] : null,
                preloadPageController: args[2],
                isBack: args.length > 5 ? args[5] : false));
      case '/ForgotPage':
        return PagingTransform(widget: const ForgotPassword());
      case '/LiveNews':
        return PagingTransform(widget: const LiveNews());
      case '/GetStarted':
        return PagingTransform(widget: const GetStarted());
      case '/ENews':
        return PagingTransform(widget: const EnewsPage());
      case '/Ads':
        return PagingTransform(
            widget: BlogAd(
          onTap: () {},
        ));

      default:
        //? in case no route has been specified [for safety]
        return null;
    }
  }
}
