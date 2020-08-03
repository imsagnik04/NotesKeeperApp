//import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:intl/intl.dart';


// ignore: must_be_immutable
class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  NoteDetailState(this.note, this.appBarTitle);
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    titleController.text = note.title;
    descriptionController.text = note.description;


    return WillPopScope(


      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }
          ),
        ),
        body: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Padding(
            padding:  EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                //First Element
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem)  {
                        return DropdownMenuItem<String> (
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      } ).toList(),

                      style: textStyle,

                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }
                  ),
                ),

                //Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    style: textStyle,
                    controller: titleController,
                    validator: (String value) {
                      if(value.isEmpty) {
                        return 'Please Enter A Title.';
                      }
                    },
                    onChanged: (value)  {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )
                    ),
                  ),
                ),

                //Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value)  {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )
                    ),
                  ),
                ),

                //Forth Element

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[

                      //Save Button
                      Expanded(
                          child:  RaisedButton(
                            onPressed: (){
                              debugPrint("Save button pressed");
                              _save();
                            },
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              _getUpdateOrSave(),
                              textScaleFactor: 1.5,
                            ),

                          )
                      ),

                      Container(width: 5.0,),

                      //Delete Button
                      Expanded(
                          child:  RaisedButton(
                            onPressed: (){
                              debugPrint("Delete button pressed");
                              _delete();
                            },
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),

                          )
                      ),
                    ],
                  ),
                )
              ],
            ),

          ),
        )

      ),


      // ignore: missing_return
      onWillPop: () {
        moveToLastScreen();
      },
    );
  }

  String _getUpdateOrSave()  {
    String _button;
    if  (note.id == null) {
      _button = 'Save';
    }
    else  {
      _button = 'Update';
    }
    return _button;
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Convert the String priority to integer before saving to Database.
  void updatePriorityAsInt(String value)  {
    switch(value) {
      case  'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert the Integer priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch(value) {
      case 1:
        priority = _priorities[0];  //'High'
        break;
      case 2:
        priority = _priorities[1];  //'Low'
        break;
    }
    return priority;
  }

  //Update the title of Note object
  void updateTitle()  {
    note.title = titleController.text;
  }
  //Update the description of Note object
  void updateDescription()  {
    note.description = descriptionController.text;
  }

  //Save data to database
  void _save()  async {
    if  (_formKey.currentState.validate())  {
      moveToLastScreen();
      note.date = DateFormat.yMMMd().format(DateTime.now());

      int result;
      if(note.id != null) {
        result = await helper.updateNote(note);
      }
      else{
        result = await helper.insertNote(note);
      }

      if(result != 0) {
        _showAlertDialog('Status', _getStatusString(result));
      }
      else {
        _showAlertDialog('Status', _getStatusString(result));
      }
    }
  }
  
  void _delete()  async {

    moveToLastScreen();
    //note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id == null) {
      _showAlertDialog('Status', 'No Note Was Deleted');
      //result = await helper.updateNote(note);
      return;
    }
    result = await helper.deleteNote(note.id);
    if(result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    }
    else {
      _showAlertDialog('Status', 'Problem Deleting Note');
    }
  }
  
  String _getStatusString  (int res)  {
    String _status;
    if(res != 0)  {
      if(note.id == null) {
        _status = 'Note Saved Successfully';
      }
      else  {
        _status = 'Note Updated Successfully';
      }
    }
    else  {
      if(note.id == null) {
        _status = 'Problem Saving Note';
      }
      else  {
        _status = 'Problem Updating Note';
      }
    }
    return _status;
  }
  
  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

}