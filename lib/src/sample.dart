import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  // ここにイニシャライザを書く
  NextPage(this.item);
  Map item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['volumeInfo']['title']),
      ),
      body: Container(
        child: Text(item['volumeInfo']['description'].toString()),
      ),
    );
  }
}
