import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hadaia/firebase_options.dart';
import 'package:hadaia/pages/login.dart';
import 'package:hadaia/pages/snackbar.dart';
import 'package:hadaia/pages/verify_email.dart';
import 'package:hadaia/provider/cart.dart';
import 'package:flutter/material.dart';
import 'package:hadaia/provider/google_signin.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return Cart();
        }),
        ChangeNotifierProvider(create: (context) {
          return GoogleSignInProvider();
        })
      ],
      child: MaterialApp(
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return showSnackBar(context, "spmething went Wrong");
                } else if (snapshot.hasData) {
                  return const VerifyEmailPage();
                } else {
                  return const Login();
                }
              })),
    );
  }
}
