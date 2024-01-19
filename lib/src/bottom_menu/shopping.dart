import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({Key? key}) : super(key: key);

  // final String title;

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  // ショッピングページのイニシャライザ設定
  List items = [];
  bool _loading = false;

  Future<void> getProductData() async {
    // スピナー表示
    setState(() {
      _loading = true;
    });

    var response = await http.get(Uri.https(
        'www.googleapis.com',
        '/books/v1/volumes',
        {'q': '{Flutter}', 'maxResults': '30', 'langRestrict': 'ja'}));

    var jsonResponse = jsonDecode(response.body);

    setState(() {
      items = jsonResponse['items'];
      print(items);
      // スピナー非表示
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    getProductData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ショッピング'),
      ),
      body: _loading
      ? const Center(child: CircularProgressIndicator()) // _loadingがtrueならスピナー表示
      : ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Image.network(
                    items[index]['volumeInfo']['imageLinks']['thumbnail'],
                  ),
                  title: Text(items[index]['volumeInfo']['title']),
                  subtitle: Text(items[index]['volumeInfo']['publishedDate']),
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 800,
                          width: double.infinity,
                          // child: Text(items[index]['volumeInfo']['description'].toString()),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(children: [
                                Image.network(
                                  items[index]['volumeInfo']['imageLinks']
                                      ['thumbnail'],
                                ),
                                Text('A random AWESOME idea:'),
                                Text(items[index]['volumeInfo']['description']
                                    .toString()),
                              ]),
                            ),
                          ),
                        );
                      },
                    );
                    // print('画面遷移します。');
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => NextPage(items[index])),
                    // );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
