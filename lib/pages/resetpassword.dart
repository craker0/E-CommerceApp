import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadaia/pages/login.dart';
import 'package:hadaia/pages/snackbar.dart';
import 'package:hadaia/shared/colors.dart';
import 'package:hadaia/shared/textfeild.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  bool isLoading = false;

  resetPass() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
      showSnackBar(context, "Done - plz check your email");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showSnackBar(context, "ERROR : ${e.code}");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarGreen,
        title: const Text("Reset Password"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Enter your E-Mail to reset your Password ."),
              Padding(
                padding: const EdgeInsets.all(38.0),
                child: TextFormField(
                  validator: (email) {
                    return email!.contains(RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                        ? null
                        : "Enter a vaild Email";
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: emailController,
                  decoration: decorationTextfield.copyWith(
                      hintText: "Enter Your E-Mail",
                      suffixIcon: const Icon(Icons.email_rounded)),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      resetPass();
                    } else {
                      showSnackBar(context, "ERROR");
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll(BTNgreen),
                      padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 15, vertical: 9)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Reset Password"))
            ],
          ),
        ),
      ),
    );
  }
}
