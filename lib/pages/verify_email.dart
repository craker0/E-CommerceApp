import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadaia/pages/home.dart';
import 'package:hadaia/pages/snackbar.dart';
import 'package:hadaia/shared/colors.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerifactionEmail();

      timer = Timer.periodic(const Duration(days: 1), (timer) async {
        await FirebaseAuth.instance.currentUser!.reload();
        setState(() {
          isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        });
        if (isEmailVerified) {
          timer.cancel();
        }
      });
    }
  }

  sendVerifactionEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(const Duration(seconds: 60));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "ERROR : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const Home()
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "Verifaction Page",
                style: TextStyle(fontSize: 25),
              ),
              centerTitle: true,
              backgroundColor: appbarGreen,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Check your E-Mail",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          canResendEmail ? sendVerifactionEmail() : null;
                        },
                        style: ButtonStyle(
                            backgroundColor: const WidgetStatePropertyAll(BTNgreen),
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8)),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)))),
                        child: const Text(
                          "Resend Email ?",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: ()async {
                        await  FirebaseAuth.instance.signOut();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 17,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          );
  }
}
