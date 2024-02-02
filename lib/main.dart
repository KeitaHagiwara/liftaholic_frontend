import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'src/app.dart';
import 'src/firebase/firebase_options.dart';

Future<void> main() async {
  // Firebaseに接続する
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // カレンダーを日本語表記にする
  initializeDateFormatting('ja');
  runApp(MyApp());
}