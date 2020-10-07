import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';

Future<void> showMyDialog(context, {String title, String message, Function function}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(proTranslate['Hayır'][Language.languageIndex], style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(proTranslate['Evet'][Language.languageIndex], style: TextStyle(fontSize: 16)),
            onPressed: () async {
              Navigator.of(context).pop();
              await function();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showWarningDialog(
    {@required context, @required String explanation}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(proTranslate['Dikkat!'][Language.languageIndex]),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(explanation),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(proTranslate['Tamam'][Language.languageIndex]),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showButtonAboutDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(proTranslate['Dikkat!'][Language.languageIndex]),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.add_circle),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        proTranslate["Ekleyeceğiniz etklinlik için tarih ve saati ayarlamanıza yardımcı olur."][Language.languageIndex],
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 5,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.notifications_active),
                  ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          proTranslate["Etkinliğiniz için size hatırlatma bildirimi hazırlar."][Language.languageIndex],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 5,
                        ),
                      )),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.mail),
                  ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          proTranslate["Ayarladığınız maili zamanı geldiğinde E-mail servisine yönlendirir."][Language.languageIndex],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 5,
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(proTranslate['Tamam'][Language.languageIndex]),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

