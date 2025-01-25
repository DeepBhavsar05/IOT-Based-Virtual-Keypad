import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:virtual_keyboard_deep/controllers/authentication_controller.dart';
import 'package:virtual_keyboard_deep/controllers/providers/user_provider.dart';
import 'package:virtual_keyboard_deep/controllers/user_controller.dart';
import 'package:virtual_keyboard_deep/screens/common/components/modal_progress_hud.dart';
import 'package:virtual_keyboard_deep/screens/home_screen/main_page.dart';
import 'package:virtual_keyboard_deep/utils/SizeConfig.dart';
import 'package:virtual_keyboard_deep/utils/my_print.dart';
import 'package:virtual_keyboard_deep/utils/styles.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginScreen";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isFirst = true, isLoading = false;

  void signInWithGoogle() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    User? user = await AuthenticationController().signInWithGoogle(context);

    if (user != null) {
      onSuccess(user);
    }
    else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> onSuccess(User user) async {
    MyPrint.printOnConsole("Login Screen OnSuccess called");

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.userid = user.uid;
    userProvider.firebaseUser = user;

    MyPrint.printOnConsole("Email:${user.email}");
    MyPrint.printOnConsole("Mobile:${user.phoneNumber}");

    bool isExist = await UserController().isUserExist(context, userProvider.userid);

    setState(() {
      isLoading = false;
    });

    print("User Exist");
    Navigator.pushNamedAndRemoveUntil(context, MainPage.routeName, (route) => false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    MyPrint.printOnConsole("LoginScreen called");

    MySize().init(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      color: Colors.black,
      progressIndicator: Container(
        padding: EdgeInsets.all(MySize.size100!),
        child: Center(
          child: Container(
            height: MySize.size90,
            width: MySize.size90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MySize.size10!),
              color: Colors.white,
            ),
            child: SpinKitFadingCircle(color: Styles.primaryColor,),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(top: 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        getLogo(),
                        getLoginText(),
                        getLoginWithGoogleButton(),
                        //getTermsAndConditionsLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Container(
      margin: EdgeInsets.only(bottom: MySize.size0!),
      width: MySize.getScaledSizeHeight(200),
      height: MySize.getScaledSizeHeight(120),
      child: Image.asset("assets/logo.png", fit: BoxFit.cover),
    );
  }

  Widget getLoginText() {
    return InkWell(
      onTap: ()async{

      },
      child: Container(
        margin: EdgeInsets.only(left: MySize.size16!, right: MySize.size16!),
        child: Center(
          child: Text(
            "Log In",
            style: TextStyle(
              fontSize: MySize.size26!,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget getTermsAndConditionsLink() {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        margin: EdgeInsets.only(top: MySize.size16!),
        child: Center(
          child: Text(
            "Terms and Conditions",
            style: TextStyle(
                decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  Widget getLoginWithGoogleButton() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size24!, right: MySize.size24!, top: MySize.size36!),
      child: InkWell(
        onTap: signInWithGoogle,
        child: Container(
          decoration: BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.circular(MySize.size10!),
            boxShadow: [
              BoxShadow(
                color: Styles.primaryColor.withAlpha(100),
                blurRadius: 5,
                offset: Offset(
                    0, 5), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(MySize.size8!),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MySize.size10!,),
                  color: Colors.white,
                ),
                child: Image.asset("assets/google logo.png", width: MySize.size30, height: MySize.size30,),
              ),
              Expanded(
                child: Text(
                  "Sign in With Google",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
