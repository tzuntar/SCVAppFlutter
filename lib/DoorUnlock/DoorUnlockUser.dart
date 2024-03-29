import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scv_app/Components/CircleProgressBar.dart';
import 'package:scv_app/Components/backBtn.dart';
import 'package:scv_app/Data/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/data.dart';
import 'package:http/http.dart' as http;
import '../Intro_And__Login/prijava.dart';

class DoorUnlockUserPage extends StatefulWidget {
  DoorUnlockUserPage({Key key, this.data, this.url}) : super(key: key);

  final Data data;
  final String url;

  _DoorUnlockUserPage createState() => _DoorUnlockUserPage();
}

class _DoorUnlockUserPage extends State<DoorUnlockUserPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> procentageAnimation;

  @override
  void initState() {
    super.initState();
    checkUri();
    WidgetsBinding.instance.addObserver(this);
    this.controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    this.procentageAnimation =
        Tween<double>(begin: 0, end: 1).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ThemeColorForStatus themeColorForStatus = ThemeColorForStatus.unknown;
  bool isLoading = false;
  String doorCode = '';
  ScrollController scrollController = new ScrollController();

  String doorNameId = 'Ne obstaja';

  void checkUri() {
    if (isUrlForOpeinDoor(widget.url)) {
      this.doorCode =
          widget.url.replaceFirst("scvapp://app.scv.si/open_door/", "");
      if (doorCode != "" && doorCode != null) {
        this.unlockDoor();
        this.getDoorInfo();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      print("Not a valid url");
      Navigator.of(context).pop();
    }
  }

  void getDoorInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(keyForAccessToken);
    final respons = await http
        .get(Uri.parse("$apiUrl/pass/get_door/${this.doorCode}"), headers: {
      'Authorization': '$accessToken',
    });
    if (respons.statusCode == 200) {
      this.doorNameId = respons.body ?? this.doorNameId;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      this.closePage();
      this.closePage();
    }
  }

  unlockDoor() async {
    if (this.themeColorForStatus == ThemeColorForStatus.error ||
        this.themeColorForStatus == ThemeColorForStatus.success) {
      return;
    }
    setState(() {
      this.themeColorForStatus = ThemeColorForStatus.unknown;
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(keyForAccessToken);
    final respons = await http
        .get(Uri.parse("$apiUrl/pass/open_door/${this.doorCode}"), headers: {
      'Authorization': '$accessToken',
    });
    if (respons.statusCode == 200) {
      setState(() {
        this.themeColorForStatus = ThemeColorForStatus.success;
        isLoading = false;
      });
      this.controller.forward().whenComplete(() {
        setState(() {
          this.themeColorForStatus = ThemeColorForStatus.lock_status;
          this.controller.reset();
        });
      });
      return;
    } else {
      final body = jsonDecode(respons.body);
      final message = body["message"];
      if (message == "Door not found") {
        setState(() {
          themeColorForStatus = ThemeColorForStatus.error;
          isLoading = false;
        });
        ShowError(
            "Vrata niso bila najdena. Poskusite znova. Ali pa se obrnite na skrbnika sistema.",
            closeInTheEnd: false);
      } else if (message == "User doesn't have access to this door") {
        setState(() {
          themeColorForStatus = ThemeColorForStatus.promisson_denied;
          isLoading = false;
        });
      } else if (message == "User is in timeout") {
        setState(() {
          themeColorForStatus = ThemeColorForStatus.time_out;
          isLoading = false;
        });
      } else {
        setState(() {
          themeColorForStatus = ThemeColorForStatus.unknown;
          isLoading = false;
        });
        ShowError("Nekaj je šlo narobe. Prosim poskusite ponovno.");
      }
      return;
    }
  }

  void closePage() {
    if (context.widget.toString().toLowerCase() ==
        "DoorUnlockUserPage".toLowerCase()) {}
  }

  Future<void> ShowError(String napaka, {bool closeInTheEnd = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextOfDialog) {
        return AlertDialog(
          title: const Text('Napaka!'),
          content: Text("$napaka"),
          actions: <Widget>[
            TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(contextOfDialog, 'Cancel');
                  if (closeInTheEnd) {
                    this.closePage();
                  }
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        backButton(context, icon: Icons.close_rounded),
        Padding(padding: EdgeInsets.only(top: 10)),
        Expanded(
            child: ListView(
                controller: this.scrollController,
                children: [
                  Padding(
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runAlignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Izbrana učilnica:",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "${this.doorNameId}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 70)),
                  GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: MediaQuery.of(context).size.width * 0.65,
                        child: CircleProgressBar(
                          foregroundColor: ThemeColorForStatus.error.color,
                          value: this.procentageAnimation.value ?? 1,
                          backgroundColor: this.themeColorForStatus.color,
                          strokeWidth: 20,
                          child: !isLoading
                              ? Icon(
                                  this.themeColorForStatus.icon,
                                  color: this.themeColorForStatus.color,
                                  size: MediaQuery.of(context).size.width * 0.3,
                                )
                              : CircularProgressIndicator(
                                  color: this.themeColorForStatus.color,
                                ),
                        ),
                      ),
                      onTap: unlockDoor),
                  !isLoading
                      ? Text(
                          this.themeColorForStatus.message,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(),
                  !isLoading
                      ? Text(this.themeColorForStatus.infoMessage,
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center)
                      : SizedBox(),
                ].withSpaceBetween(spacing: 30))),
      ],
    )));
  }
}

enum ThemeColorForStatus {
  success,
  promisson_denied,
  error,
  unknown,
  lock_status,
  time_out,
}

extension ThemeColorForStatusExtension on ThemeColorForStatus {
  Color get color {
    switch (this) {
      case ThemeColorForStatus.success:
        return Colors.green;
      case ThemeColorForStatus.promisson_denied:
        return Colors.orange;
      case ThemeColorForStatus.time_out:
        return Colors.orange;
      case ThemeColorForStatus.error:
        return Colors.red;
      case ThemeColorForStatus.lock_status:
        return Colors.red;
      case ThemeColorForStatus.unknown:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeColorForStatus.success:
        return Icons.lock_open_outlined;
      case ThemeColorForStatus.promisson_denied:
        return Icons.lock_outline;
      case ThemeColorForStatus.error:
        return Icons.error_outline;
      case ThemeColorForStatus.unknown:
        return Icons.lock_outline;
      default:
        return Icons.lock_outline;
    }
  }

  String get message {
    switch (this) {
      case ThemeColorForStatus.success:
        return "Vrata so uspešno odklenjena";
      case ThemeColorForStatus.promisson_denied:
        return "Trenutno nimaš pouka v tej učilnici";
      case ThemeColorForStatus.time_out:
        return "Malo počakaj, da lahko ponovno odkleneš vrata";
      case ThemeColorForStatus.error:
        return "Učilnica ne obstaja";
      case ThemeColorForStatus.lock_status:
        return "Vrata so zaklenjena";
      case ThemeColorForStatus.unknown:
        return "Neznana napaka";
      default:
        return "Neznana napaka";
    }
  }

  String get infoMessage {
    if (this == ThemeColorForStatus.error) {
      return "Prosim poskusite ponovno";
    } else if (this == ThemeColorForStatus.success) {
      return "";
    } else if (this == ThemeColorForStatus.time_out) {
      return "Presegli ste število odklepanj v določenem času";
    }
    return "Pritisni ključavnico za odklep";
  }
}
