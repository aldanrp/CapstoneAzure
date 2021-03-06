import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import 'Constant/style.dart';
import 'Repository/Api/providers/aI_prediction_api.dart';
import 'Repository/Api/providers/auth.dart';
import 'Repository/Api/providers/place_data.dart';
import 'Repository/Api/providers/player.dart';
import 'Repository/local/helper/db_helper.dart';
import 'Repository/local/service/db_provider.dart';
import 'UI/Pages/history_page.dart';
import 'UI/Pages/home_page.dart';
import 'UI/Pages/search_page.dart';
import 'UI/Pages/setting_page.dart';
import 'UI/Pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Placesdata>(
          create: (context) => Placesdata(),
          update: (context, auth, places) => places!
            ..updatedata(
                auth.token, auth.userId, auth.usernamedata, auth.email),
        ),
        ChangeNotifierProxyProvider<Auth, PlayersProviders>(
          create: (context) => PlayersProviders(),
          update: (context, auth, playersdata) =>
              playersdata!..updatedata(auth.token, auth.userId),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DatabaseProvider(
            databaseHelper: DatabaseHelper(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AiPrediction(),
        ),
      ],
      builder: (context, child) => MaterialApp(
        theme: ThemeData(
          androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int selectedPage;
  const MyHomePage({
    Key? key,
    required this.selectedPage,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ShapeBorder? bottomBarShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    ),
  );

  bool selectpage = true;
  int _selectedItemPosition = 0;
  SnakeShape snakeShape = SnakeShape.circle;

  bool showSelectedLabels = false;
  bool showUnselectedLabels = false;

  Color selectedColor = Colors.black;
  Gradient selectedGradient =
      const LinearGradient(colors: [Colors.red, Colors.amber]);

  Color unselectedColor = Colors.grey;
  Gradient unselectedGradient =
      const LinearGradient(colors: [Colors.red, Colors.blueGrey]);

  @override
  void initState() {
    super.initState();
    if (selectpage == true) {
      _selectedItemPosition = widget.selectedPage;
    }
  }

  Widget _getWidget(bool isfocus) {
    if (_selectedItemPosition == 1) {
      return SearchPage(
        isFocus: isfocus,
      );
    } else if (_selectedItemPosition == 2) {
      return const HistoryPage();
    } else if (_selectedItemPosition == 3) {
      return const SettingPage();
    }

    return const HomePage();
  }

  DateTime _timebackPressed = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final _difference = DateTime.now().difference(_timebackPressed);
        final _exitwarning = _difference >= const Duration(seconds: 2);

        _timebackPressed = DateTime.now();

        if (_exitwarning) {
          const message = 'Press back again to exit';
          Fluttertoast.showToast(
            msg: message,
            fontSize: 18,
            gravity: ToastGravity.BOTTOM,
          );
          return false;
        } else {
          Fluttertoast.cancel();
          SystemNavigator.pop();
          return true;
        }
      },
      child: Scaffold(
        body: widget.selectedPage == 1 ? _getWidget(true) : _getWidget(false),
        bottomNavigationBar: SnakeNavigationBar.color(
          // height: 80,
          backgroundColor: kPrimary,
          behaviour: SnakeBarBehaviour.pinned,
          snakeShape: snakeShape = SnakeShape.circle,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          padding: EdgeInsets.zero,

          ///configuration for SnakeNavigationBar.color
          snakeViewColor: kSecondary,

          selectedItemColor: kBlack,
          unselectedItemColor: kWhite,

          ///configuration for SnakeNavigationBar.gradient
          // snakeViewGradient: selectedGradient,
          // selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
          // unselectedItemGradient: unselectedGradient,

          showSelectedLabels: showSelectedLabels = false,
          showUnselectedLabels: showUnselectedLabels = false,
          currentIndex:
              selectpage == true ? widget.selectedPage : _selectedItemPosition,
          onTap: (index) => setState(() {
            _selectedItemPosition = index;
            selectpage = false;
          }),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: 'home'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart_fill), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings_solid), label: 'search')
          ],
          selectedLabelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
