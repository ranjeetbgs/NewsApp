import 'package:flutter/material.dart';
import 'package:incite/api_controller/repository.dart';
import 'package:incite/pages/setting/widgets/setting_wrap.dart';
import 'package:incite/utils/nav_util.dart';
import 'package:incite/widgets/app_bar.dart';
import '../../api_controller/user_controller.dart';
import '../../model/home.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_util.dart';
import '../cms.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  UserProvider userProvider = UserProvider();

  List<HomeModel> settings = [
 HomeModel(
  title: allMessages.value.notifications ?? 'Notification',
  subtitle: allMessages.value.enableDisablePushNotification ??'Enable Disable Push notification',
  image: SvgImg.noti,
  isToggle: true
 ),
 HomeModel(
  title: allMessages.value.selectLanguage ?? 'Select Language',
  subtitle:allMessages.value.selectLanguageSubitle ?? 'Select your preferred language',
  image: SvgImg.lang
 ),
  HomeModel(
  title: allMessages.value.blogFontSize ?? 'Font Size',
  image: SvgImg.font
 )
];


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CommonAppbar(title:allMessages.value.settingsPage ??'Settings Page'),
         const SliverToBoxAdapter(
          child: SizedBox(height:30),
         ),
         SliverPadding(
           padding: const EdgeInsets.only(bottom: 0,left: 24,right: 24),
           sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                 ...List.generate(settings.length, (index) => index == 2 ? 
                 Builder(
                   builder: (context) {
                     return FontWrap(
                      pos: 2,
                      model: settings[index],
                     );
                   }
                 )  : ValueListenableBuilder(
                  valueListenable: appThemeModel.value.isNotificationEnabled,
                   builder: (context,value,child) {
                     return ListSettingWrap(
                      pos: index+4,
                      model: settings[index],
                      isOn:value,
                      onTap: () {
                      switch (index) {
                        case 0: {
                           if(currentUser.value.id == null ){
                             currentUser.value.deviceToken = getOnesignalUserId();
                             setState(() {  });
                           }
                           toggleNotify(!appThemeModel.value.isNotificationEnabled.value);
                           updateToken(currentUser.value,getOnesignalUserId().toString());
                           setState(() { });
                        }
                        break; 
                        case 1:
                           Navigator.pushNamed(context,'/LanguageSelection',arguments:true );
                        break; 
                        default:
                      }
                      },
                     );
                   }
                 ))
              ],
            ),
           ),
         ),
           SliverPadding(
           padding: const EdgeInsets.only(top: 10),
           sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                 ...List.generate(allCMS.length, (index) => RowDot(
                 pos: index+1,
                 title: allCMS[index].title,
                  onTap: () {
                      Navigator.push(context,
                      PagingTransform(widget: CmsPage(
                        cms: allCMS[index],
                      )));
                  },
                 ))
              ],
            ),
           ),
         ),
        ],
      ),
    );
  }
}