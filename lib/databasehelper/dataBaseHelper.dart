import 'dart:async';
import 'dart:io' show Directory;

import 'package:ajanda/databasehelper/settingsHelper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/helperFunctions.dart';
import '../databasemodels/events.dart';
import '../events/notifications.dart';
import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';
import '../main.dart';

class DbHelper {
  static DbHelper _databaseHelper; // Database'in tekil olmasi icin
  static Database _database;

  static final String _tableName = EventConstants.TABLE_NAME;
  static final String _columnId = EventConstants.COLUMN_ID;
  static final String _columnTitle = EventConstants.COLUMN_TITLE;
  static final String _columnDate = EventConstants.COLUMN_DATE;
  static final String _columnStartTime = EventConstants.COLUMN_STARTTIME;
  static final String _columnFinishTime = EventConstants.COLUMUN_FINISHTIME;
  static final String _columnDesc = EventConstants.COLUMN_DESCRIPTION;
  static final String _columnIsActive = EventConstants.COLUMN_ISACTIVE;
  static final String _columnNotification = EventConstants.COLUMN_NOTIFICATION;
  static final String _columnCountdownIsActive = EventConstants.COLUMN_COUNTDOWNISACTIVE;
  static final String _columnAttachments = EventConstants.COLUMN_ATTACHMENTS;
  static final String _columnCc = EventConstants.COLUMN_CC;
  static final String _columnBb = EventConstants.COLUMN_BB;
  static final String _columnRecipient = EventConstants.COLUMN_RECIPIENT;
  static final String _columnSubject = EventConstants.COLUMN_SUBJECT;
  static final String _columnBody = EventConstants.COLUMN_BODY;
  static final String _columnPeriodic = EventConstants.COLUMN_PERIODIC;
  static final String _columnFrequency = EventConstants.COLUMN_FREQUENCY;

  DbHelper._createInstance();

  factory DbHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DbHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  static Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'dbtakvim.db';

    // Database yoksa olusturuyor varsa aciyor
    var eventsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return eventsDatabase;
  }

  static void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $_tableName ( $_columnId INTEGER PRIMARY KEY NOT NULL,$_columnTitle TEXT ,$_columnDate TEXT,$_columnStartTime TEXT,$_columnFinishTime TEXT,$_columnDesc TEXT,$_columnIsActive INTEGER, $_columnNotification TEXT, $_columnCountdownIsActive INTEGER, $_columnAttachments TEXT,$_columnCc TEXT, $_columnBb TEXT, $_columnRecipient TEXT, $_columnSubject TEXT, $_columnBody TEXT,$_columnPeriodic INTEGER, $_columnFrequency TEXT);');
  }

  // Databaseden tüm eventleri alma
  Future<List<Map<String, dynamic>>> getEventMapList() async {
    Database db = await this.database;
    var result = await db.query(_tableName, orderBy: '$_columnTitle ASC');
    return result;
  }

  // Event ekleme
  Future<int> insertEvent(Event event) async {
    Database db = await this.database;
    var result = await db.insert(_tableName, event.toMap());
    return result;
  }

  // Eventi güncelleme
  Future<int> updateEvent(Event event) async {
    var db = await this.database;
    var result =
        await db.update(_tableName, event.toMap(), where: '$_columnId = ?', whereArgs: [event.id]);
    return result;
  }

  Future updateSingleColumn(int id, String columnName, String newValue) async {
    var db = await this.database;
    await db.rawQuery("UPDATE $_tableName SET $columnName='$newValue' WHERE $_columnId=$id");
  }

  // IDsiyle event silme
  Future<int> deleteEvent(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $_tableName WHERE $_columnId = $id');
    return result;
  }

  Future<void> deleteOldEventDay(String date) async {
    var db = await this.database;
    await db.rawQuery('DELETE FROM $_tableName WHERE $_columnDate = "$date" ');
  }

  Future<void> deleteOldEventHour(String date, String hour) async {
    var db = await this.database;
    await db.rawQuery(
        'DELETE FROM $_tableName WHERE $_columnStartTime = "$hour" AND $_columnDate = "$date" ');
  }

  Future<Event> getEventById(int id) async {
    var db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $_tableName WHERE $_columnId=$id');

    Event event = Event();
    event = Event.fromMap(result[0]);
    return event;
  }

  // Database deki eleman sayisini donduruyor
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $_tableName');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Databaseden alinan eventleri list seklinde alma
  Future<List<Event>> getEventList() async {
    var eventMapList = await getEventMapList();
    int count = eventMapList.length;
    List<Event> eventList = List<Event>();
    for (int i = 0; i < count; i++) {
      eventList.add(Event.fromMap(eventMapList[i]));
    }
    return eventList;
  }

  // Istenilen sekilde eventleri alma
  Future<List<Event>> getEventsByOrder(sortStyle) async {
    var eventMapList = await getEventMapList();
    int count = eventMapList.length;

    List<Event> eventList = List<Event>();
    for (int i = 0; i < count; i++) {
      eventList.add(Event.fromMap(eventMapList[i]));
    }
    // Listeyi istenilen sirada siralayip return edilmesi
    print("[DATABASEHELPER] [getEventByOrder] sortStyle : $sortStyle");
    switch (sortStyle) {
      case 0:
        {
          return eventList; // A-Z a-z normal siralama
        }
        break;

      case 1:
        {
          return eventList.reversed.toList(); // Z-A z-a ters alfabetik siralama
        }
        break;
      case 2:
        {
          // Yakin tarihlerin basta oldugu siralama
          eventList.sort((a, b) => sortByDate(a, b));
        }
        break;
      case 3:
        {
          // Uzak tarihlerin basta oldugu siralama
          eventList.sort((a, b) => sortByDate(a, b));
          eventList = eventList.reversed.toList();
        }
        break;
      default:
        {
          // Default olarak A-Z a-z ayarli herhangi bir acik olmasin diye
          return eventList;
        }
        break;
    }
    return eventList;
  }

  Future<bool> isEventInDb(String date) async {
    var eventList = await getEventList();
    int count = eventList.length;

    for (var i = 0; i < count; i++) {
      if (eventList[i].date == date) {
        return true;
      }
    }
    return false;
  }

  Future<List<Event>> getEventCalander(String date) async {
    var eventList = await getEventList();
    int count = eventList.length;

    List<Event> resultList = List<Event>();

    for (var i = 0; i < count; i++) {
      if (eventList[i].date == date) {
        resultList.add(eventList[i]);
      }
    }
    return resultList;
  }

  Future<bool> openNotificationBar() async {
    /// Database aciliyor
    Database db = await this.database;

    /// Notification objesi olusturuluyor
    var not = Notifications(flutterLocalNotificationsPlugin);

    /// Settings helper
    SettingsDbHelper settingsDbHelper = SettingsDbHelper();
    /// Gerekli sartlari [countDownIsActive(Sabit bildirim) - periodic(Periyotlu event)] saglayan eventler databaseden aliniyor
    var result = await db.rawQuery(
        "SELECT * FROM $_tableName WHERE $_columnCountdownIsActive=1 OR $_columnPeriodic!=0");

    /// Eventler listeye ekleniyor
    List<Event> eventList = List<Event>();
    for (var i = 0; i < result.length; i++) {
      eventList.add(Event.fromMap(result[i]));
    }

    /// Eger gerekli sartlari saglayan event yoksa return edilip fonksiyondan cikiliyor
    if (eventList.length == 0) {
      return false;
    }

    /// Sartlari saglayan eventler uzerinde yapilan islemler
    for (var i = 0; i < eventList.length; i++) {
      /// Eger sabit bildirim acik degilse arka planda calismamasi icin pass geciliyor
      if (eventList[i].countDownIsActive == 0) {
        continue;
      }

      /// Gun ve saatler birlestirilip tam tarih aliniyor
      var targetTime = eventList[i].startTime == "null"
          ? DateTime.parse("${eventList[i].date}")
          : DateTime.parse("${eventList[i].date} ${eventList[i].startTime}");

      /// Eger etkinlik tarihi gecmis ise
      if (targetTime.isBefore(DateTime.now()) || (targetTime == DateTime.now())) {
        /// Periyodik degilse etkinlik siliniyor ve db guncellenerek sabit bildirim kapatiliyor
        if (eventList[i].periodic == 0) {
          not.cancelNotification(flutterLocalNotificationsPlugin, eventList[i].id);
          await updateSingleColumn(eventList[i].id, _columnCountdownIsActive, "0");
          continue;
        }

        /// Eger periyodik ise periyod surelerine bakiliyor
        else {
          await this.controlDates().then((value) => targetTime = value);
        }
      }
      var remainingTime = targetTime.difference(DateTime.now());
      await settingsDbHelper.getSettings().then((value) => Language.languageIndex=value[0].language);
      await not.countDownNotification(
          flutterLocalNotificationsPlugin,
          eventList[i].title,
          "${proTranslate["ETKİNLİĞE"][Language.languageIndex]} ${remainingTime.inDays} ${proTranslate["GÜN"][Language.languageIndex]} ${remainingTime.inHours - remainingTime.inDays * 24} ${proTranslate["SAAT"][Language.languageIndex]} ${remainingTime.inMinutes - remainingTime.inHours * 60} ${proTranslate["DAKİKA"][Language.languageIndex]} ${proTranslate["KALDI"][Language.languageIndex]}",
          eventList[i].id);
    }
    return true;
  }

  Future<void> createNotifications() async {
    Database db = await this.database;
    var not = Notifications(flutterLocalNotificationsPlugin);
    var events = await db.rawQuery("SELECT * FROM $_tableName WHERE $_columnNotification!='0'");
    List<Event> eventList = List<Event>();

    for (var i = 0; i < events.length; i++) {
      eventList.add(Event.fromMap(events[i]));
    }
    for (var event in eventList) {
      if (event.choice == "null") {
        continue;
      }
      var datetime = event.startTime != "null"
          ? DateTime.parse("${event.date} ${event.startTime}")
          : DateTime.parse(event.date);
      if (DateTime.now().compareTo(datetime) == 1) {
        print("[dataBaseHelper] [createNotifications] Out of time event title : ${event.title}");
        flutterLocalNotificationsPlugin
            .cancel(event.id); // zaman gectikten sonra notificasyonun kapanmasinin sebebi
        continue;
      }
      datetime = not.calcNotificationDate(datetime, int.parse(event.choice));
      if (event.recipient != "") {
        print("[DATABASEHELPER] [createNotifications] e-mail notification : ${event.title}");
        await not.singleNotificationWithMail(
            flutterLocalNotificationsPlugin,
            datetime,
            event.title,
            proTranslate["Yollayacağınız e-mail'in vakti geldi."][Language.languageIndex],
            event.id);
      } else {
        print("[DATABASEHELPER] [createNotifications] normal notification : ${event.title}");
        await not.singleNotification(flutterLocalNotificationsPlugin, datetime, event.title,
            not.calcSingleNotificationBodyText(event.choice), event.id);
      }
    }
  }

  Future<DateTime> controlDates() async {
    Database db = await this.database;
    var events = await db.rawQuery("SELECT * FROM $_tableName WHERE $_columnPeriodic!=0");
    DateTime eventDate;
    List<Event> eventList = List<Event>();
    events.forEach((element) {
      eventList.add(Event.fromMap(element));
    });
    for (Event event in eventList) {
      eventDate = event.startTime == "null"
          ? DateTime.parse("${event.date}")
          : DateTime.parse("${event.date} ${event.startTime}");
      if (eventDate.isAfter(DateTime.now())) {
        continue;
      }
      switch (event.periodic) {

        /// Gunluk periyod
        case 1:
          {
            eventDate = eventDate.add(Duration(days: 1));
            event.date = eventDate.toString().split(" ")[0];
            this.updateEvent(event);
            break;
          }

        /// Haftalik periyod
        case 2:
          {
            eventDate = eventDate.add(Duration(days: 7));
            event.date = eventDate.toString().split(" ")[0];
            this.updateEvent(event);
            break;
          }

        /// Aylik periyod
        case 3:
          {
            eventDate = eventDate.add(Duration(days: 30));
            event.date = eventDate.toString().split(" ")[0];
            this.updateEvent(event);
            break;
          }

        /// Ozel periyod
        default:
          {
            /// Etkinlik zamani gectigi icin bir sonraki gunden baslayarak frekansa bakiliyor
            int j = eventDate.weekday == 7 ? 0 : eventDate.weekday - 1;
            j < 6 ? j++ : j = 0;

            /// Sonsuz donguye girmemesi icin kontrol
            int control = 0;
            while (j < 7) {
              /// Eger frekansta 1 degerini bulduysa aradaki fark kadar gun date'e eklenip bir sonraki
              /// tarih belirleniyor ve date guncelleniyor
              if (event.frequency[j] == "1") {
                int addition = ((j + 1) - eventDate.weekday) == 0
                    ? (7)
                    : (((j + 1) - eventDate.weekday) < 0)
                        ? ((j + 1) - eventDate.weekday + 7)
                        : ((j + 1) - eventDate.weekday);
                eventDate = eventDate.add(Duration(days: addition));
                event.date = eventDate.toString().split(" ")[0];
                this.updateEvent(event);
                break;
              }
              j++;
              if (j == 7) {
                control++;
                j = 0;
              }

              /// Sonsuz donguye girmesin diye kontrol
              if (control > 8) {
                break;
              }
            }
          }
      }
    }
    return eventDate;
  }

  // Istenilen bir sql sorgusunu calistiriyor
  Future<dynamic> query(String query) async {
    Database db = await this.database;
    var result = await db.rawQuery(query);
    print("[DATABASEHELPER] [query] result :$result");
    return result;
  }

  Future clearOldEvents() async {
    var not = Notifications(flutterLocalNotificationsPlugin);
    await getEventList().then((value) {
      for (int i = 0; i < value.length; i++) {
        var targetTime = value[i].startTime == "null"
            ? DateTime.parse("${value[i].date}")
            : DateTime.parse("${value[i].date} ${value[i].startTime}");
        if (targetTime.isBefore(DateTime.now()) || (targetTime == DateTime.now())) {
          if (value[i].startTime == "null") {
            deleteOldEventDay(value[i].date);
          } else {
            deleteOldEventHour(value[i].date, value[i].startTime);
          }
          not.cancelNotification(flutterLocalNotificationsPlugin, value[i].id);
        }
      }
    });
  }

  Future clearDb() async {
    // butun notificationlarda silinecek
    var not = Notifications(flutterLocalNotificationsPlugin);
    Database db = await this.database;
    await db.rawQuery('DELETE FROM $_tableName');
    not.cancelAllNotifications(flutterLocalNotificationsPlugin);
  }

  Future closeDb() => _database.close();
}
