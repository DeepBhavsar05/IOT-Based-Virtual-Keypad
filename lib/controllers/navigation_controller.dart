import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_keyboard_deep/screens/authentication/login_screen.dart';
import 'package:virtual_keyboard_deep/screens/home_screen/create_post_screen.dart';
import 'package:virtual_keyboard_deep/screens/home_screen/main_page.dart';
import 'package:virtual_keyboard_deep/splash_screen.dart';
import 'package:virtual_keyboard_deep/utils/my_print.dart';

class NavigationController {
  Route? onGeneratedRoutes(RouteSettings routeSettings) {
    MyPrint.printOnConsole("OnGeneratedRoutes Called for ${routeSettings.name} with arguments:${routeSettings.arguments}");

    Widget? widget;

    switch(routeSettings.name) {
      case SplashScreen.routeName : {
        widget = const SplashScreen();
        break;
      }
      case LoginScreen.routeName : {
        widget = const LoginScreen();
        break;
      }
      case MainPage.routeName : {
        widget = const MainPage();
        break;
      }
      case CreatePostScreen.routeName : {
        widget = const CreatePostScreen();
        break;
      }
      default : {
        widget = const SplashScreen();
      }
    }

    if(widget != null)return MaterialPageRoute(builder: (_) => widget!);
  }
}