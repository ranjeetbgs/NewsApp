import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../model/blog.dart';
import '../splash_screen.dart';
import '../urls/url.dart';
import 'package:http/http.dart' as http;

class NavigateUtil extends NavigatorObserver {
  final Set<String> restrictedRoutes = {'/UserProfile'};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) async{
  
    super.didPush(route, previousRoute);
      final List<Page> routes = route.navigator!.widget.pages;

      //  debugPrint(routes.toString());
      //  debugPrint("//////===============routes.toString=========/////////");
      //  debugPrint(route.settings.name);
       var arguments = route.settings.arguments ;
      //final arguments['productId'];

      if (prefs!.containsKey('data')) {
          
      // print('settings Name');
      // print(route.settings.name);

      // print('Arguments Name');
      // print(arguments);
      
      // try {
         
      //   var url = "${Urls.baseUrl}blog-detail/${prefs!.getString('data')}";
  
      //   print('--------url------------');
      //    print('--------${url}------------');

      //   var result = await http.get(
      //     Uri.parse(url),
      //   );
      //   Map datas = await json.decode(result.body);

      //  // print(datas);
      //   if (datas['success'] == true) {
      //     final list = Blog.fromJson(datas['data'],isNotification: true);
      //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //         Navigator.pushNamedAndRemoveUntil(route.navigator!.context, '/MainPage',
      //         arguments:1,(route) => false);
      //         Navigator.pushNamedAndRemoveUntil(route.navigator!.context, '/ReadBlog',
      //         arguments:{
      //           list,
      //           (){
      //            // Navigator.pop(context);
      //           },
      //           true
      //         },(route) => false);
              
      //     });
      //   }
      
      // } on Exception catch (e) {

      // }

        // Navigator.pushNamedAndRemoveUntil(route.navigator!.context, '/ReadBlog',arguments: [
          
        // ],(route) => false);
       }

    // if (restrictedRoutes.contains(route.settings.name)) {
    //   final isLoggedIn = currentUser.value.id != null;// Check if the user is logged in
    //    if (!isLoggedIn) {
    //     debugPrint('Access denied. User is not logged in.');
    //     Navigator.pushNamed(route.navigator!.context,'/LoginPage');
    //        // Optionally, show a dialog or navigate to a login screen
    //   }
    // }
  }
}