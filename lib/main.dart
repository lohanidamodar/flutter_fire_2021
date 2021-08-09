import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null)
                    return Text(snapshot.data!.email!);
                  else
                    return Text("Not Logged in");
                }
                return Text("Not Logged in");
              }),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('demo').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!.docs;
                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ...data.map((doc) {
                      if (doc.exists) {
                        return ListTile(
                          title: Text(
                              (doc.data() as Map<String, dynamic>)['name']),
                          subtitle: Text(
                              (doc.data() as Map<String, dynamic>)['email']),
                        );
                      }
                      return SizedBox(
                        height: 0,
                      );
                    })
                  ],
                );
              }
              return CircularProgressIndicator();
            },
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: "test@testme.com", password: 'testtest');
              print("Login successful");
            },
            child: Text("Login"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection("demo").add({
                "name": "Damodar Lohani 1",
                "email": "test1@testme.com",
              });
              print("Document added");
            },
            child: Text("Create Doc"),
          ),
        ],
      ),
    );
  }
}
