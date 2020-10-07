import 'package:ajanda/databasehelper/dataBaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';

void navigateToSettingsDialog(context) async {
  var _db = DbHelper.instance;
  bool val = false;
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(proTranslate["Dikkat!"][Language.languageIndex]),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    proTranslate["Telefon üreticinizin Xiaomi, OnPlus veya Vivo olduğunu tespit ettik. Lütfen uygulamamızı arka planda çalışması için otomatik başlatmayı açın."][Language.languageIndex],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(proTranslate["Bir daha gösterme"][Language.languageIndex]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Checkbox(
                        value: val,
                        onChanged: (v) => setState(() {
                          val = v;
                        }),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text(proTranslate["Tamam"][Language.languageIndex]),
                      onPressed: () async {
                        await _db.updateWarning(val ? 1 : 0).then((value) => Navigator.pop(context));
                      },
                    ),
                    FlatButton(
                      child: Text(proTranslate["Ayarlara Git"][Language.languageIndex]),
                      onPressed: () async {
                        openAppSettings();
                        await _db.updateWarning(val ? 1 : 0).then((value) => Navigator.pop(context));
                      },
                    )
                  ],
                )
              ],
            );
          },
        );
      });
}
