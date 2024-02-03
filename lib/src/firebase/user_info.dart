import 'package:firebase_auth/firebase_auth.dart';

// Firebaseとの連携用のAPIに関しては以下のサイトを参照のこと
// https://qiita.com/nR9h3kLy/items/a0cebb06a3f7257ff6de

// ユーザー情報を取得する
Future<void> reload() async {
  final instance = FirebaseAuth.instance;
  final User? user = instance.currentUser;
  await user!.reload();
}

// ユーザー表示名を更新する
Future<void> updateDisplayName(String displayName) async {
  final instance = FirebaseAuth.instance;
  final User? user = instance.currentUser;
  await user!.updateDisplayName(displayName);
}

