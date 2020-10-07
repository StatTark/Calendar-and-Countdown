import 'dart:async';
import 'dart:io' show Directory;

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/helperFunctions.dart';
import '../databasemodels/events.dart';
import '../events/notifications.dart';
import '../helpers/constants.dart';
import '../helpers/languageDictionary.dart';
import '../main.dart';
import '../databasemodels/settingsModel.dart';

class DbHelper {
  static Database _database;

  DbHelper._createInstance();

  static final DbHelper instance = DbHelper._createInstance();

  Future<Database> get database async {
    debugPrint("[dataBaseHelper] get database working...");
    if (_database == null) {
      debugPrint("[dataBaseHelper] _database is null");
      _database = await _initDatabase();
    }
    debugPrint("[dataBaseHelper] _database is not null");
    return _database;
  }

  Future<Database> _initDatabase() async {
    debugPrint("[dataBaseHelper] [_initDatabase] initDatabase working...");
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'dbtakvimXX.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database database, int version) async {
        try {
          await database.execute(
              'CREATE TABLE ${EventConstants.TABLE_NAME}( ${EventConstants.COLUMN_ID} INTEGER PRIMARY KEY NOT NULL, ${EventConstants.COLUMN_TITLE} TEXT ,${EventConstants.COLUMN_DATE} TEXT,${EventConstants.COLUMN_STARTTIME} TEXT,${EventConstants.COLUMUN_FINISHTIME} TEXT, ${EventConstants.COLUMN_DESCRIPTION} TEXT, ${EventConstants.COLUMN_ISACTIVE} INTEGER, ${EventConstants.COLUMN_NOTIFICATION} TEXT, ${EventConstants.COLUMN_COUNTDOWNISACTIVE} INTEGER, ${EventConstants.COLUMN_ATTACHMENTS} TEXT, ${EventConstants.COLUMN_CC} TEXT, ${EventConstants.COLUMN_BB} TEXT, ${EventConstants.COLUMN_RECIPIENT} TEXT, ${EventConstants.COLUMN_SUBJECT} TEXT, ${EventConstants.COLUMN_BODY} TEXT, ${EventConstants.COLUMN_PERIODIC} INTEGER, ${EventConstants.COLUMN_FREQUENCY} TEXT)');
          await database.execute(
              'CREATE TABLE ${SettingsConstants.TABLE_NAME}(${SettingsConstants.COLUMN_THEME} TEXT DEFAULT "light" NOT NULL, ${SettingsConstants.COLUMN_FONTNAME} TEXT,${SettingsConstants.COLUMN_WARNING} INTEGER, ${SettingsConstants.COLUMN_LANGUAGE} INTEGER, ${SettingsConstants.COLUMN_FIRST} INTEGER)');
        } catch (e) {
          debugPrint("[ERROR] [DATABASEHELPER] [_initDatabase] : $e");
        }
      },
    );
  }

  // Databaseden tüm eventleri alma
  Future<List<Map<String, dynamic>>> getEventMapList() async {
    Database db = await this.database;
    var result = await db.query(EventConstants.TABLE_NAME,
        orderBy: '${EventConstants.COLUMN_TITLE} ASC');
    return result;
  }

  // Event ekleme
  Future<int> insertEvent(Event event) async {
    Database db = await this.database;
    var result = await db.insert(EventConstants.TABLE_NAME, event.toMap());
    return result;
  }

  // Eventi güncelleme
  Future<int> updateEvent(Event event) async {
    var db = await this.database;
    var result = await db.update(EventConstants.TABLE_NAME, event.toMap(),
        where: '${EventConstants.COLUMN_ID} = ?', whereArgs: [event.id]);
    return result;
  }

  Future updateSingleColumn(int id, String columnName, String newValue) async {
    var db = await this.database;
    await db.rawQuery(
        "UPDATE ${EventConstants.TABLE_NAME} SET $columnName='$newValue' WHERE ${EventConstants.COLUMN_ID}=$id");
  }

  // IDsiyle event silme
  Future<int> deleteEvent(int id) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_ID} = $id');
    return result;
  }

  Future<void> deleteOldEventDay(String date) async {
    var db = await this.database;
    await db.rawQuery(
        'DELETE FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_DATE} = "$date" ');
  }

  Future<void> deleteOldEventHour(String date, String hour) async {
    var db = await this.database;
    await db.rawQuery(
        'DELETE FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_STARTTIME} = "$hour" AND ${EventConstants.COLUMN_DATE} = "$date" ');
  }

  Future<Event> getEventById(int id) async {
    var db = await this.database;
    var result = await db.rawQuery(
        'SELECT * FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_ID}=$id');

    Event event = Event();
    event = Event.fromMap(result[0]);
    return event;
  }

  // Database deki eleman sayisini donduruyor
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from ${EventConstants.TABLE_NAME}');
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
    debugPrint("[dataBaseHelper] [openNotificationBar] func working...");

    /// Database aciliyor
    Database db = await this.database;

    /// Notification objesi olusturuluyor
    var not = Notifications(flutterLocalNotificationsPlugin);

    /// Gerekli sartlari [countDownIsActive(Sabit bildirim) - periodic(Periyotlu event)] saglayan eventler databaseden aliniyor
    var result;
    try {
      result = await db.rawQuery(
          "SELECT * FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_COUNTDOWNISACTIVE}=1 OR ${EventConstants.COLUMN_PERIODIC}!=0");
    } catch (e) {
      debugPrint("[ERROR] [DATABASEHELPER] [openNotificationBar] $e");
      debugPrint("[openNotificationBar] db value : ${db.runtimeType}");
      return false;
    }

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
      if (targetTime.isBefore(DateTime.now()) ||
          (targetTime == DateTime.now())) {
        /// Periyodik degilse etkinlik siliniyor ve db guncellenerek sabit bildirim kapatiliyor
        if (eventList[i].periodic == 0) {
          not.cancelNotification(
              flutterLocalNotificationsPlugin, eventList[i].id);
          await updateSingleColumn(
              eventList[i].id, EventConstants.COLUMN_COUNTDOWNISACTIVE, "0");
          continue;
        }

        /// Eger periyodik ise periyod surelerine bakiliyor
        else {
          await this.controlDates().then((value) => targetTime = value);
        }
      }
      var remainingTime = targetTime.difference(DateTime.now());
      await this.getSettings().then((value) {
        Language.languageIndex = value[0].language;
      });
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
    var events = await db.rawQuery(
        "SELECT * FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_NOTIFICATION}!='0'");
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
        print(
            "[dataBaseHelper] [createNotifications] Out of time event title : ${event.title}");
        flutterLocalNotificationsPlugin.cancel(event
            .id); // zaman gectikten sonra notificasyonun kapanmasinin sebebi
        continue;
      }
      datetime = not.calcNotificationDate(datetime, int.parse(event.choice));
      if (event.recipient != "") {
        print(
            "[DATABASEHELPER] [createNotifications] e-mail notification : ${event.title}");
        await not.singleNotificationWithMail(
            flutterLocalNotificationsPlugin,
            datetime,
            event.title,
            proTranslate["Yollayacağınız e-mail'in vakti geldi."]
                [Language.languageIndex],
            event.id);
      } else {
        print(
            "[DATABASEHELPER] [createNotifications] normal notification : ${event.title}");
        await not.singleNotification(
            flutterLocalNotificationsPlugin,
            datetime,
            event.title,
            not.calcSingleNotificationBodyText(event.choice),
            event.id);
      }
    }
  }

  Future<DateTime> controlDates() async {
    debugPrint("[dataBaseHelper] [controlDates] controlDates working...");
    Database db = await this.database;
    var events;
    try {
      events = await db.rawQuery(
          "SELECT * FROM ${EventConstants.TABLE_NAME} WHERE ${EventConstants.COLUMN_PERIODIC}!=0");
    } catch (e) {
      debugPrint("[ERROR] [DATABASEHELPER] [controlDates] $e");
      debugPrint("[controlDates] db value : ${db.runtimeType}");
      return null;
    }
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
        if (targetTime.isBefore(DateTime.now()) ||
            (targetTime == DateTime.now())) {
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
    await db.rawQuery('DELETE FROM ${EventConstants.TABLE_NAME}');
    not.cancelAllNotifications(flutterLocalNotificationsPlugin);
  }

  /// Settings part

  /// Yeni gelen theme bilgisiyle database guncelleniyor
  Future<void> updateTheme(Setting setting) async {
    var db = await this.database;
    await db.rawQuery(
        "UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_THEME} = '${setting.theme}';");
  }

  /// Font settings'i guncelleniyor
  Future<void> updateFont(Setting setting) async {
    var db = await this.database;
    await db.rawQuery(
        "UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_FONTNAME} = '${setting.fontName}';");
  }

  /// Warning Settings'i guncelleniyor
  Future<void> updateWarning(int e) async {
    var db = await this.database;
    await db.rawQuery(
        "UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_WARNING} = $e;");
  }

  /// Yeni gelen dil bilgisiyle database guncelleniyor
  Future<void> updateLanguage(Setting setting) async {
    var db = await this.database;
    await db.rawQuery(
        "UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_LANGUAGE} = ${setting.language};");
  }

  /// Yeni gelen dil bilgisiyle database guncelleniyor
  Future<void> updateFirst(Setting setting) async {
    var db = await this.database;
    await db.rawQuery(
        "UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_FIRST} = ${setting.first};");
  }

  /// Tum kayitli ayarlari cekmek icin
  Future<List<Setting>> getSettings() async {
    Database db = await this.database;
    var settingsMapList;
    try {
      settingsMapList =
          await db.rawQuery("SELECT * FROM ${SettingsConstants.TABLE_NAME}");
    } catch (e) {
      debugPrint("[ERROR] [DATABASEHELPER] [getSettings] : $e");
    }
    debugPrint(
        "[DATABASEHELPER] [getSettings] settingsMapList : $settingsMapList --- settingsMapList length : ${settingsMapList.length}");

    /// Db bos ise default degerler veriliyor
    if (settingsMapList.length == 0 || settingsMapList == []) {
      // !!!!!!!! Default deger ver bunla ugrasma kekeo
      await db.rawQuery(
          "INSERT INTO ${SettingsConstants.TABLE_NAME} (${SettingsConstants.COLUMN_THEME},${SettingsConstants.COLUMN_FONTNAME},${SettingsConstants.COLUMN_WARNING},${SettingsConstants.COLUMN_LANGUAGE},${SettingsConstants.COLUMN_FIRST}) VALUES('light','Titillium',0,1,0);");

      settingsMapList =
          await db.rawQuery("SELECT * FROM ${SettingsConstants.TABLE_NAME}");
    }
    debugPrint(
        "[DATABASEHELPER] [getSettings] settingsMapList : $settingsMapList --- settingsMapList length : ${settingsMapList.length}");
    List<Setting> settingList = List<Setting>();
    for (int i = 0; i < settingsMapList.length; i++) {
      settingList.add(Setting.fromMap(settingsMapList[i]));
    }
    settingList.forEach((element) {
      print("[DATABASEHELPER] [getSettings] settingList element : $element");
    });
    return settingList;
  }
}
