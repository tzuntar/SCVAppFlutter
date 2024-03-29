import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scv_app/Components/NavBarItemv2.dart';
import 'package:scv_app/alerts/cantLoadAlert.dart';
import 'package:scv_app/alerts/unAuthoritizedAlert.dart';
import 'package:scv_app/eA/easistent.dart';
import 'package:scv_app/Data/functions.dart';
import 'package:scv_app/eA_icon/ea_flutter_icon.dart';
import 'package:scv_app/Intro_And__Login/prijava.dart';
import 'package:scv_app/Data/theme.dart';
import 'package:scv_app/Intro_And__Login/uvod.dart';
import 'package:scv_app/Lock/zaklep.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'Lunch/malice.dart';
import 'Nastavitve/nastavitve.dart';
import 'Home_Page/domov.dart';
import 'Schedule/urnik.dart';
import 'Data/data.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DarkLightTheme();
  }
}

class DarkLightTheme extends StatefulWidget {
  const DarkLightTheme({
    Key key,
  }) : super(key: key);

  @override
  State<DarkLightTheme> createState() => _DarkLightThemeState();
}

class _DarkLightThemeState extends State<DarkLightTheme> {
  @override
  void initState() {
    super.initState();
    isLogedIn();
  }

  Widget presented = OnBoardingPage();

  ThemeMode themeMode = ThemeMode.system;
  bool isBioLock = false;

  void isLogedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      bool isBio = prefs.getBool(keyForUseBiometrics);
      if (isBio == true) {
        isBioLock = true;
      } else if (isBio == false) {
        isBioLock = false;
      }
    } catch (e) {
      print(e);
    }
    if (await aliJeUporabnikPrijavljen()) {
      presented = isBioLock ? ZaklepPage() : MyHomePage();
    }
    try {
      bool isDark = prefs.getBool(keyForThemeDark);
      if (isDark == true) {
        themeMode = ThemeMode.dark;
      } else if (isDark == false) {
        themeMode = ThemeMode.light;
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: isLoading ? CircularProgressIndicator() : presented,
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: themeMode,
      supportedLocales: [Locale("sl")],
      locale: Locale("sl"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int selectedIndex = 0;
  Data data = new Data();
  bool isLoading = true;
  CacheData cacheData = new CacheData();
  final List<Widget> _childrenWidgets = [];
  String appOpenUrl = "";

  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadDataToScreen();
  }

  void initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (isUrlForOpeinDoor(initialLink)) {
        goToOpenDoor(context, initialLink);
      }
    } catch (e) {}
    _incomingLinkHandler();
  }

  void _incomingLinkHandler() {
    _streamSubscription = uriLinkStream.listen((Uri uri) {
      if (!mounted) {
        return;
      }
      if (uri != null) {
        setState(() {
          appOpenUrl = uri.toString();
        });
      } else {
        setState(() {
          appOpenUrl = "";
        });
      }
    }, onError: (Object err) {
      if (!mounted) {
        return;
      }
    });
  }

  void loadDataToScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(keyForAppAutoLock);
    CacheData cacheData2 = new CacheData();
    await cacheData2.getData();
    setState(() {
      cacheData = cacheData2;
      _childrenWidgets.add(new DomovPage(
        cacheData: cacheData,
      ));
      _childrenWidgets.add(new MalicePage());
      // _childrenWidgets.add(new IsciPage());
      _childrenWidgets.add(new EasistentPage());
      _childrenWidgets.add(new UrnikPage(cacheData: cacheData));
      _childrenWidgets.add(new NastavitvePage(cacheData: cacheData));
      isLoading = !cacheData2.dataLoaded;
    });
    try {
      if (await this.data.loadData(cacheData)) {
        setState(() {
          DomovPage page = _childrenWidgets[0];
          page.updateData(data);
          UrnikPage page2 = _childrenWidgets[3];
          page2.updateData(data);
          NastavitvePage page3 = _childrenWidgets[4];
          page3.updateData(data);
          isLoading = false;
        });
        var prevS = selectedIndex;
        if (prevS != 0) {
          setState(() {
            selectedIndex = 0;
          });
          await Future.delayed(Duration(milliseconds: 10));
          setState(() {
            selectedIndex = prevS;
          });
        } else if (cacheData.schoolUrl == "") {
          setState(() {
            selectedIndex = 1;
          });
          await Future.delayed(Duration(milliseconds: 10));
          setState(() {
            selectedIndex = prevS;
          });
        }
      } else {
        showCantLoad(context);
      }
    } catch (e) {
      List<String> error = e.toString().split(" ");
      if (error.length >= 1) {
        if (error[1] == "401") {
          showUnAuthoritized(context);
          return;
        }
      }
      showCantLoad(context);
    }
    await initUniLinks();
  }

  void changeView(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //Aplikacija odprta iz ozadja
      SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        //Funkcija za osvežitev dostopnega žetona
        final expiresOn = prefs.getString(keyForExpiresOn);
        final accessToken = prefs.getString(keyForAccessToken);
        DateTime expiredDate = new DateFormat("EEE MMM dd yyyy hh:mm:ss")
            .parse(expiresOn)
            .toUtc()
            .subtract(Duration(minutes: 5));
        DateTime zdaj = new DateTime.now().toUtc();
        if (zdaj.isAfter(expiredDate)) {
          await refreshToken();
        }
        if (data != null) {
          await data.ureUrnikData.getFromWeb(accessToken);
        } else {
          await cacheData.ureUrnikData.getFromWeb(accessToken);
        }
      } catch (e) {
        print(e);
      }

      try {
        bool isBio = prefs.getBool(keyForUseBiometrics);
        int autoLock = prefs.getInt(keyForAppAutoLock);
        int zdaj = new DateTime.now().toUtc().millisecondsSinceEpoch;
        if (isBio == true) {
          prefs.remove(keyForAppAutoLock);
          if (zdaj >= autoLock) {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ZaklepPage(
                      isFromAutoLock: true,
                    )));
            if (isUrlForOpeinDoor(appOpenUrl)) {
              goToOpenDoor(context, appOpenUrl);
              setState(() {
                appOpenUrl = "";
              });
            }
          }
        } else {
          if (isUrlForOpeinDoor(appOpenUrl)) {
            goToOpenDoor(context, appOpenUrl);
            setState(() {
              appOpenUrl = "";
            });
          }
        }
      } catch (e) {
        print(e);
      }
    } else if (state == AppLifecycleState.paused) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int minuts = 5;
      try {
        int minutuesToAutoLOCK = prefs.getInt(keyForAppAutoLockTimer);
        if (minutuesToAutoLOCK == 0) {
          minuts = 0;
          prefs.setInt(keyForAppAutoLock,
              new DateTime.now().toUtc().millisecondsSinceEpoch);
          return;
        } else if (minutuesToAutoLOCK > 10000) {
          prefs.remove(keyForAppAutoLockTimer);
          return;
        } else {
          minuts = minutuesToAutoLOCK;
        }
      } catch (e) {
        minuts = 5;
      }
      prefs.setInt(
          keyForAppAutoLock,
          new DateTime.now()
              .toUtc()
              .add(Duration(minutes: minuts))
              .millisecondsSinceEpoch);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedIndex == 0 && !isLoading
          ? (data.schoolData.schoolColor != null
              ? data.schoolData.schoolColor
              : cacheData.schoolColor)
          : Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: selectedIndex == 0
            ? SystemUiOverlayStyle.light
            : Theme.of(context).backgroundColor == Colors.black
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
        child: Center(
            child: SafeArea(
                child: isLoading
                    ? CircularProgressIndicator(
                        color: cacheData.schoolColor,
                      )
                    : _childrenWidgets[selectedIndex])),
      ),
      bottomNavigationBar: !isLoading
          ? FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Theme.of(context).bottomAppBarColor,
                selectedItemBorderColor: Theme.of(context).bottomAppBarColor,
                selectedItemBackgroundColor:
                    (data.schoolData.schoolColor != null
                        ? data.schoolData.schoolColor
                        : cacheData.schoolColor),
                selectedItemIconColor: Theme.of(context).bottomAppBarColor,
                selectedItemLabelColor: Theme.of(context).primaryColor,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItemv2(
                  iconData: Icons.home_rounded,
                  label: 'Domov',
                ),
                FFNavigationBarItemv2(
                  iconData: Icons.fastfood,
                  label: 'Malice',
                ),
                /* FFNavigationBarItemv2(
            iconData: Icons.person_search,
            label: 'P.O.',
          ), */
                FFNavigationBarItemv2(
                  iconData: FluttereAIcon.ea,
                  label: 'eAsistent',
                ),
                FFNavigationBarItemv2(
                  iconData: Icons.calendar_today_rounded,
                  label: 'Urnik',
                ),
                FFNavigationBarItemv2(
                  iconData: Icons.settings,
                  label: 'Nastavitve',
                ),
              ],
            )
          : SizedBox(),
    );
  }
}
