import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:scv_app/prijava.dart';
import 'package:scv_app/uvod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data.dart';
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
        body: Center(
          child: ElevatedButton(onPressed: (() => Navigator.pop(context)),child: Icon(Icons.arrow_back_ios),),
        )
    );
  }
}
