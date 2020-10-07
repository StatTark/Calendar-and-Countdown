import 'package:flutter/material.dart';

import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';
import '../databasemodels/events.dart';
import '../events/eventEditting.dart';

class Details extends StatefulWidget {
  final Event event;

  const Details({Key key, this.event}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Map<int, String> _periodicTexts = {
    0: "",
    1: proTranslate["Günlük tekrarlı"][Language.languageIndex],
    2: proTranslate["Haftalık tekrarlı"][Language.languageIndex],
    3: proTranslate["Aylık tekrarlı"][Language.languageIndex],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(proTranslate["Detaylar"][Language.languageIndex]),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 25,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.event.title,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 35.0),
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Row(children: <Widget>[
                      Text(
                        widget.event.date +
                            "${widget.event.startTime != "null" ? ("  " + widget.event.startTime + "-" + widget.event.finishTime) : " - ${proTranslate["Tüm gün"][Language.languageIndex]}"}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ]),
                  ),
                  if ((widget.event.recipient != "" || widget.event.recipient.length != 0) ||
                      (widget.event.periodic != 0))
                    Container(
                      padding: const EdgeInsets.only(right: 64.0),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black38,
                      ),
                    ),
                  if (widget.event.recipient != "" || widget.event.recipient.length != 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.mail_outline),
                          Text(
                            proTranslate["Mail atılacak"][Language.languageIndex] +
                                printMails(widget.event.recipient),
                            maxLines: widget.event.recipient.split(",").length + 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  if (widget.event.periodic != 0)
                    Container(
                      padding: const EdgeInsets.only(left: 12.0, top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.refresh),
                          Column(
                            children: [
                              Text(
                                widget.event.periodic != 4
                                    ? _periodicTexts[widget.event.periodic]
                                    : calcDays(widget.event.frequency),
                                maxLines: 9,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Card(
              elevation: 25,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.event.desc,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (EventEdit(
                                    event: Event(
                                        id: widget.event.id,
                                        title: widget.event.title,
                                        date: widget.event.date,
                                        startTime: widget.event.startTime,
                                        finishTime: widget.event.finishTime,
                                        desc: widget.event.desc,
                                        isActive: widget.event.isActive,
                                        choice: widget.event.choice,
                                        countDownIsActive: widget.event.countDownIsActive,
                                        attachments: widget.event.attachments,
                                        cc: widget.event.cc,
                                        bb: widget.event.bb,
                                        recipient: widget.event.recipient,
                                        subject: widget.event.subject,
                                        body: widget.event.body,
                                        periodic: widget.event.periodic,
                                        frequency: widget.event.frequency),
                                  ))));
                    },
                    elevation: 18,
                    color: Colors.blue,
                    child: Text(
                      proTranslate["Düzenle"][Language.languageIndex],
                      style: TextStyle(fontSize: 18),
                    ),
                    splashColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String calcDays(String frequency) {
    Map<int, String> weekdayToDay = {
      0: proTranslate["Pazartesi"][Language.languageIndex],
      1: proTranslate["Salı"][Language.languageIndex],
      2: proTranslate["Çarşamba"][Language.languageIndex],
      3: proTranslate["Perşembe"][Language.languageIndex],
      4: proTranslate["Cuma"][Language.languageIndex],
      5: proTranslate["Cumartesi"][Language.languageIndex],
      6: proTranslate["Pazar"][Language.languageIndex]
    };

    String result = "${proTranslate["Tekrar günleri"][Language.languageIndex]} :\n";

    for (int i = 0; i < frequency.length; i++) {
      if (frequency[i] == "1") {
        result += "- ${weekdayToDay[i]}\n";
      }
    }

    /// Sondaki fazla virgulden kurtulmak icin
    result = result.substring(0, result.length - 1);
    return result;
  }

  String printMails(String recipients) {
    String result = recipients.split(",").length > 1
        ? " ${proTranslate["kişiler"][Language.languageIndex]} :\n"
        : " ${proTranslate["kişi"][Language.languageIndex]} :\n";
    recipients.split(",").forEach((element) {
      result += "> " + element.trim() + "\n";
    });
    return result;
  }
}
