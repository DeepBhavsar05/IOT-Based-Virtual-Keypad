import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:virtual_keyboard_deep/controllers/authentication_controller.dart';
import 'package:virtual_keyboard_deep/controllers/providers/connection_provider.dart';
import 'package:virtual_keyboard_deep/controllers/providers/user_provider.dart';
import 'package:virtual_keyboard_deep/controllers/user_controller.dart';
import 'package:virtual_keyboard_deep/screens/authentication/login_screen.dart';
import 'package:virtual_keyboard_deep/screens/home_screen/main_page.dart';
import 'package:virtual_keyboard_deep/utils/SizeConfig.dart';
import 'package:virtual_keyboard_deep/utils/my_print.dart';
import 'package:virtual_keyboard_deep/utils/styles.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirst = true;

  void startListeners() async {
    MyPrint.printOnConsole("Start Listener Called");

    DateTime startTime = DateTime.now();

    int count = 0;
    Function whenComplete = () => count++;



    /*while(count < 5) {
      await Future.delayed(Duration(milliseconds: 100));
    }*/

    DateTime endTime = DateTime.now();
    MyPrint.printOnConsole("Data Got in ${endTime.difference(startTime).inMilliseconds} Milliseconds");

    //await Future.delayed(Duration(seconds: 3));
    if(await AuthenticationController().isUserLogin(context: context, initializeUserid: true)) {
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

      bool isExist = await UserController().isUserExist(context, userProvider.userid);
      MyPrint.printOnConsole("IsUserExist:${isExist}");

      Navigator.pushNamedAndRemoveUntil(context, MainPage.routeName, (route) => false);
    }
    else {
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("isInternet:${Provider.of<ConnectionProvider>(context).isInternet}");
    if(Provider.of<ConnectionProvider>(context).isInternet && isFirst) {
      isFirst = false;

      MySize().init(context);
      startListeners();
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset("assets/logo.png",width: MySize.getScaledSizeHeight(200)),
            ),
          ),
          SpinKitThreeBounce(size: 30, color: Provider.of<ConnectionProvider>(context).isInternet? Styles.primaryColor : Colors.red,),
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(10.0),
              child: const Text("Made In India.",style: TextStyle(fontSize: 11), textAlign: TextAlign.center,),
            ),
          ),
        ],
      ),
    );
  }
}
