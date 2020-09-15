import 'dart:async';
import 'dart:io' show Directory;

import 'package:ajanda/databasemodels/settingsModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/constants.dart';

class SettingsDbHelper {
  static SettingsDbHelper _databaseHelper; // Database'in tekil olmasi icin
  static Database _database;

  SettingsDbHelper._createInstance();

  factory SettingsDbHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = SettingsDbHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  /// Database initialize ediliyor
  static Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'dbsettings.db';

    /// Database yoksa olusturuyor varsa aciyor
    var eventsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return eventsDatabase;
  }

  /// Database olusturuluyor
  static void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE ${SettingsConstants.TABLE_NAME}(${SettingsConstants.COLUMN_THEME} TEXT, ${SettingsConstants.COLUMN_FONTNAME} TEXT,${SettingsConstants.COLUMN_WARNING} INTEGER, ${SettingsConstants.COLUMN_LANGUAGE} INTEGER)');
  }

  /// Yeni gelen theme bilgisiyle database guncelleniyor
  Future<void> updateTheme(Setting setting) async {
    var db = await this.database;
    await db.rawQuery("UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_THEME} = '${setting.theme}';");
  }

  /// Font settings'i guncelleniyor
  Future<void> updateFont(Setting setting) async {
    var db = await this.database;
    await db.rawQuery("UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_FONTNAME} = '${setting.fontName}';");
  }

  /// Warning Settings'i guncelleniyor
  Future<void> updateWarning(int e) async {
    var db = await this.database;
    await db.rawQuery("UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_WARNING} = $e;");
  }

  /// Yeni gelen dil bilgisiyle database guncelleniyor
  Future<void> updateLanguage(Setting setting) async {
    var db = await this.database;
    await db.rawQuery("UPDATE ${SettingsConstants.TABLE_NAME} SET ${SettingsConstants.COLUMN_LANGUAGE} = ${setting.language};");
  }
  /// Tum kayitli ayarlari cekmek icin
  Future<List<Setting>> getSettings() async {
    Database db = await this.database;
    var settingsMapList = await db.rawQuery("SELECT * FROM ${SettingsConstants.TABLE_NAME}");
    /// Db bos ise default degerler veriliyor
    if (settingsMapList.length == 0 || settingsMapList == []) {
      await db.rawQuery(
          "INSERT INTO ${SettingsConstants.TABLE_NAME} (${SettingsConstants.COLUMN_THEME},${SettingsConstants.COLUMN_FONTNAME},${SettingsConstants.COLUMN_WARNING},${SettingsConstants.COLUMN_LANGUAGE}) VALUES('light','Titillium',0,2);");
      settingsMapList = await db.rawQuery("SELECT * FROM ${SettingsConstants.TABLE_NAME}");
    }
    List<Setting> settingList = List<Setting>();
    for (int i = 0; i < settingsMapList.length; i++) {
      settingList.add(Setting.fromMap(settingsMapList[i]));
    }
    return settingList;
  }
}
