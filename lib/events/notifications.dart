import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:ajanda/helpers/constants.dart';
import 'package:ajanda/helpers/languageDictionary.dart';

class Notifications {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  Notifications(this.localNotificationsPlugin);

  Future countDownNotification(
      FlutterLocalNotificationsPlugin plugin, String message, String subtext, int id) async {
    var androidChannel = AndroidNotificationDetails(
      'your channel id',
      "CHANNEL-NAME",
      "CHANNEL-DESC",
      largeIcon: DrawableResourceAndroidBitmap('large_icon'),
      importance: Importance.Low,
      priority: Priority.High,
      autoCancel: false,
      ongoing: true,
      enableVibration: false,
      onlyAlertOnce: true,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    subtext = "<b>" + subtext + "<//b>";
    await plugin.show(id, message, subtext, platformChannel);
  }

  Future singleNotification(FlutterLocalNotificationsPlugin plugin, DateTime datetime,
      String message, String subtext, int id) async {
    var androidChannel = AndroidNotificationDetails(
      'your channel id',
      "CHANNEL-NAME",
      "CHANNEL-DESC",
      largeIcon: DrawableResourceAndroidBitmap('large_icon'),
      importance: Importance.Max,
      priority: Priority.Max,
      autoCancel: false,
      ongoing: false,
      // notifications
      onlyAlertOnce: true,
    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    await localNotificationsPlugin.schedule(
      id + 5000,
      message,
      subtext,
      datetime,
      platformChannel,
    );
  }

  Future singleNotificationWithMail(FlutterLocalNotificationsPlugin plugin, DateTime datetime,
      String message, String subtext, int id) async {
    var androidChannel = AndroidNotificationDetails(
      'your channel id',
      "CHANNEL-NAME",
      "CHANNEL-DESC",
      largeIcon: DrawableResourceAndroidBitmap('large_icon'),
      importance: Importance.Max,
      priority: Priority.Max,
      autoCancel: false,
      ongoing: false,
      onlyAlertOnce: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound("slow_spring_board_longer_tail"),
    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    print("[NOTIFICATIONS] [onSelectNotification] creating notification ");
    await localNotificationsPlugin.schedule(
      id + 5000,
      message,
      subtext,
      datetime,
      platformChannel,
      payload: id.toString(),
    );
  }

  Future cancelNotification(FlutterLocalNotificationsPlugin plugin, int eventId) async {
    await plugin.cancel(eventId);
  }

  Future cancelAllNotifications(FlutterLocalNotificationsPlugin plugin) async {
    await plugin.cancelAll();
  }

  String calcSingleNotificationBodyText(String index) {
    var provisionMap = {
      "1": proTranslate["Etkinliğiniz zamanı geldi."][Language.languageIndex],
      "2": proTranslate["Etkinliğinize 5 dakika kaldı."][Language.languageIndex],
      "3": proTranslate["Etkinliğinize 15 dakika kaldı."][Language.languageIndex],
      "4": proTranslate["Etkinliğinize 30 dakika kaldı."][Language.languageIndex],
      "5": proTranslate["Etkinliğinize 12 saat kaldı."][Language.languageIndex],
      "6": proTranslate["Etkinliğinize 12 saat kaldı."][Language.languageIndex],
      "7": proTranslate["Etkinliğinize 1 gün kaldı."][Language.languageIndex],
      "8": proTranslate["Etkinliğinize 3 gün kaldı."][Language.languageIndex],
      "9": proTranslate["Etkinliğinize 1 hafta kaldı."][Language.languageIndex]
    };
    return provisionMap.containsKey(index)
        ? provisionMap[index]
        : "[ERROR] [NOTIFICATIONS] [calcSingleNotificationBodyText] Unvalid index!";
  }

  DateTime calcNotificationDate(DateTime date, int index) {
    switch (index) {
      case 1:
        {
          return date;
        }
        break;
      case 2:
        {
          return date.subtract(Duration(minutes: 5));
        }
        break;
      case 3:
        {
          return date.subtract(Duration(minutes: 15));
        }
        break;
      case 4:
        {
          return date.subtract(Duration(minutes: 30));
        }
        break;
      case 5:
        {
          return date.subtract(Duration(minutes: 60));
        }
        break;
      case 6:
        {
          return date.subtract(Duration(hours: 12));
        }
        break;
      case 7:
        {
          return date.subtract(Duration(days: 1));
        }
        break;
      case 8:
        {
          return date.subtract(Duration(days: 3));
        }
        break;
      case 9:
        {
          return date.subtract(Duration(days: 7));
        }
        break;
      default:
        {
          print("[ERROR] [NOTIFICATIONS] Invalid index");
          return date;
        }
    }
  }
}
