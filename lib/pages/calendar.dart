import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart" show CalendarCarousel;
import 'package:intl/intl.dart' show DateFormat;

import '../databasehelper/dataBaseHelper.dart';
import '../events/addevent.dart';
import '../events/calenderEvent.dart';
import '../widgets/showDialog.dart';
import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';

class FutureCalendar extends StatelessWidget {
  final DbHelper _helper = DbHelper.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _helper.getEventList(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text(proTranslate["Yükleniyor...."][Language.languageIndex]),
            ),
          );
        } else {
          return Calendar(
            eventList: snapshot.data,
          );
        }
      },
    );
  }
}

class Calendar extends StatefulWidget {
  final eventList;

  Calendar({Key key, this.eventList}) : super(key: key);

  @override
  _CalendarState createState() => new _CalendarState(eventList);
}

class _CalendarState extends State<Calendar> {
  final eventList;

  _CalendarState(this.eventList);

  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();

  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Colors.deepOrangeAccent,
    ),
  );

  EventList<Event> _markedDateMap = new EventList<Event>();

  CalendarCarousel _calendarCarousel, _calendarCarouselNoHeader;

  @override
  void initState() {
    super.initState();
    setState(() {
      for (var event in eventList) {
        _markedDateMap.add(
            DateTime.parse(event.date),
            Event(
              date: DateTime.parse(event.date),
              title: event.title,
              icon: _eventIcon,
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Example with custom icon
    _calendarCarousel = CalendarCarousel<Event>(
      locale: Language.languageIndex==0?'tr':'en',
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate = date);
        events.forEach((event) => print(event.title));
      },
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      headerText: proTranslate['Haftalık Takvim'][Language.languageIndex],
      weekFormat: true,
      markedDatesMap: _markedDateMap,
      height: 200.0,
      selectedDateTime: _currentDate2,
      showIconBehindDayText: true,

      /// daysHaveCircularBorder : null for not rendering any border, true for circular border, false for rectangular border
      daysHaveCircularBorder: false,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      selectedDayTextStyle: TextStyle(
        color: Colors.orangeAccent,
      ),
      todayTextStyle: TextStyle(
        color: Colors.orangeAccent,
      ),
      markedDateIconBuilder: (event) {
        return event.icon;
      },
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.green,
      markedDateMoreShowTotal: true, // null for not showing hidden events indicator
    );

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      locale: Language.languageIndex==0?'tr':'en',
      todayBorderColor: Colors.green,
      onDayPressed: (DateTime date, List<Event> events) {
        print("Ondaypreesed");
        this.setState(() => _currentDate2 = date);
        setState(() {
          var newdate = date.toString().split(" ")[0];
          final _helper = DbHelper.instance;
          Future<bool> sorgu = _helper.isEventInDb('$newdate');
          sorgu.then((onValue) {
            if (onValue == true) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CalanderEvent(newdate)));
            } else {
              showMyDialog(context,
                  title: proTranslate["Boş Gün"][Language.languageIndex],
                  message: proTranslate['Bu tarihe etkinlik eklemek ister misiniz ?'][Language.languageIndex], function: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddEvent(
                              inputDate: newdate,
                            )));
                  });
            }
          });
        });
      },
      daysHaveCircularBorder: false,
      showOnlyCurrentMonthDate: false,
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      // firstDayOfWeek: 4,
      markedDatesMap: _markedDateMap,
      height: 420.0,
      selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomShapeBorder: CircleBorder(side: BorderSide(color: Colors.blue)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.blue,
      ),
      showHeader: false,
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
      todayButtonColor: Colors.orange,
      selectedDayTextStyle: TextStyle(
        color: Colors.orange,
      ),
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        print('[CALENDAR] long pressed date $date');
      },
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //custom icon
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: _calendarCarousel,
          ),
          Container(
            margin: EdgeInsets.only(
              top: 30.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: new Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      translateMonths(_currentMonth),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    )),
                FlatButton(
                  child: Text(proTranslate['GERİ'][Language.languageIndex]),
                  onPressed: () {
                    setState(() {
                      _targetDateTime = DateTime(_targetDateTime.year, _targetDateTime.month - 1);
                      _currentMonth = DateFormat.yMMM().format(_targetDateTime);
                    });
                  },
                ),
                FlatButton(
                  child: Text(proTranslate['İLERİ'][Language.languageIndex]),
                  onPressed: () {
                    setState(() {
                      _targetDateTime = DateTime(_targetDateTime.year, _targetDateTime.month + 1);
                      _currentMonth = DateFormat.yMMM().format(_targetDateTime);
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: _calendarCarouselNoHeader,
          ),
        ],
      ),
    );
  }

  void refreshPage() {
    var _helper =DbHelper.instance;
    var sorgu = _helper.getEventList();
    sorgu.then((onValue) {
      setState(() {
        for (int i = 0; i < onValue.length; i++) {
          var tarih = DateTime.parse(onValue[i].date);
          _markedDateMap.add(
              tarih,
              Event(
                date: tarih,
                title: onValue[i].title,
                icon: _eventIcon,
              ));
        }
      });
    });
  }

  String translateMonths(String monthYear) {
    var map = {
      "Jan": proTranslate["Ocak"][Language.languageIndex],
      "Feb": proTranslate["Şubat"][Language.languageIndex],
      "Mar": proTranslate["Mart"][Language.languageIndex],
      "Apr": proTranslate["Nisan"][Language.languageIndex],
      "May": proTranslate["Mayıs"][Language.languageIndex],
      "Jun": proTranslate["Haziran"][Language.languageIndex],
      "Jul": proTranslate["Temmuz"][Language.languageIndex],
      "Aug": proTranslate["Ağustos"][Language.languageIndex],
      "Sep": proTranslate["Eylül"][Language.languageIndex],
      "Oct": proTranslate["Ekim"][Language.languageIndex],
      "Nov": proTranslate["Kasım"][Language.languageIndex],
      "Dec": proTranslate["Aralık"][Language.languageIndex]
    };

    return map.keys.contains(monthYear.split(" ")[0])
        ? map[monthYear.split(" ")[0]] + " " + monthYear.split(" ")[1]
        : monthYear;
  }
}
