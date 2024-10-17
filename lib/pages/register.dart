// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hadaia/pages/login.dart';
import 'package:hadaia/pages/snackbar.dart';
import 'package:hadaia/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:hadaia/shared/textfeild.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  File? imgPath;

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;
  bool isVisable = true;
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();
  final ageController = TextEditingController();
  final titleController = TextEditingController();

  bool isPass8chara = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasNum = false;
  bool hasSimple = false;
  String? imgName;

  upLoadImage(ImageSource src) async {
    final pickedImg = await ImagePicker().pickImage(source: src);
    try {
      if (pickedImg != null) {
        setState(() {
          imgPath = File(pickedImg.path);
          imgName = basename(pickedImg.path);
          int random = Random().nextInt(9999);
          imgName = "$random$imgName";
        });
      } else {
        print("The file unavilable");
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "ERROR : $e");
    }
  }

  onPassChange(String password) {
    isPass8chara = false;
    hasUpper = false;
    hasLower = false;
    hasNum = false;
    hasSimple = false;

    setState(() {
      if (password.contains(RegExp(r'.{8,}'))) {
        isPass8chara = true;
      }
      if (password.contains(RegExp(r'[A-Z]'))) {
        hasUpper = true;
      }
      if (password.contains(RegExp(r'[a-z]'))) {
        hasLower = true;
      }
      if (password.contains(RegExp(r'[0-9]'))) {
        hasNum = true;
      }
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        hasSimple = true;
      }
    });
  }

  register() async {
    setState(() {
      isLoading = true;
    });
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final storageRef = FirebaseStorage.instance.ref('img-user/$imgName');
      await storageRef.putFile(imgPath!);
      String url = await storageRef.getDownloadURL();
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      users
          .doc(credential.user!.uid)
          .set({
            'imgUrl': url,
            'userName': userNameController.text,
            'age': ageController.text,
            'title': titleController.text,
            'email': emailController.text,
            'pass': passwordController.text
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (!mounted) return;
        showSnackBar(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        if (!mounted) return;

        showSnackBar(context, 'The account already exists for that email.');
      }
    } catch (e) {
        if (!mounted) return;

      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  showModel() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(22),
            height: 200,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await upLoadImage(ImageSource.camera);

                    Navigator.pop(context);
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.camera_enhance,
                        size: 24,
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Text(
                        "Camera ",
                        style: TextStyle(fontSize: 24),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () async {
                    await upLoadImage(ImageSource.gallery);

                    Navigator.pop(context);
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 24,
                      ),
                      SizedBox(
                        width: 14,
                      ),
                      Text(
                        "Gallery ",
                        style: TextStyle(fontSize: 24),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
    titleController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(33.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3.3),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 78, 42, 42),
                          shape: BoxShape.circle),
                      child: Stack(
                        children: [
                          imgPath == null
                              ? const CircleAvatar(
                                  radius: 77,
                                  backgroundImage:
                                      AssetImage('assets/img/avatar.jpg'),
                                )
                              : ClipOval(
                                  child: Image.file(
                                    imgPath!,
                                    width: 145,
                                    height: 145,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Positioned(
                              bottom: -13,
                              right: -13,
                              child: IconButton(
                                  onPressed: () {
                                    showModel();
                                  },
                                  icon: const Icon(
                                    Icons.add_a_photo,
                                  )))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextFormField(
                        controller: userNameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        decoration: decorationTextfield.copyWith(
                            hintText: "Enter Your username : ",
                            suffixIcon: const Icon(Icons.person))),
                    const SizedBox(
                      height: 33,
                    ),
                    TextFormField(
                      controller: ageController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      decoration: decorationTextfield.copyWith(
                          hintText: "Enter Your Age : ",
                          suffixIcon: const Icon(Icons.numbers)),
                    ),
                    const SizedBox(
                      height: 33,
                    ),
                    TextFormField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        decoration: decorationTextfield.copyWith(
                            hintText: "Enter Your Title : ",
                            suffixIcon: const Icon(Icons.person_outline_outlined))),
                    const SizedBox(
                      height: 33,
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
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        decoration: decorationTextfield.copyWith(
                            hintText: "Enter Your Email : ",
                            suffixIcon: const Icon(Icons.email))),
                    const SizedBox(
                      height: 33,
                    ),
                    TextFormField(
                        onChanged: (password) {
                          onPassChange(password);
                        },
                        validator: (value) {
                          return value!.length < 8
                              ? "Enter at least 8 characters"
                              : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: passwordController,
                        textInputAction: TextInputAction.done,
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
                      height: 12,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPass8chara ? Colors.green : Colors.white,
                              border: Border.all(color: Colors.white)),
                          child: const Icon(
                            Icons.check,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text("At least 8 Characters")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasUpper ? Colors.green : Colors.white,
                              border: Border.all(color: Colors.white)),
                          child: const Icon(
                            Icons.check,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text("Has Uppercase")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasLower ? Colors.green : Colors.white,
                              border: Border.all(color: Colors.white)),
                          child: const Icon(
                            Icons.check,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text("Has Lowecase")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasNum ? Colors.green : Colors.white,
                              border: Border.all(color: Colors.white)),
                          child: const Icon(
                            Icons.check,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text("Has a number")
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasSimple ? Colors.green : Colors.white,
                              border: Border.all(color: Colors.white)),
                          child: const Icon(
                            Icons.check,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text("Has a Simple {!@#\$}")
                      ],
                    ),
                    const SizedBox(
                      height: 33,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            imgName != null &&
                            imgPath != null) {
                          await register();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()));
                          }
                        } else {
                          showSnackBar(context, "ERROR");
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(BTNgreen),
                        padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Register",
                              style: TextStyle(fontSize: 19),
                            ),
                    ),
                    const SizedBox(
                      height: 33,
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
                                    builder: (context) => const Login()),
                              );
                            },
                            child: const Text('sign in',
                                style: TextStyle(fontSize: 18))),
                      ],
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
