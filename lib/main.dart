import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/randwords.dart';
import 'package:snapping_sheet/snapping_sheet.dart';


//void main() => runApp(MyApp());
class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
            body: Center(
                child: Text(snapshot.error.toString(),
                    textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {

        return MyApp();
      }
      return Center(child: CircularProgressIndicator());
        },
    );
  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
}
// #docregion MyApp
class _MyApp extends State<MyApp> {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    final snappingSheetController = SnappingSheetController();
    return MaterialApp(
      theme:ThemeData(primaryColor: Colors.red),
      home: RandomWords(snappingSheetController,
      notifyParent: (dynamic factor) { snappingSheetController.snapToPosition(SnappingPosition.factor(positionFactor: factor)); },),);
  }
  }
//Row(children: [Container(child:Text('Welcome Back'
     //    ,style:TextStyle(fontSize:16,color:Colors.black))),Container( child:Icon(Icons.arrow_upward_sharp)),],)