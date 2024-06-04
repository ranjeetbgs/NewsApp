class SettingModel {
  String? homepageTheme;
  String? layout;
  String? googleAnalyticsCode;
  String? appName;
  String? baseImageUrl;
  String? bundleIdAndroid;
  String? bundleIdIos;
  String? isAppForceUpdate;
  String? appLogo;
  String? appSplashScreen;
  String? siteTitle;
  String? enableNotifications;
  String? firebaseMsgKey;
  String? primaryColor;
  String? firebaseApiKey;
  String? fromName;
  String? enableMaintainanceMode;
  String? maintainanceTitle;
  String? maintainanceShortText;
  String? pushNotificationEnabled;
  String? dateFormat;
  String? timezone;
  String? blogAccentCode;
  String? liveNewsLogo;
  String? liveNewsStatus;
  String? ePaperLogo;
  String? ePaperStatus;
  String? enableAds;
  String? admobBannerIdAndroid;
  String? admobInterstitialIdAndroid;
  String? admobBannerIdIos;
  String? admobInterstitialIdIos;
  String? fbInterstitialIdIos;
  String? fbInterstitialIdAndroid;
  String? admobFrequency;
  String? enableFbAds;
  String? fbAdsPlacementIdAndroid;
  String? fbAdsPlacementIdIos;
  String? fbAdsAppToken;
  String? fbAdsFrequency;
  String? blogLanguage;
  String? blogAccent;
  String? blogVoice;
  String? rectangualrAppLogo;
  String? signingKeyAndroid;
  String? keyPropertyAndroid;
  String? oneSignalKey;
  String? googleApikey;
  String? secondaryColor;
  bool? isVoiceEnabled;

  SettingModel(
      {this.homepageTheme,
      this.layout,
      this.googleAnalyticsCode,
      this.appName,
      this.bundleIdAndroid,
      this.bundleIdIos,
      this.isAppForceUpdate,
      this.appLogo,
      this.secondaryColor,
      this.appSplashScreen,
      this.isVoiceEnabled=true,
      this.googleApikey,
      this.siteTitle,
      this.enableNotifications,
      this.firebaseMsgKey,
      this.firebaseApiKey,
      this.fbInterstitialIdAndroid,
      this.fbInterstitialIdIos,
      this.baseImageUrl,
      this.fromName,
      this.enableMaintainanceMode,
      this.maintainanceTitle,
      this.maintainanceShortText,
      this.pushNotificationEnabled,
      this.dateFormat,
      this.timezone,
      this.blogAccentCode,
      this.liveNewsLogo,
      this.liveNewsStatus,
      this.ePaperLogo,
      this.ePaperStatus,
      this.enableAds,
      this.admobBannerIdAndroid,
      this.admobInterstitialIdAndroid,
      this.admobBannerIdIos,
      this.admobInterstitialIdIos,
      this.admobFrequency,
      this.enableFbAds,
      this.fbAdsPlacementIdAndroid,
      this.fbAdsPlacementIdIos,
      this.fbAdsAppToken,
      this.fbAdsFrequency,
      this.blogLanguage,
      this.blogAccent,
      this.blogVoice,
      this.rectangualrAppLogo,
      this.signingKeyAndroid,
      this.oneSignalKey='4e94725e-4369-4386-bf67-b9c16ad99abe',
      this.keyPropertyAndroid});

  SettingModel.fromJson(Map<String, dynamic> json) {
    homepageTheme = json['homepage_theme'];
    layout = json['layout'];
    googleAnalyticsCode = json['google_analytics_code'];
    appName = json['app_name'];
    bundleIdAndroid = json['bundle_id_android'];
    bundleIdIos = json['bundle_id_ios'];
    secondaryColor = json['secondary_color'];
    baseImageUrl = json['base_url'];
    isAppForceUpdate = json['is_app_force_update'];
    appLogo = json['app_logo'];
    appSplashScreen = json['app_splash_screen'];
    fbInterstitialIdAndroid = json['fb_ads_interstitial_id_android'];
    fbInterstitialIdIos = json['fb_ads_interstitial_id_android'];
    siteTitle = json['site_title'];
    isVoiceEnabled = json['is_voice_enabled']== '0' ? false : true;
    googleApikey = json['google_api_key'];
    enableNotifications = json['enable_notifications'];
    firebaseMsgKey = json['firebase_msg_key'];
    firebaseApiKey = json['firebase_api_key'];
    fromName = json['from_name'];
    primaryColor = json['primary_color'];
    enableMaintainanceMode = json['enable_maintainance_mode'];
    maintainanceTitle = json['maintainance_title'];
    maintainanceShortText = json['maintainance_short_text'];
    pushNotificationEnabled = json['push_notification_enabled'];
    dateFormat = json['date_format'];
    timezone = json['timezone'];
    blogAccentCode = json['blog_accent_code'];
    liveNewsLogo = json['live_news_logo'];
    liveNewsStatus = json['live_news_status'];
    ePaperLogo = json['e_paper_logo'];
    ePaperStatus = json['e_paper_status'];
    enableAds = json['enable_ads'];
    admobBannerIdAndroid = json['admob_banner_id_android'];
    admobInterstitialIdAndroid = json['admob_interstitial_id_android'];
    admobBannerIdIos = json['admob_banner_id_ios'];
    admobInterstitialIdIos = json['admob_interstitial_id_ios'];
    admobFrequency = json['admob_frequency'];
    enableFbAds = json['enable_fb_ads'];
    fbAdsPlacementIdAndroid = json['fb_ads_placement_id_android'];
    fbAdsPlacementIdIos = json['fb_ads_placement_id_ios'];
    fbAdsAppToken = json['fb_ads_app_token'];
    oneSignalKey = json['one_signal_app_id'];
    fbAdsFrequency = json['fb_ads_frequency'];
    blogLanguage = json['blog_language'];
    blogAccent = json['blog_accent'];
    blogVoice = json['blog_voice'];
    rectangualrAppLogo = json['rectangualr_app_logo'];
    signingKeyAndroid = json['signing_key_android'];
    keyPropertyAndroid = json['key_property_android'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['homepage_theme'] = homepageTheme;
    data['layout'] = layout;
    data['google_analytics_code'] = googleAnalyticsCode;
    data['app_name'] = appName;
    data['bundle_id_android'] = bundleIdAndroid;
    data['bundle_id_ios'] = bundleIdIos;
    data['is_app_force_update'] = isAppForceUpdate;
    data['app_logo'] = appLogo;
    data['app_splash_screen'] = appSplashScreen;
    data['site_title'] = siteTitle;
    data['enable_notifications'] = enableNotifications;
    data['firebase_msg_key'] = firebaseMsgKey;
    data['firebase_api_key'] = firebaseApiKey;
    data['from_name'] = fromName;
    data['enable_maintainance_mode'] = enableMaintainanceMode;
    data['maintainance_title'] = maintainanceTitle;
    data['maintainance_short_text'] = maintainanceShortText;
    data['push_notification_enabled'] = pushNotificationEnabled;
    data['date_format'] = dateFormat;
    data['timezone'] = timezone;
    data['blog_accent_code'] = blogAccentCode;
    data['live_news_logo'] = liveNewsLogo;
    data['live_news_status'] = liveNewsStatus;
    data['e_paper_logo'] = ePaperLogo;
    data['e_paper_status'] = ePaperStatus;
    data['enable_ads'] = enableAds;
    data['admob_banner_id_android'] = admobBannerIdAndroid;
    data['admob_interstitial_id_android'] = admobInterstitialIdAndroid;
    data['admob_banner_id_ios'] = admobBannerIdIos;
    data['admob_interstitial_id_ios'] = admobInterstitialIdIos;
    data['admob_frequency'] = admobFrequency;
    data['enable_fb_ads'] = enableFbAds;
    data['fb_ads_placement_id_android'] = fbAdsPlacementIdAndroid;
    data['fb_ads_placement_id_ios'] = fbAdsPlacementIdIos;
    data['fb_ads_app_token'] = fbAdsAppToken;
    data['fb_ads_frequency'] = fbAdsFrequency;
    data['blog_language'] = blogLanguage;
    data['blog_accent'] = blogAccent;
    data['blog_voice'] = blogVoice;
    data['rectangualr_app_logo'] = rectangualrAppLogo;
    data['signing_key_android'] = signingKeyAndroid;
    data['key_property_android'] = keyPropertyAndroid;
    return data;
  }
}