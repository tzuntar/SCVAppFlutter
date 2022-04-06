import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart';
import 'package:scv_app/easistent.dart';
import 'package:scv_app/presentation/ea_flutter_icon.dart';
import 'package:scv_app/prijava.dart';
import 'package:scv_app/theme.dart';
import 'package:scv_app/uvod.dart';
import 'package:scv_app/zaklep.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'malice.dart';
import 'nastavitve.dart';
import 'domov.dart';
import 'urnik.dart';
import 'data.dart';
import 'isci.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
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
    // HomeWidget.setAppGroupId('group.pripomocki');
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
      supportedLocales: [
        Locale("sl")
      ],
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
  bool noUser = false;

  final List<Widget> _childrenWidgets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadDataToScreen();
  }

  void loadDataToScreen() async {
    if (!await this.data.loadData()) {
      setState(() {
        noUser = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(keyForAccessToken);
      prefs.remove(keyForRefreshToken);
      prefs.remove(keyForExpiresOn);
      prefs.remove(keyForThemeDark);
      prefs.remove(keyForUseBiometrics);

      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => OnBoardingPage()));
    }
    setState(() {
      _childrenWidgets.add(new DomovPage(data: data));
      _childrenWidgets.add(new MalicePage());
      // _childrenWidgets.add(new IsciPage());
      _childrenWidgets.add(new EasistentPage());
      _childrenWidgets.add(new UrnikPage(data: data));
      _childrenWidgets.add(new NastavitvePage(data: data));
      isLoading = false;
    });
  }

  void changeView(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try{
        final expiresOn = prefs.getString(keyForExpiresOn);
        DateTime expiredDate = new DateFormat("EEE MMM dd yyyy hh:mm:ss").parse(expiresOn).toUtc();
        DateTime zdaj = new DateTime.now().toUtc();
        print(expiredDate);
        if(zdaj.isAfter(expiredDate)){
          await refreshToken();
        }
      }catch(e){
        print(e);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedIndex == 0
          ? data.schoolData.schoolColor
          : Theme.of(context).backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: selectedIndex == 0
            ? SystemUiOverlayStyle.light
            : Theme.of(context).backgroundColor == Colors.black
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
        child: Center(
            child: SafeArea(
                child: isLoading
                    ? CircularProgressIndicator()
                    : _childrenWidgets[selectedIndex])),
      ),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Theme.of(context).bottomAppBarColor,
          selectedItemBorderColor: Theme.of(context).bottomAppBarColor,
          selectedItemBackgroundColor: data.schoolData.schoolColor,
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
          FFNavigationBarItem(
            iconData: Icons.home_rounded,
            label: 'Domov',
          ),
          FFNavigationBarItem(
            iconData: Icons.fastfood,
            label: 'Malice',
          ),
          /* FFNavigationBarItem(
            iconData: Icons.person_search,
            label: 'P.O.',
          ), */
          FFNavigationBarItem(
            iconData: FluttereAIcon.ea,
            label: 'eAsistent',
          ),
          FFNavigationBarItem(
            iconData: Icons.calendar_today_rounded,
            label: 'Urnik',
          ),
          FFNavigationBarItem(
            iconData: Icons.settings,
            label: 'Nastavitve',
          ),
        ],
      ),
    );
  }
}
