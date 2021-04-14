
//------------------------ Login Page --------------------------------



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/confirm.dart';
class Login extends StatefulWidget {
  final  Function(dynamic) notifyParent;
  Login({required this.notifyParent}) ;
  @override
  _Login createState() => _Login(this.notifyParent);
}

class _Login extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationPassword = TextEditingController();
  final  Function(dynamic) notifyParent;
  bool attemptLogin = false;
  _Login(this.notifyParent);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Welcome to Startup Names Generator, please log in below:',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                    height: 40,
                    decoration: BoxDecoration( borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: attemptLogin ?
                    ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child:LinearProgressIndicator(backgroundColor: Colors.red,
                        value: 0.8,
                    ))
                        : ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius:  new BorderRadius.circular(30),
                                  side: BorderSide(color: Colors.red)
                              )
                          ) ),
                      child: Text('Login'),
                      onPressed: () async {
                        //HW2
                        try {
                          setState(() {
                            attemptLogin= true;
                          });

                          /*UserCredential userCredential =*/ await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: nameController.text,
                            password: passwordController.text,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          }else{
                            print(e.toString());
                          }
                        }
                          setState(() {
                          attemptLogin= false;
                        });
                        User currentUser = FirebaseAuth.instance.currentUser;
                        //if login is successful
                        if(currentUser.uid != null) {
                          notifyParent(nameController.text);
                          Navigator.of(context).pop();
                        }else{
                          var snackBar = SnackBar(content: Text('There was an error logging into the app'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        //needs to be changed , disable login button until firebase answers.
                        print(nameController.text);
                        print(passwordController.text);


                        //HW1
                        // snackBar = SnackBar(content: Text('Login is not implemented yet'));
                         //ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      },
                    )
                ),
                Container(
                    height: 40,
                    decoration: BoxDecoration( borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child:  attemptLogin ? Container() : ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius:  new BorderRadius.circular(30),
                                  side: BorderSide(color: Colors.green)
                              )
                          ) ),
                      child: Container(child: Text('New user? Click to sign up')),
                      onPressed: () async {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (_)=>Confirm( nameController.text ,
                               passwordController.text,notifyParent: success ),
                        );
                      },
                    )
                )
              ],
            )));
  }
  dynamic success(dynamic) async {
  await registerUser(nameController.text, passwordController.text);
  print('success login email : '+nameController.text);
  }
  Future<void> registerUser(String email,String password) async {
    try {
      //TODO:CHECK IF THIS IS ENOUGH
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      /*UserCredential userCredential =*/ await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: nameController.text,
        password: passwordController.text,
      );
      setState(() {
        attemptLogin= false;
      });
      User currentUser = FirebaseAuth.instance.currentUser;


      //if login is successful
      if(currentUser.uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set(Map());
        notifyParent(nameController.text);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        print(currentUser.email+ ' << email from sign up');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
