// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// // Lottieを使ったログインスクリーン
// // アニメーション素材は以下のサイトから取得できる。
// // https://lottiefiles.com/
// // pubspec.yamlに以下を追加
// // lottie: ^1.2.1
// class LottieScreen extends StatefulWidget {
//   const LottieScreen({Key? key}) : super(key: key);

//   @override
//   _LottieScreenState createState() => _LottieScreenState();
// }

// class _LottieScreenState extends State<LottieScreen> {
//   String email = '';
//   String password = '';
//   bool hidePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Lottie Screen'),
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
//         child: Center(
//           child: Column(
//             children: [
//               const Text(
//                 'ログイン',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               // https://lottiefiles.com/38435-register を使用。
//               // ページ内の'Lottie Animation URL'で取得したURLを貼り付ける
//               Lottie.network(
//                 // 'https://lottie.host/84241c93-f84c-4133-9d2b-4eeff328313a/XPxdU0Zv81.json',
//                 'https://lottie.host/c40cfa4e-ab6d-4c6e-aa13-2901a6bd5100/dG0o8nAXpc.json',
//                 width: 300,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Padding(
//                     padding: EdgeInsets.all(30.0),
//                     child: CircularProgressIndicator(),
//                   );
//                 },
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   icon: Icon(Icons.mail),
//                   hintText: 'liftaholic@example.com',
//                   labelText: 'メールアドレス',
//                 ),
//                 onChanged: (String value) {
//                   setState(() {
//                     email = value;
//                   });
//                 },
//               ),
//               TextFormField(
//                 obscureText: hidePassword,
//                 decoration: InputDecoration(
//                   icon: const Icon(Icons.lock),
//                   labelText: 'パスワード',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       hidePassword ? Icons.visibility_off : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         hidePassword = !hidePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 onChanged: (String value) {
//                   setState(() {
//                     password = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 15),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('ログイン'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String error_message = "";

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    try {
      // Try login
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      // Succeeded to login
      // final User user = userCredential.user!;
      // print(user.email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          error_message = 'メールアドレスが間違っています。';
          break;
        case 'wrong-password':
          error_message = 'パスワードが間違っています。';
          break;
        case 'user-not-found':
          error_message = 'このアカウントは存在しません。';
          break;
        case 'user-disabled':
          error_message = 'このメールアドレスは無効になっています。';
          break;
        case 'too-many-requests':
          error_message = '回線が混雑しています。もう一度試してみてください。';
          break;
        case 'operation-not-allowed':
          error_message = 'メールアドレスとパスワードでのログインは有効になっていません。';
          break;
        case 'email-already-in-use':
          error_message = 'このメールアドレスはすでに登録されています。';
          break;
        default:
          error_message = 'ログインに失敗しました。';
          break;
      }
      return error_message;
    } catch (e) {
      error_message = '予期せぬエラーが発生しました。';
      return error_message;
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      // User Registration
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          error_message = 'パスワードが弱いです。';
          break;
        case 'email-already-in-use':
          error_message = 'このメールアドレスを持つアカウントは既に存在します。';
          break;
        default:
          error_message = 'サインインに失敗しました。';
          break;
      }
      return error_message;
    } catch (e) {
      error_message = '予期せぬエラーが発生しました。';
      return error_message;
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      // print("パスワードリセット用のメールを送信しました。");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          error_message = 'メールアドレスが無効です。';
          break;
        case 'user-not-found':
          error_message = '該当のメールアドレスを持つユーザーが存在しません。';
          break;
        default:
          error_message = 'パスワードリセットメールの送信に失敗しました。';
          break;
      }
      return error_message;
    } catch (e) {
      error_message = '予期せぬエラーが発生しました。';
      return error_message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('LIFTAHOLIC', style: GoogleFonts.bungeeSpice()),
      // ),
      body: FlutterLogin(
        title: 'LIFTAHOLIC',
        // logo: const AssetImage('assets/images/liftaholic_logo.gif'),
        onLogin: _authUser,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pop();
        },
        onRecoverPassword: _recoverPassword,
        messages: LoginMessages(
          // recoverPasswordDescription:
          //     'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
          recoverPasswordSuccess: 'パスワードリセット用のメールを送信しました。',
        ),
      ),
    );
  }
}
