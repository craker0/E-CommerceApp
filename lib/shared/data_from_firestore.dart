import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadaia/pages/snackbar.dart';

class GetDataFromFirestore extends StatefulWidget {
  final String documentId;

  const GetDataFromFirestore({super.key, required this.documentId});

  @override
  State<GetDataFromFirestore> createState() => _GetDataFromFirestoreState();
}

class _GetDataFromFirestoreState extends State<GetDataFromFirestore> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final credential = FirebaseAuth.instance.currentUser;
    final dialogFeildController = TextEditingController();

    viewDialog(Map data, myKey) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: TextField(
                        controller: dialogFeildController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: data[myKey],
                          border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: .5, color: Colors.brown)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 33,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            onPressed: () {
                              users
                                  .doc(credential!.uid)
                                  .update({myKey: dialogFeildController.text});

                              Navigator.pop(context);
                              showSnackBar(context,
                                  "Changed Succesfully , plz Refresh the page");
                            },
                            child: const Text(
                              "Edit",
                              style: TextStyle(fontSize: 17),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontSize: 17),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Column(
            children: [
              SizedBox(height: 22,),
              Center(child: Text("Document does not exist",style: TextStyle(fontSize: 19),)),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Full Name:  ${data['userName']}"),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              users
                                  .doc(credential!.uid)
                                  .update({"userName": FieldValue.delete()});
                            });
                          },
                          icon: const Icon(Icons.delete)),
                      IconButton(
                          onPressed: () {
                            viewDialog(data, 'userName');
                          },
                          icon: const Icon(Icons.edit)),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Title :  ${data['title']}"),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              users
                                  .doc(credential!.uid)
                                  .update({'title': FieldValue.delete()});
                            });
                          },
                          icon: const Icon(Icons.delete)),
                      IconButton(
                          onPressed: () {
                            viewDialog(data, 'title');
                          },
                          icon: const Icon(Icons.edit))
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Age :  ${data['age']} years old"),
                  IconButton(
                      onPressed: () {
                        viewDialog(data, 'age');
                      },
                      icon: const Icon(Icons.edit))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("E-Mail :  ${data['email']}"),
                  IconButton(
                      onPressed: () {
                        viewDialog(data, 'email');
                      },
                      icon: const Icon(Icons.edit))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("PassWord :  ${data['pass']}"),
                  IconButton(
                      onPressed: () {
                        viewDialog(data, 'pass');
                      },
                      icon: const Icon(Icons.edit))
                ],
              ),
              const SizedBox(
                height: 17,
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        users.doc(credential!.uid).delete();
                      });
                    },
                    child: const Text(
                      "Delete Data",
                      style: TextStyle(fontSize: 17),
                    )),
              )
            ],
          );
        }

        return const Text("loading");
      },
    );
  }
}
