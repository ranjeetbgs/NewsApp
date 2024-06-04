import 'package:flutter/material.dart';

class AppModel {
  ValueNotifier<bool> isDarkModeEnabled = ValueNotifier(false);
  ValueNotifier<bool> isUserLoggedIn = ValueNotifier(false);
  ValueNotifier<bool> isNotificationEnabled = ValueNotifier(true);
  AppModel();

  AppModel.fromMap(Map data) {

    isDarkModeEnabled.value = data['isDarkModeEnabled'] as bool;
    isUserLoggedIn.value = data['isUserLoggedIn'] as bool;
    isNotificationEnabled.value = data['is_notification_enabled'] as bool;
  }

  Map toMap() {
    return {
      'isDarkModeEnabled': isDarkModeEnabled.value,
      'isUserLoggedIn': isUserLoggedIn.value,
      'is_notification_enabled' : isNotificationEnabled.value
    };
  }
}
