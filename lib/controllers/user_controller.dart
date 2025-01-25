import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:virtual_keyboard_deep/controllers/firestore_controller.dart';
import 'package:virtual_keyboard_deep/controllers/providers/user_provider.dart';
import 'package:virtual_keyboard_deep/models/user_model.dart';
import 'package:virtual_keyboard_deep/utils/my_print.dart';
import 'package:provider/provider.dart';

class UserController {
  static UserController? _instance;

  StreamSubscription? streamSubscription;

  factory UserController() {
    _instance ??= UserController._();
    return _instance!;
  }

  UserController._();

  Future<bool> isUserExist(BuildContext context, String uid) async {
    if(uid.isEmpty) return false;

    MyPrint.printOnConsole("Uid:${uid}");
    if(uid == null || uid.isEmpty) return false;

    bool isUserExist = false;

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirestoreController().firestore.collection('users').doc(uid).get();

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      if(documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
        UserModel userModel = UserModel.fromMap(documentSnapshot.data()!);
        userProvider.userModel = userModel;
        MyPrint.printOnConsole("User Model:${userProvider.userModel}");
        isUserExist = true;
      }
      else {
        UserModel userModel = UserModel();
        userModel.id = uid;
        userModel.name = userProvider.firebaseUser?.displayName ?? "";
        userModel.mobile = userProvider.firebaseUser?.phoneNumber ?? "";
        userModel.email = userProvider.firebaseUser?.email ?? "";
        userModel.image = userProvider.firebaseUser?.photoURL ?? "";
        userModel.createdTime = Timestamp.now();
        bool isSuccess = await UserController().createUser(context, userModel);
        MyPrint.printOnConsole("Insert Client Success:${isSuccess}");
      }
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.isClientExist:${e}");
    }

    return isUserExist;
  }

  Future<bool> createUser(BuildContext context,UserModel userModel) async {
    try {
      /*Map<String, dynamic> data = {
        "ClientId" : clientModel.ClientId,
      };*/
      //if(clientModel.ClientPhoneNo.isNotEmpty) data['ClientPhoneNo'] = clientModel.ClientPhoneNo;
      //if(clientModel.ClientEmailId.isNotEmpty) data['ClientEmailId'] = clientModel.ClientEmailId;
      //data.remove("ClientId");
      Map<String, dynamic> data = userModel.tomap();

      await FirestoreController().firestore.collection("users").doc(userModel.id).set(data);

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userModel = userModel;

      return true;
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.insertClient:${e}");
    }

    return false;
  }

  Future<void> fetchImageDecodeImageAndStoreInFirestore() async {
    if(streamSubscription != null) {
      await streamSubscription!.cancel();
      streamSubscription = null;
    }

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref("decoding");

    streamSubscription = databaseReference.onValue.listen((event) async {
      MyPrint.printOnConsole("Doc1 Snapshot:${event.snapshot.value}");

      Map<String, dynamic> map = {};

      try {
        map = Map.castFrom((event.snapshot.value as Map?) ?? {});
      }
      catch(e, s) {
        MyPrint.printOnConsole("Error in Converting From Object To Map:${e}");
        MyPrint.printOnConsole(s);
      }

      MyPrint.printOnConsole("Map:${map}");
      if(map.isNotEmpty) {
        String imageUrl = "";
        if(map['image_url']?.toString().isNotEmpty ?? false) {
          imageUrl = map['image_url'].toString();
        }
        MyPrint.printOnConsole("ImageUrl:${imageUrl}");

        if(imageUrl.isNotEmpty) {
          try {
            Uri? uri = Uri.tryParse(imageUrl);
            if(uri != null) {
              MyPrint.printOnConsole("Uri is Not Null");
              Response response = await get(uri);

              MyPrint.printOnConsole("Image Data:${response.bodyBytes}");

              if(response.bodyBytes.isNotEmpty) {
                Directory? directory = await getExternalStorageDirectory();
                MyPrint.printOnConsole("Storage Directory:${directory}");
                if(directory != null) {
                  File file = File(directory.path + "/image.png");
                  file = await file.create();
                  await file.writeAsBytes(response.bodyBytes.toList());

                  String decodedText = await _delectText(file);
                  MyPrint.printOnConsole("Decoded Text Length:${decodedText.length}, Text:${decodedText}");
                  if(decodedText.length >= 15) {
                    //await documentReference.update({"detected_text" : decodedText, "image_url" : ""});
                    await databaseReference.set({"detected_text" : decodedText, "image_url" : ""});
                  }
                }
              }
            }
          }
          catch(e, s) {
            MyPrint.printOnConsole("Error in Fetching Image Data in UserController().fetchImageDecodeImageAndStoreInFirestore():${e}");
            MyPrint.printOnConsole(s);
          }
        }
      }
    });
  }

  Future<String> _delectText(File file) async {
    try {
      GoogleVisionImage visionImage = GoogleVisionImage.fromFile(file);

      final TextRecognizer textRecognizer = GoogleVision.instance.textRecognizer();
      final VisionText visionText = await textRecognizer.processImage(visionImage);
      String? text = visionText.text;
      if(text==null) {
        MyPrint.printOnConsole("No text found");
      }
      else {
        String text = "";

        for (TextBlock block in visionText.blocks) {
          for (TextLine line in block.lines) {
            MyPrint.printOnConsole("line : ${line.text}");
            for (TextElement element in line.elements) {
              MyPrint.printOnConsole("B : ${element.text}");
              String decodedText = (element.text ?? "").trim();
              String newText = "";
              for(int i = 0; i < decodedText.length; i++) {
                int asciiValue = decodedText[i].isNotEmpty ? decodedText[i].codeUnitAt(0) : -1;
                MyPrint.printOnConsole("Ascii Value for '${decodedText[i]}' is $asciiValue");
                if((asciiValue > 47 && asciiValue < 58) || (asciiValue > 64 && asciiValue < 91) || (asciiValue > 96 && asciiValue < 123)) {
                  newText += decodedText[i];
                }
              }
              text += newText;
            }
          }
        }

        return text;
      }

      return '';
    }
    catch (e, s) {
      print("Error in _checkFaceInFile in UserProfile3 : $e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }
}