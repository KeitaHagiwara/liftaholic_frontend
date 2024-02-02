import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'sample.dart';
import 'bottom_menu/account.dart';
import 'bottom_menu/workout.dart';
import 'bottom_menu/planning.dart';
import 'bottom_menu/notification.dart';
import 'bottom_menu/shopping.dart';
import 'login.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIFTAHOLIC',
      theme: ThemeData(brightness: Brightness.dark),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          if (snapshot.hasData) {
            return MyHomePage(title: 'LIFTAHOLIC');
          }
          return LoginScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _screens = [
    PlanningScreen(),
    WorkoutScreen(),
    NotificationScreen(),
    // ShoppingScreen(),
    AccountScreen()
  ];

  int _selectedIndex = 0;
  // bool isLogin = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('LIFTAHOLIC', style: GoogleFonts.blackOpsOne()),
        // title: Text('LIFTAHOLIC', style: GoogleFonts.goblinOne()),
        // title: Text('LIFTAHOLIC', style: GoogleFonts.zillaSlabHighlight()),
        // title: Text('LIFTAHOLIC', style: GoogleFonts.bungeeSpice()),
        title: Text(
          'LIFTAHOLIC',
          style: TextStyle(fontFamily: 'Honk', fontSize: 36, color: Colors.blue),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.shopping_bag),
        //     onPressed: () => {},
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.list_alt),
        //     onPressed: () => {},
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.account_circle),
        //     onPressed: () => {},
        //   ),
        // ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'プランニング'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'ワークアウト'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'お知らせ'),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.shopping_cart), label: 'ショッピング'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        selectedIconTheme: const IconThemeData(size: 32, color: Colors.blue),
        unselectedIconTheme: const IconThemeData(size: 32),
        showSelectedLabels: true, // 選択されたメニューのラベルの表示設定
        showUnselectedLabels: true, // 選択されてないメニューのラベルの表示設定
      ),
    );
  }
}
