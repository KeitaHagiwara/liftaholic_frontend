import 'package:flutter/material.dart';

import '../workout/add_training_menu.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ワークアウト'),
      ),
      body: const Center(
          child: Text('ワークアウト画面', style: TextStyle(fontSize: 32.0))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPage()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
