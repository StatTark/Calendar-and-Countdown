import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';

class NotificationPicker extends StatefulWidget {

  var radioValue;

  @override
  _NotificationPickerState createState() => _NotificationPickerState();
}

class _NotificationPickerState extends State<NotificationPicker> {

  var radioGroupValue;

  @override
  void initState() {
    super.initState();
    radioGroupValue = proTranslate["Zaman geldiğinde"][Language.languageIndex];
  }

  List<String> _choices = [
    proTranslate["Hiçbir zaman"][Language.languageIndex],
    proTranslate["Zaman geldiğinde"][Language.languageIndex],
    proTranslate["5 dakika öncesinde"][Language.languageIndex],
    proTranslate["15 dakika öncesinde"][Language.languageIndex],
    proTranslate["30 dakika öncesinde"][Language.languageIndex],
    proTranslate["1 saat öncesinde"][Language.languageIndex],
    proTranslate["12 saat öncesinde"][Language.languageIndex],
    proTranslate["1 gün öncesinde"][Language.languageIndex],
    proTranslate["3 gün öncesinde"][Language.languageIndex],
    proTranslate["1 hafta öncesinde"][Language.languageIndex],
  ];

  Widget notificationTimePicker() {
    return Container(
        height: 200,
        width: 75,
        padding: EdgeInsets.only(top: 8.0),
        child: ListView.builder(
            itemCount: _choices.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  child: RadioListTile(
                    title: Text(_choices[index]),
                    value: index,
                    groupValue: radioGroupValue,
                    onChanged: (currentRadio) {
                      setState(() {
                        radioGroupValue = currentRadio;
                        widget.radioValue = currentRadio;
                      });
                    },
                  ));
            }));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(proTranslate["Bildirim zamanı"][Language.languageIndex],style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
      children: <Widget>[
        Container(padding: EdgeInsets.only(left: 25.0), child: Text(proTranslate["Bildirim ne zaman çıksın ?"][Language.languageIndex],style: TextStyle(fontSize: 18),)),
        notificationTimePicker(),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                child: Text(
                  proTranslate["Geri"][Language.languageIndex],
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  proTranslate["Ayarla"][Language.languageIndex],
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
