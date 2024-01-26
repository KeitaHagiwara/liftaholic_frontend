import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  // final String title;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  // イニシャライザ設定

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('アカウント'),
      // ),
      body: Center(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "Keita Hagiwara",
                style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white, fontSize:18.0),
              ),
              accountEmail: Text("liftaholic@example.com"),
              currentAccountPicture: CircleAvatar(foregroundImage: AssetImage("assets/test_user.jpeg")),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
          ]
        )
      ),
    );
  }
}