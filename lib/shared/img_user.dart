
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ImgUser extends StatefulWidget {
  

  const ImgUser({super.key,});

  @override
  State<ImgUser> createState() => _ImgUserState();
}
  CollectionReference users = FirebaseFirestore.instance.collection('users');
    final credential = FirebaseAuth.instance.currentUser;
class _ImgUserState extends State<ImgUser> {
  @override
  Widget build(BuildContext context) {
  




    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(credential!.uid).get(),
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
          return CircleAvatar(
                            radius: 77,
                            backgroundImage: NetworkImage(data['imgUrl']),
                          );
        }

        return const Text("loading");
      },
    );
  }
}
