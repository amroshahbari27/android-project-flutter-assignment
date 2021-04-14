
//------------------------ Saved Suggestions --------------------------------

import 'package:flutter/material.dart';
class Saved extends StatefulWidget {
  final  Function(dynamic) notifyParent;
  Saved(this._saved,{required this.notifyParent}) ;
  final _saved ;
  @override
  _Saved createState() => _Saved(_saved,this.notifyParent);
}

class _Saved extends State<Saved> {
  var _saved = <String>{};
  final  Function(dynamic) notifyParent;
  _Saved(this._saved,this.notifyParent);
  @override
  Widget build(BuildContext context) {
      final tiles = _saved.map(
            (String pair) {
          return ListTile(
            title: Text(
              pair,
            ),
            trailing: Icon( Icons.delete_outline ,
              color:Colors.red,
            ),
            onTap: () {
              // HW2
              setState(() {
                _saved.remove(pair);

              });
              notifyParent(pair);

              //HW1
              // final snackBar = SnackBar(content: Text('Deletion is not implemented yet'));
              //ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          );
        },
      );
      var divided = <Widget>[];
      if(tiles.isNotEmpty)
        divided = ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList();

      return Scaffold(
        appBar: AppBar(
          title: Text('Saved Suggestions'),
        ),
        body: divided.isNotEmpty ? ListView(children:  divided ) : Center(child: Text('No Saved Suggestions')),
      );
    }
  }