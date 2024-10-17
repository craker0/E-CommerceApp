// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadaia/pages/register.dart';
import 'package:hadaia/pages/resetPassword.dart';
import 'package:hadaia/pages/snackbar.dart';
import 'package:hadaia/provider/google_signin.dart';
import 'package:hadaia/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hadaia/shared/textfeild.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  bool isLoading = true;
  bool isVisable = true;
  final passController = TextEditingController();

  signIn() async {
    setState(() {
      isLoading = false;
    });
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        showSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, 'Wrong password provided for that user.');
      }
    }
    setState(() {
      isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final googleLoginProvider = Provider.of<GoogleSignInProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(33.0),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 64,
                    ),
                    TextFormField(
                        validator: (email) {
                          return email!.contains(RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                              ? null
                              : "Enter a vaild Email";
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        decoration: decorationTextfield.copyWith(
                            hintText: "Enter Your Email : ",
                            suffixIcon: const Icon(Icons.email))),
                    const SizedBox(
                      height: 33,
                    ),
                    TextField(
                        controller: passController,
                        keyboardType: TextInputType.text,
                        obscureText: isVisable ? true : false,
                        decoration: decorationTextfield.copyWith(
                            hintText: "Enter Your Password : ",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisable = !isVisable;
                                  });
                                },
                                icon: isVisable
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off)))),
                    const SizedBox(
                      height: 33,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await signIn();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(BTNgreen),
                        padding:
                            WidgetStateProperty.all(const EdgeInsets.all(12)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                      ),
                      child: isLoading
                          ? const Text(
                              "Sign in",
                              style: TextStyle(
                                fontSize: 19,
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ResetPassword()));
                        },
                        child: const Text(
                          "Forget Password .",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18),
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Do not have an account?",
                            style: TextStyle(fontSize: 18)),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Register()),
                              );
                            },
                            child: const Text('sign up',
                                style: TextStyle(
                                    fontSize: 18,
                                    decoration: TextDecoration.underline))),
                      ],
                    ),
                    const SizedBox(
                      height: 17,
                    ),
                    const SizedBox(
                      width: 300,
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                            thickness: 0.6,
                            color: Colors.black,
                          )),
                          Text("OR"),
                          Expanded(
                              child: Divider(
                            thickness: 0.6,
                            color: Colors.black,
                          ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 17,
                    ),
                    GestureDetector(
                      onTap: () {
                        googleLoginProvider.googlelogin();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 94, 7, 14),
                            )),
                        child: SvgPicture.asset(
                          "assets/svg/google.svg",
                          height: 45,
                          color: const Color.fromARGB(255, 94, 7, 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
