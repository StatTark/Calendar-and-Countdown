import 'package:ajanda/helpers/constants.dart';
import 'package:ajanda/helpers/languageDictionary.dart';
import 'package:flutter/material.dart';

import '../Widgets/dropdown.dart';
import '../databasehelper/dataBaseHelper.dart';
import '../databasemodels/events.dart';
import '../events/addevent.dart';
import '../helpers/helperFunctions.dart';

class CalanderEvent extends StatefulWidget {
  final tarih;

  CalanderEvent(this.tarih);

  @override
  _CalanderEventstate createState() => _CalanderEventstate();
}

class _CalanderEventstate extends State<CalanderEvent> {
  var _db = DbHelper.instance;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          proTranslate["Etkinlik"][Language.languageIndex],
          style: TextStyle(fontSize: 22),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddEvent(inputDate: widget.tarih)));
              })
        ],
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: FutureBuilder(
          future: _db.getEventCalander(widget.tarih),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Text(proTranslate["Yükleniyor....."][Language.languageIndex]),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(6.0, 16.0, 8.0, 16.0),
                      child: Card(
                        elevation: 25,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
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
                                    Text(
                                      snapshot.data[index].desc,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2 - 32,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width / 4,
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
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        color: (calcRemaining(snapshot.data[index].date,
                                            snapshot.data[index].startTime,snapshot.data[index].finishTime,)
                                            .contains(proTranslate["Geçti"][Language.languageIndex]))
                                            ? Colors.blueGrey
                                            : Colors.blue,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          calcRemaining(snapshot.data[index].date,
                                              snapshot.data[index].startTime,snapshot.data[index].finishTime,),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                  ],
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
