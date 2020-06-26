
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webookapp/model/user_model.dart';
import 'package:webookapp/view_model/auth_provider.dart';
import 'package:webookapp/view_model/file_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:flutter/foundation.dart';

class CreateBookPage extends StatefulWidget{
  CreateBookPage({Key key}) : super(key:key);
  @override
  _CreateBookPageState createState(){
      return _CreateBookPageState();
  }
}
class _CreateBookPageState extends State<CreateBookPage>{

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController catController = TextEditingController();
  TextEditingController coverController = TextEditingController();
  TextEditingController bookController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //Can add more
  List<String> category = <String>[
    "Romance",
    "Thriller",
    "Fantasy",
    "Poetry",
    "Horror",
    "Action and Adventure",
    "Detective and Mystery",
    "Sci-Fi", 
    "Short Story"
  ];

  String selectedCat = "Romance";

  @override
  Widget build (BuildContext context){
    final auth = Provider.of<AuthProvider>(context);
    final fileUploader = Provider.of<FileProvider>(context);
    final pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/logo_transparent.png'),
        backgroundColor: Colors.white,
        title: new Text(
          "Create",
          style: new TextStyle(
          fontSize: 16,
           color: Colors.black
        )),
      ),
    
      body: Center(
        child: Form(
          key: _formKey,
          child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
              child: new ListView(
                shrinkWrap: true,
                children: <Widget> [
                  TextFormField(
                    controller: titleController,
                    maxLength: 25,
                    decoration: new InputDecoration(
                      hintText: "Title",
                      icon: new Icon(
                        Icons.title,
                        color: Colors.grey
                      )
                    ),
                    validator: (value) => value.isEmpty ? 'Title can\'t be empty' : null,
                  ),
                  TextFormField(
                    controller: descController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: new InputDecoration(
                      hintText: "Book Description",
                      icon: new Icon(
                        Icons.description,
                        color: Colors.grey
                      )
                    ),
                    validator: (value) => value.isEmpty ? 'Book Description can\'t be empty' : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                        children: <Widget> [
                          Icon(Icons.category, color: Colors.grey),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
                            child: new DropdownButton<String> (
                              icon: Icon(Icons.arrow_downward),
                              hint: Text("Select your category"),
                              value: selectedCat,
                              iconSize: 24,
                              elevation: 16,
                              items: category.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: new Text(category));
                              },
                              ).toList(),
                              onChanged: (String value) {
                                setState(() {
                                  selectedCat = value;
                                  catController.text = value;
                                });
                              },
                            ),
                          )
                        ]
                      )
                  ),
                  //Upload Image
                  Padding(
                    padding: EdgeInsets.fromLTRB(0,10,0,0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: new Text("Book Cover")
                        ),
                        Expanded(
                          child: new TextFormField(
                            style: new TextStyle(
                              fontSize: 12,
                            ),
                            controller: coverController,
                            enabled: false,
                          )
                        ),
                        Expanded(
                          child: new RaisedButton(
                            child: Text("Upload Image"),
                            onPressed: () {
                              openFileExplorer() async {
                                try {
                                  coverController.text = await FilePicker.getFilePath(type: FileType.image);
                                } on PlatformException catch (e) {
                                  print('Unsupported Operation ' + e.toString());
                                }

                              }
                              openFileExplorer();
                            }
                            )
                          )
                      ],
                    ),
                  ),
                  //Document Upload
                  Padding(
                    padding: EdgeInsets.fromLTRB(0,10,0,0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: new Text("eBook (.pdf)")
                        ),
                        Expanded(
                          child: TextFormField(
                            style: new TextStyle(
                              fontSize: 12,
                            ),
                            controller: bookController,
                            enabled: false,
                            validator: (value) => value.isEmpty ? 'A document must be uploaded': null,
                            )
                        ),
                        Expanded(
                          child: new RaisedButton(
                            child: Text("Upload Book"),
                            onPressed: () {
                              openFileExplorer() async {
                                try {
                                  bookController.text = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: ['.epub+zip']);
                                } on PlatformException catch (e) {
                                  print('Unsupported Operation ' + e.toString());
                                }
                              }
                              openFileExplorer();
                            }
                            )
                          )
                      ],
                    ),
                  ),
                  //Upload Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 30.0, 40, 30),
                    child: new RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      color: Colors.blue,
                      child: new Text(
                        "Upload My Work",
                        style: new TextStyle(
                          fontSize: 16,
                          color: Colors.white
                        )),
                      onPressed: () {
                        upload () async {
                          if(_formKey.currentState.validate()){
                            await pr.show();
                            User user = await auth.retrieveUser(); 

                            await fileUploader.uploadBook(
                              user, 
                              titleController.text, 
                              descController.text, 
                              catController.text,
                              coverController.text, 
                              bookController.text);

                            final snackBar = SnackBar(
                              content: Text('Yay! Your work has been uploaded!'),
                              duration: Duration(seconds: 3),);

                            await pr.hide();

                            titleController.clear();
                            descController.clear();
                            coverController.clear();
                            bookController.clear();
                            Scaffold.of(context).showSnackBar(snackBar);

                            print("Submitted");
                          } else {
                            print("Not Submitted");
                          }
                        }
                        upload();
                      },
                    )
                  ),
                ]
              )
            ),
          ],
        ),
      ),
      )
      // bottomNavigationBar: BottomNavBar(),
    );
  }
  
}