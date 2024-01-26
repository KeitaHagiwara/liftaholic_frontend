import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  // final String title;

  @override
  State<NotificationScreen> createState() => _NortificationScreenState();
}


class _NortificationScreenState extends State<NotificationScreen> {

  // イニシャライザ設定



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Information',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold).copyWith(color: Colors.white70, fontSize: 18.0),
        ),
      ),
      body:
          const Center(child: Text('お知らせ画面', style: TextStyle(fontSize: 32.0))),
    );
  }
}
