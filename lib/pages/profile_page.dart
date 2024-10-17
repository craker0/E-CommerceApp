// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hadaia/pages/snackbar.dart';
import 'package:hadaia/shared/data_from_firestore.dart';
import 'package:hadaia/shared/img_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? imgPath;
  String? imgName;
  final credential = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  upLoadImage(ImageSource src) async {
    final pickedImage = await ImagePicker().pickImage(source: src);
    try {
      if (pickedImage != null) {
        setState(() {
          imgPath = File(pickedImage.path);
        });
      } else {}
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "ERROR : $e");
    }
  }

  reUploadImage() async {
    final storeageRef = FirebaseStorage.instance.ref('img-user/$imgName');
    await storeageRef.putFile(imgPath!);
    String url = await storeageRef.getDownloadURL();

    users.doc(credential!.uid).update({'imgUrl': url});
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
                    if (imgPath != null) {
                      await reUploadImage();
                    }
                    if (!mounted) return;
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
                    if (imgPath != null) {
                      await reUploadImage();
                    }
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
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        actions: [
          TextButton.icon(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text("logout"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(3.3),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 78, 42, 42),
                    shape: BoxShape.circle),
                child: Stack(
                  children: [
                    imgPath == null
                        ? const ImgUser()
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
                            onPressed: () async {
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
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 55, 5, 5),
                      borderRadius: BorderRadius.circular(9)),
                  child: const Text(
                    "info form firebase Auth",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 22,
                  ),
                  Text("E-mail : ${credential!.email} "),
                  const SizedBox(
                    height: 22,
                  ),
                  Text(
                    "Created date:   ${DateFormat("MMMM d, y").format(credential!.metadata.creationTime!)}   ",
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  Text(
                      "last signin : ${DateFormat("MMM d , y").format(credential!.metadata.lastSignInTime!)}  "),
                  const SizedBox(
                    height: 22,
                  ),
                  Center(
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            credential!.delete();
                            users.doc(credential!.uid).delete();
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          "Delete User",
                          style: TextStyle(fontSize: 17),
                        )),
                  ),
                  const SizedBox(
                    height: 11,
                  ),
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 55, 5, 5),
                          borderRadius: BorderRadius.circular(9)),
                      child: const Text(
                        "info form firebase firestore",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  GetDataFromFirestore(documentId: credential!.uid)
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}
