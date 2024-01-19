import 'package:flutter/material.dart';

// import 'sample.dart';
import 'bottom_menu/account.dart';
import 'bottom_menu/workout.dart';
import 'bottom_menu/home.dart';
import 'bottom_menu/notification.dart';
import 'bottom_menu/shopping.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'workout trAIner',
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home: MyHomePage(title: 'workout trAIner'),
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
    HomeScreen(),
    WorkoutScreen(),
    NotificationScreen(),
    ShoppingScreen(),
    AccountScreen()
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('workout trAIner'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'ワークアウト'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'お知らせ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'ショッピング'),
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
