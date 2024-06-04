import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/model/lang.dart';
import 'package:incite/model/messages.dart';
import 'package:incite/model/settings.dart';
import '../model/cms.dart';
import '../splash_screen.dart';
import 'app_util.dart';
import 'color_util.dart';

//* <------------- App Theme [Theme Manager] ------------->

ValueNotifier<AppModel> appThemeModel = ValueNotifier(AppModel());

toggleDarkMode(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': value,
    'isUserLoggedIn': model.isUserLoggedIn.value,
    'is_notification_enabled': model.isNotificationEnabled.value,
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

toggleSignInOut(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': model.isDarkModeEnabled.value,
    'isUserLoggedIn': value,
    'is_notification_enabled': model.isNotificationEnabled.value,
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

toggleNotify(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': model.isDarkModeEnabled.value,
    'isUserLoggedIn': model.isUserLoggedIn.value,
    'is_notification_enabled': value,
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

saveDataToSharedPrefs(AppModel model) async {
  try {
    prefs?.setString('app_data', json.encode(model.toMap()));
    // ignore: empty_catches
  } catch (e) {}
}

getDataFromSharedPrefs() async {
  if (prefs!.containsKey('app_data')) {
    AppModel model =
        AppModel.fromMap(json.decode(prefs!.getString('app_data').toString()));
    appThemeModel.value = model;
  } else {
    // initializing app_data in sharedPreferences with default values
    saveDataToSharedPrefs(AppModel());
  }
}

getMessageAndSetting() {
  if (prefs!.containsKey('local_data')) {
    allMessages.value = Messages.fromJson(
        json.decode(prefs!.getString('local_data').toString()));
  }
  if (prefs!.containsKey('setting')) {
    allSettings.value = SettingModel.fromJson(
        json.decode(prefs!.getString('setting').toString()));
  }
  if (prefs!.containsKey('languages')) {
    allLanguages = [];
    json.decode(prefs!.getString("languages").toString()).forEach((lang) {
      allLanguages.add(Language.fromJson(lang));
    });
  }
  if (prefs!.containsKey('defalut_language')) {
    String lng = prefs!.getString("defalut_language").toString();
    languageCode.value = Language.fromJson(json.decode(lng));
  }
  if (prefs!.containsKey('OffAds')) {
    allCMS = [];
    final ads = prefs!.getString('OffAds').toString();
    json.decode(ads)['data'].forEach((language) {
      allCMS.add(CmsModel.fromJson(language));
    });
  }
}

//* ThemeData according to brightness i.e Dark or Light mode

ThemeData getLightThemeData(Color primary, Color secondary) {
  return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      primaryColor: primary,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      brightness: Brightness.light,
      dividerColor: Colors.grey.shade200,
      primaryIconTheme: const IconThemeData(color: Colors.black),
      textTheme: getLightTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
      ));
}

ThemeData getDarkThemeData(Color primary, Color secondary) {
  return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      primaryColor: primary,
      scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 1),
      brightness: Brightness.dark,
      appBarTheme:
          const AppBarTheme(backgroundColor: Color.fromARGB(255, 20, 19, 19)),
      cardColor: const Color.fromRGBO(40, 40, 40, 1),
      canvasColor: const Color.fromRGBO(10, 10, 10, 1),
      primaryIconTheme: const IconThemeData(color: Colors.white),
      textTheme: getDarkTextTheme(),
      colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
          brightness: Brightness.dark));
}

//* Text Themes according to brightness i.e Dark or Light mode

TextTheme getLightTextTheme() {
  return const TextTheme(
    displayLarge: TextStyle(
        fontFamily: 'Roboto', fontSize: 30, color: ColorUtil.textblack),
    displayMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 28,
        color: ColorUtil.textblack,
        fontWeight: FontWeight.w700),
    displaySmall: TextStyle(
        color: ColorUtil.textblack, fontFamily: 'Roboto', fontSize: 17),
    headlineMedium: TextStyle(
        fontFamily: 'Roboto', fontSize: 12, color: ColorUtil.textblack),
    titleLarge: TextStyle(
        fontFamily: 'Roboto', fontSize: 14, color: ColorUtil.textblack),
    titleMedium: TextStyle(
        color: ColorUtil.textblack, fontFamily: 'Roboto', fontSize: 12),
    bodyLarge: TextStyle(
        fontWeight: FontWeight.w500, fontFamily: 'Roboto', fontSize: 15),
    bodyMedium: TextStyle(
        fontFamily: 'Roboto', fontSize: 25, color: ColorUtil.textblack),
  );
}

TextTheme getDarkTextTheme() {
  return const TextTheme(
      displayLarge:
          TextStyle(fontFamily: 'Roboto', fontSize: 30, color: Colors.white),
      displayMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.w700),
      displaySmall:
          TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 17),
      headlineMedium:
          TextStyle(fontFamily: 'Roboto', fontSize: 12, color: Colors.white),
      titleLarge:
          TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Colors.white),
      titleMedium:
          TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 12),
      bodyLarge: TextStyle(
          fontWeight: FontWeight.w500, fontFamily: 'Roboto', fontSize: 15),
      bodyMedium:
          TextStyle(fontFamily: 'Roboto', fontSize: 25, color: Colors.white));
}
