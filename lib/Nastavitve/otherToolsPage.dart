import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:scv_app/Components/backBtn.dart';
import 'package:scv_app/Intro_And__Login/prijava.dart';
import 'package:scv_app/Intro_And__Login/uvod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/data.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:get/get.dart';


class OtherToolsPage extends StatefulWidget {
  OtherToolsPage({Key key, this.data}) : super(key: key);

  final Data data;

  _OtherToolsPage createState() => _OtherToolsPage();
}

class _OtherToolsPage extends State<OtherToolsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedPickerItem = 0;

  String token = "";

  @override
  void initState() {
    super.initState();
  }

  bool _value = true;
  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
        body: SafeArea(
          child: Column(
            
            children: [
              backButton(context),
              Container(
            width: 200,
            height: 300,
            child: Image.asset(
              'assets/Construction2.png',
            )),
              
              Text("Kmalu na voljo."),
            ],
          )
        )
    );
  }
}
