
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class Profile extends StatefulWidget {
  final  Function(dynamic) notifyParent;
  Profile(this.email,{ required this.notifyParent}) ;
  final email ;
  @override
  _Profile createState() => _Profile(email,this.notifyParent);
}

class _Profile extends State<Profile> {
  var email ;
  File? _image;
  NetworkImage? toShow;
  final  Function(dynamic) notifyParent;
  _Profile(this.email,this.notifyParent);
  @override
  Widget build(BuildContext context) {
      if(toShow==null)downloadPic();
    return Container(padding: EdgeInsets.fromLTRB(2, 2, 5, 2),color:Colors.white,child:SingleChildScrollView(
        child:Row(children: [ClipRRect(borderRadius:BorderRadius.circular(100),
          child:
          toShow == null ?
          InkWell(child: CircleAvatar(radius: 50,child: Icon(Icons.add_a_photo_outlined),backgroundColor: Colors.green,),
            onTap: (){
              getImage();
            },)
              :
          CircleAvatar(
              radius: 50,
              backgroundImage: toShow
          ),),
          Column(children: [
            Text(' '+email,style: TextStyle(fontSize: 16),),
            ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
                onPressed: (){
                getImage();
                },
                child: Text('Change avatar',))],)],)));
  }
  //image get from gallery
  Future<void> getImage() async {
    PickedFile? selectedFile = await ImagePicker().getImage(source: ImageSource.gallery );
    // ignore: unnecessary_null_comparison
    if(selectedFile == null){
      var snackBar = SnackBar(content: Text('No image selected'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //show snack bar of erorr and exit .
      return;
    }
    File selected = File(selectedFile.path);
    _image=selected;
    //TODO update database from here
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(email);
    UploadTask uploadTask = ref.putFile(_image);
    await uploadTask.then((res) {
      res.ref.getDownloadURL();
    });
    try{
      var url = await ref.getDownloadURL();
      print('uploadid pic url : '+url);
      setState(() {
        toShow=NetworkImage(url);
      });
    }catch(e){
      print("error");
    }
  }
 void downloadPic() async {
    final ref = FirebaseStorage.instance.ref().child(email);
// no need of the file extension, the name will do fine.
    var url ;
      try{

        print('start');
        url = await ref.getDownloadURL();
        print('end');

        setState(() {
          toShow=NetworkImage(url);
        });
      }catch( e){
        print('exception...........');
        print(e.toString());
      }

  }

}
