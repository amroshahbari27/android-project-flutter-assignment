import 'package:flutter/material.dart';

class Confirm extends StatefulWidget {
  final  Function(dynamic) notifyParent;
  Confirm(this.nameController,this.passwordController,{ required this.notifyParent});
  final nameController ;
  final passwordController;
  @override
  _Confirm createState() => _Confirm(nameController,passwordController,this.notifyParent);
}
class _Confirm extends State<Confirm> {
  final  Function(dynamic) notifyParent;
  bool wrongConfirm =false ;
  String nameController = '';
  String passwordController = '';
  TextEditingController confirmationPassword =TextEditingController();
_Confirm(this.nameController ,
   this.passwordController,this.notifyParent );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(
        height: 163,
        child :ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text('Please confirm your password below:',
              )),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextField(
              obscureText: true,
              controller: confirmationPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: wrongConfirm ?'Passwords must match' :'Password',
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(150, 10, 150, 10),
              child : ElevatedButton(
                child:Text('Confirm',style: TextStyle(color: Colors.white)),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
                onPressed: (){
                  setState(() {
                    print(confirmationPassword.text );
                    print(passwordController);
                    print(nameController);
                    wrongConfirm = (confirmationPassword.text != passwordController);
                  });
                  if(!wrongConfirm){ //success
                    notifyParent('');
                  }
                },
              ))
        ]));
  }

  }
