import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:virtual_keyboard_deep/screens/common/components/app_bar.dart';
import 'package:virtual_keyboard_deep/screens/home_screen/main_page.dart';
import 'package:virtual_keyboard_deep/utils/SizeConfig.dart';
import 'package:virtual_keyboard_deep/utils/my_print.dart';
import 'package:virtual_keyboard_deep/utils/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirst = true, pageMounted = false;
  late DatabaseReference _deviceRef;
  late StreamSubscription<DatabaseEvent> _deviceSubscription;

  bool status = false;
  String text = "";
  String pin = "";

  Future<void> initSync() async {
    _deviceRef = FirebaseDatabase.instance.ref('device');

    _deviceSubscription = _deviceRef.onValue.listen((DatabaseEvent event) {
      print("Value:${event.snapshot.value}");
      try {
        Map<String, dynamic> map = Map.castFrom(event.snapshot.value as Map);
        text = map['data'] ?? "";
        status = (map['status'] ?? "") == "on" ? true : false;
        if(pageMounted) setState(() {});
      }
      catch(e) {

      }
    });
  }

  void changePin() {
    pin = "";
    for(int i = 0; i < 3; i++) {
      int num = Random().nextInt(10);
      pin += num.toString();
    }
    FirebaseDatabase.instance.ref('pin').set(pin);
  }

  @override
  void initState() {
    initSync();
    super.initState();
    changePin();
  }

  @override
  Widget build(BuildContext context) {
    pageMounted = false;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      pageMounted = true;
    });

    if(isFirst) {
      isFirst = false;
    }

    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "Virtual Keyboard", backbtnVisible: false, color: Colors.white,),
              Expanded(
                child: getMainBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget getMainBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size10!, vertical: MySize.size5!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: getMainText(text)),
          const SizedBox(height: 20,),
          getOnOffSwitch(),
          const SizedBox(height: 30,),
          Visibility(
            visible: status,
            child: Text("Pin:${pin}", textAlign: TextAlign.center, style: TextStyle(fontSize: 24),),
          ),
          const SizedBox(height: 50,),
        ],
      ),
    );
  }
  
  Widget getMainText(String text) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size10!),
        border: Border.all(color: Styles.primaryColor, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget getOnOffSwitch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Switch(value: status, onChanged: (bool? newValue) {
          print("On Changed Called:${newValue}");
          if(newValue ?? false) {
            changePin();
          }
          _deviceRef.update({"status" : (newValue ?? false) ? "on" : "off"});
        }),
        SizedBox(width: MySize.size10!,),
        Text(status ? "On" : "Off", style: const TextStyle(color: Colors.black),)
      ],
    );
  }
}
