import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';
import '../widgets/showDialog.dart';


class EmailSender extends StatefulWidget {
  final List<String> attacs;
  final cctext;
  final bbtext;
  final recipienttext;
  final subjecttext;
  final bodytext;

  EmailSender({
    Key key,
    this.attacs,
    this.cctext,
    this.bbtext,
    this.recipienttext,
    this.subjecttext,
    this.bodytext,
  }) : super(key: key);

  @override
  _EmailSender createState() => _EmailSender();
}

class _EmailSender extends State<EmailSender> {
  List<String> attachments = [];

  final _ccController = TextEditingController();

  final _bbcController = TextEditingController();

  final _recipientController = TextEditingController();

  final _subjectController = TextEditingController();

  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recipienttext != null) {
      setState(() {
        attachments = widget.attacs;
        _ccController.text = widget.cctext;
        _bbcController.text = widget.bbtext;
        _recipientController.text = widget.recipienttext;
        _subjectController.text = widget.subjecttext;
        _bodyController.text = widget.bodytext;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(proTranslate['Mail gönderme'][Language.languageIndex]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            List<dynamic> sendBack = sendBackFunc();
            Navigator.pop(context, sendBack);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help_outline,size: 36,),
              onPressed: () {
                showWarningDialog(
                    context: context,
                    explanation: proTranslate["Eğer birden fazla alıcı, cc veya bbc değeri girecekseniz her mail arasına virgül koymalısınız.\n\n(örnek: ornek@gmail.com , ornek2@gmail.com)"][Language.languageIndex]);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: proTranslate['Alıcı adresi '][Language.languageIndex],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _ccController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CC',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _bbcController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'BBC',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: proTranslate['Konu'][Language.languageIndex],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _bodyController,
                  maxLines: 10,
                  decoration: InputDecoration(labelText:"Mail", border: OutlineInputBorder()),
                ),
              ),
              ...attachments.map(
                    (item) => Text(
                  item,
                  overflow: TextOverflow.fade,
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 3 + 16,
                      child: RaisedButton(
                        color: Colors.blue,
                        elevation: 18,
                        onPressed: _pickerImage,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                            Text(
                              proTranslate["  Resim ekle"][Language.languageIndex],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        splashColor: Colors.blue,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 3 + 16,
                      child: RaisedButton(
                        color: Colors.blue,
                        onPressed: _pickerFile,
                        elevation: 18,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.insert_drive_file,
                              color: Colors.white,
                            ),
                            Text(
                              proTranslate["  Dosya Ekle"][Language.languageIndex],
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        splashColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: RaisedButton(
                    color: Colors.blue,
                    onPressed: save,
                    elevation: 18,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        Text(proTranslate["  Kaydet"][Language.languageIndex], style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    splashColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<dynamic> sendBackFunc(){
    List<dynamic> sendBack = [];
    sendBack.add(attachments);
    sendBack.add(_ccController.text);
    sendBack.add(_bbcController.text);
    sendBack.add(_recipientController.text);
    sendBack.add(_subjectController.text);
    sendBack.add(_bodyController.text);
    return sendBack;
  }

  void save() {
    if (_recipientController.text == "") {
      showWarningDialog(context: context, explanation: proTranslate['Alıcı mail boş bırakılmaz!'][Language.languageIndex]);
    } else if (_subjectController.text == "") {
      showWarningDialog(context: context, explanation: proTranslate['Konu boş bırakılamaz!'][Language.languageIndex]);
    } else {
      List<dynamic> sendBack = sendBackFunc();
      Navigator.pop(context, sendBack);
    }
  }

  void _pickerImage() async {
    try{
      final File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        attachments.add(pick.path);
      });
    }catch(e){
      print("[ERROR] [MAILSENDER] [_pickerImage] $e");
    }
  }


  void _pickerFile() async {
    try{
      List<File> files = await FilePicker.getMultiFile(
        type: FileType.custom,
      );
      setState(() {
        for(int i = 0;i<files.length;i++){
          if(files[i].path.endsWith(".png") || files[i].path.endsWith(".jpeg") || files[i].path.endsWith(".jpg") || files[i].path.endsWith(".gif")){
            showWarningDialog(context: context, explanation: proTranslate["Resimleri resim ekle butonundan ekleyiniz."][Language.languageIndex]);
            continue;
          }
          attachments.add(files[i].path);
        }
      });
    }catch(e){
      print("[ERROR] [MAILSENDER] [_pickerFile] $e");
    }
  }
}
