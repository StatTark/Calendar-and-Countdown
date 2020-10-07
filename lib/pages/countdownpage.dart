import 'package:flutter/material.dart';
import 'dart:async';

import '../databasehelper/dataBaseHelper.dart';
import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';

class CountDownPage extends StatefulWidget {
  @override
  _CountDownPageState createState() => _CountDownPageState();
}

class _CountDownPageState extends State<CountDownPage> {
  var _db = DbHelper.instance;

  var now = DateTime.now();

  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(
      Duration(seconds: 1),
          (Timer timer) => setState(
            () {
          now = DateTime.now();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _db.getEventsByOrder(2),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(child: Text(proTranslate["Yükleniyor....."][Language.languageIndex])),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (snapshot.data[index].isActive == 1) {
                      var date = snapshot.data[index].startTime == "null"
                          ? DateTime.parse(snapshot.data[index].date)
                          : DateTime.parse(
                          snapshot.data[index].date + " " + snapshot.data[index].startTime);
                      return Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: ((date.difference(now).inSeconds -
                                    date.difference(now).inMinutes * 60) <
                                    0)
                                    ? [Colors.deepOrange, Colors.redAccent, Colors.red]
                                    : [
                                  Colors.blueGrey,
                                  Colors.blue,
                                  Colors.cyan,
                                  Colors.lightBlueAccent,
                                ])),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              snapshot.data[index].title,
                              style: infoStyles(),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      proTranslate["GÜN"][Language.languageIndex],
                                      style: infoStyles(),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Text(
                                      (date.difference(now).inDays < 0)
                                          ? "0"
                                          : date.difference(now).inDays.toString(),
                                      style: inputStyles(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      proTranslate["SAAT"][Language.languageIndex],
                                      style: infoStyles(),
                                    ),
                                    Text(
                                      ((date.difference(now).inHours -
                                          date.difference(now).inDays * 24) <
                                          0)
                                          ? "0"
                                          : (date.difference(now).inHours -
                                          date.difference(now).inDays * 24)
                                          .toString(),
                                      style: inputStyles(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      proTranslate["DAKİKA"][Language.languageIndex],
                                      style: infoStyles(),
                                    ),
                                    Text(
                                      ((date.difference(now).inMinutes -
                                          date.difference(now).inHours * 60) <
                                          0)
                                          ? "0"
                                          : (date.difference(now).inMinutes -
                                          date.difference(now).inHours * 60)
                                          .toString(),
                                      style: inputStyles(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      proTranslate["SANİYE"][Language.languageIndex],
                                      style: infoStyles(),
                                    ),
                                    Text(
                                      ((date.difference(now).inSeconds -
                                          date.difference(now).inMinutes * 60) <
                                          0)
                                          ? "0"
                                          : (date.difference(now).inSeconds -
                                          date.difference(now).inMinutes * 60)
                                          .toString(),
                                      style: inputStyles(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              snapshot.data[index].date,
                              style: infoStyles(),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  });
            }
          }),
    );
  }
}

TextStyle infoStyles() {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black38,
  );
}

TextStyle inputStyles() {
  return TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black38,
  );
}
