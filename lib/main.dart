import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages/mainmenu.dart';
import 'databasehelper/dataBaseHelper.dart';
import 'helpers/helperFunctions.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationAppLaunchDetails notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    var db = DbHelper.instance;
    var event = await db.getEventById(int.parse(payload));

    var ccList = event.cc.split(",");
    var bbList = event.bb.split(",");
    var recipientsList = event.recipient.split(",");

    final MailOptions mailOptions = MailOptions(
      body: event.body,
      subject: event.subject,
      recipients: recipientsList,
      ccRecipients: ccList,
      bccRecipients: bbList,
      attachments: stringPathsToList(event.attachments),
    );
    await FlutterMailer.send(mailOptions);
  });
  if (await Permission.notification.status.isDenied) {
    openAppSettings();
  }
  runApp(MainMenu());
}
