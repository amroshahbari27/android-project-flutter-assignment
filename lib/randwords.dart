
import 'dart:async';
import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_me/profile.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'SavedSugg.dart';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class RandomWords extends StatefulWidget {
  final  Function(dynamic) notifyParent;
  final snappingsheet;
  RandomWords(this.snappingsheet,{ required this.notifyParent});
  @override
  State<RandomWords> createState() => _RandomWordsState(snappingsheet,notifyParent);
}
class _RandomWordsState extends State<RandomWords> {
  final  Function(dynamic) notifyParent;
  final _suggestions = <String>[];
  final _saved = <String>{};
  final _biggerFont = TextStyle(fontSize: 18.0);
  bool isLoggedIn = false;
  String userEmail= '';
  SnappingSheetController snappingSheetController;
  _RandomWordsState(this.snappingSheetController,this.notifyParent);
  refresh(dynamic toRemove) {
    setState(() {
        updateDatabase();
       _saved.remove(toRemove);
    });
  }
  logined(dynamic login) async {
    if(FirebaseAuth.instance.currentUser!=null)
      print('trueeeeeeeeeeeeee');
    String userId= FirebaseAuth.instance.currentUser.uid;
    CollectionReference userFav = FirebaseFirestore.instance.collection('users');
    print(userId);
    List<dynamic> mylist=[];
    await userFav.doc(userId)?.get()?.then((documentSnapshot) async =>
        mylist =documentSnapshot.data()[userId]);
    print('trueeeeeeeeeeeeee');
    setState(() {
      isLoggedIn=true;
      userEmail = login;

      _saved.addAll(mylist.cast<String>());
      updateDatabase();


    }
    );
    print('Email ????'+userEmail);
  }
  // #docregion _buildSuggestions
  Widget _buildSuggestions() {
    return ListView.builder(
      reverse: false,
      padding: EdgeInsets.all(16.0),
      itemBuilder: /*1*/ (context, i) {
        if (i.isOdd) return Divider();
        /*2*/

        final index = i ~/ 2; /*3*/
        if (index >= _suggestions.length) {
          List<String> toadd= [] ;
          generateWordPairs().take(10).forEach((element) {
            toadd.add(element.toString());
          });
          _suggestions.addAll(toadd); /*4*/
        }
        return _buildRow(_suggestions[index]);
      },
      //physics: const NeverScrollableScrollPhysics(); // if added can stop scrolling to achieve no bug.
    );
  }

  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(String pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
          updateDatabase();
        });
      },
    );
  }

//todo :  add the sheet her below.
  bool tapped = false;
  bool isDragged=false;
  final openFactor = 0.2;
  final closeFactor = 0.03;
  var factor = 0.03;
  @override
  Widget build(BuildContext context) {
    print('beford build email'+userEmail);
    print('is Dragged : ' + isDragged.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          IconButton(icon: isLoggedIn ? Icon(Icons.exit_to_app) : Icon(Icons.login),
              onPressed:isLoggedIn ? signOut : _loginscreen),
        ],
      ),
      body: SnappingSheet(
        // behind the sheet.
          onSheetMoved: (double x){
            setState(() {
              print('onSheetMoved');
              if(isLoggedIn)
                isDragged=true;
            });
            },
          onSnapCompleted:(double x,SnappingPosition y){
            setState(() {
            if(y ==SnappingPosition.factor(positionFactor: openFactor)){
              factor = openFactor;
              print('onSheetCompleted');
              isDragged=true;
            }else if(y ==SnappingPosition.factor(positionFactor: closeFactor)){
              factor = closeFactor;
              isDragged=false;
            }
            });
          },
          initialSnappingPosition: SnappingPosition.factor(positionFactor: closeFactor),
          snappingPositions: [SnappingPosition.factor(positionFactor: closeFactor),
            SnappingPosition.factor(positionFactor: openFactor)],
          lockOverflowDrag:false,
          child:Stack(children: [_buildSuggestions(), !isDragged  ? Container() :
          (isLoggedIn ? BlurryEffect(0.9,2.6,Colors.white):Container())],),
          //initialSnappingPosition:  ,
          controller:  snappingSheetController,
          grabbing: !isLoggedIn ? SizedBox(height: 0,width: 0,):SafeArea(
              child: Drawer(
                  child:InkWell(
                    child:   ListTile(tileColor:Colors.grey,leading:Text('Welcome back, '+userEmail),
              trailing: (factor > closeFactor) ? Icon(Icons.arrow_drop_down): Icon(Icons.arrow_drop_up),),
            onTap: (){
              setState(() {
                print('onTap');

                factor = (factor == openFactor ) ? (closeFactor) : (openFactor);
                notifyParent(factor);
                if(factor > closeFactor){
                  isDragged = true;
                }else if(factor < openFactor){
                  isDragged = false;
                }
              });
            },
          ))) ,
          grabbingHeight:!isLoggedIn  ? 0 : 50,
          sheetBelow: !isLoggedIn  ? SnappingSheetContent(child: Container()) : SnappingSheetContent(
            draggable: true,
            child:Profile( userEmail,notifyParent: (dynamic newimage) {  }) ,
          )) ,
    );
  }
  void signOut()async{
     updateDatabase(); // to synchronize database in case one of the small updates failed.
    _signOut();
    setState(() {
      isDragged=false;
      isLoggedIn=false;
      userEmail='';
    });
    //notifyParent('logged out');
  }
  void updateDatabase(){
    var upload=_saved.toList(); // update database
    List<String> toSave = [];
    for(int i=0 ; i<upload.length ; i++){
      toSave.add(upload[i].toString());
    }
    updateFavoritesDataBase(toSave);
  }
  //TODO: create a toJSON
  //here we need to know wether we create base on sign up , or by use .
  Future<void> updateFavoritesDataBase(List<String> tosend) async {
    String userId= FirebaseAuth.instance.currentUser.uid;

    CollectionReference userFav = FirebaseFirestore.instance.collection('users');
    print(userId);
    userFav.doc(userId)?.update(<String,dynamic>{userId :tosend});
    //userFav.add(upload.asMap());
    //userFav.doc().add();*/
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLoggedIn = false;
      _saved.clear();

    });
  }
  // #enddocregion RWS-build
  void _loginscreen() {
    Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Login(notifyParent: logined),
        ));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (_) => Saved(_saved,notifyParent: refresh), //...to here.
      ),
    );
  }
}
class BlurryEffect extends StatelessWidget {
  final double opacity;
  final double blurry;
  final Color shade;

  BlurryEffect(this.opacity,this.blurry,this.shade);

  @override  Widget build(BuildContext context) {
    return Container(
      child: ClipRect(
        child:  BackdropFilter(
          filter:  ImageFilter.blur(sigmaX:blurry, sigmaY:blurry),
          child:  Container(
            width: double.infinity,
            height:  double.infinity,
            decoration:  BoxDecoration(color: shade.withOpacity(opacity)),
          ),
        ),
      ),
    );
  }
}
