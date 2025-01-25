import 'package:flutter/material.dart';
import 'package:virtual_keyboard_deep/screens/common/components/app_bar.dart';
import 'package:virtual_keyboard_deep/utils/styles.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = "/CreatePostScreen";

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "Create Post", backbtnVisible: true, color: Colors.white,),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      getImageSelectionListWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageSelectionListWidget() {
    return Container();
  }
}
