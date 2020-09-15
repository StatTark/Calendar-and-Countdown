import 'package:ajanda/helpers/constants.dart';
import 'package:ajanda/helpers/languageDictionary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../databasehelper/dataBaseHelper.dart';
import '../databasemodels/events.dart';
import '../helpers/helperFunctions.dart';
import '../widgets/dropdown.dart';

class Soclose extends StatefulWidget {
  int index = 0;

  Soclose({this.index});

  @override
  _Closesevents createState() => _Closesevents();
}

class _Closesevents extends State<Soclose> {
  var _db = DbHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _db.getEventsByOrder(widget.index),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(child: Text(proTranslate["Yükleniyor....."][Language.languageIndex])),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                      child: Card(
                        elevation: 25,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                        '${snapshot.data[index].title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 28),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 22,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text("${snapshot.data[index].date}"),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.watch_later,
                                                  size: 22,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                    "${snapshot.data[index].startTime == "null" ? proTranslate["Tüm gün"][Language.languageIndex] : "${snapshot.data[index].startTime} - ${snapshot.data[index].finishTime}"}"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data[index].desc,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        child: DropDown(Event(
                                          id: snapshot.data[index].id,
                                          title: snapshot.data[index].title,
                                          date: snapshot.data[index].date,
                                          startTime: snapshot.data[index].startTime,
                                          finishTime: snapshot.data[index].finishTime,
                                          desc: snapshot.data[index].desc,
                                          isActive: snapshot.data[index].isActive,
                                          choice: snapshot.data[index].choice,
                                          countDownIsActive: snapshot.data[index].countDownIsActive,
                                          attachments: snapshot.data[index].attachments,
                                          cc: snapshot.data[index].cc,
                                          bb: snapshot.data[index].bb,
                                          recipient: snapshot.data[index].recipient,
                                          subject: snapshot.data[index].subject,
                                          body: snapshot.data[index].body,
                                          periodic: snapshot.data[index].periodic,
                                          frequency: snapshot.data[index].frequency,
                                        )),
                                      ),
                                      Container(
                                        height: 105,
                                        width: 105,
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          color: (calcRemaining(snapshot.data[index].date,
                                              snapshot.data[index].startTime)
                                              .contains(proTranslate["Geçti"][Language.languageIndex]))
                                              ? Colors.blueGrey
                                              : Colors.blue,
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            calcRemaining(snapshot.data[index].date,
                                                snapshot.data[index].startTime),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 22),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
