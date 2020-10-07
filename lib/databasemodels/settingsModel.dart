import '../helpers/constants.dart';

class Setting {
  String _theme;
  String _fontName;
  int _warning;
  int _language;
  int _first;

  Setting({theme,fontName,warning,language,first}) {
    this._theme = theme;
    this._fontName = fontName;
    this._warning = warning;
    this._language = language;
    this._first = first;
  }
  String get theme => _theme;
  String get fontName => _fontName;
  int get warning => _warning;
  int get language => _language;
  int get first => _first;

  set theme(String th) {
    this._theme = th;
  }
  set fontName(String fn) {
    this._fontName = fn;
  }

  set warning(int v){
    this._warning = v;
  }

  set language(int v){
    this._language = v;
  }
  set first(int v){
    this._first = v;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[SettingsConstants.COLUMN_THEME]= _theme;
    map[SettingsConstants.COLUMN_FONTNAME] = _fontName;
    map[SettingsConstants.COLUMN_WARNING] = _warning;
    map[SettingsConstants.COLUMN_LANGUAGE] = _language;
    map[SettingsConstants.COLUMN_FIRST] = _first;
    return map;
  }

  Setting.fromMap(Map input) {
    this._theme = input[SettingsConstants.COLUMN_THEME];
    this._fontName = input[SettingsConstants.COLUMN_FONTNAME];
    this._warning = input[SettingsConstants.COLUMN_WARNING];
    this._language = input[SettingsConstants.COLUMN_LANGUAGE];
    this._first = input[SettingsConstants.COLUMN_FIRST];
  }
}
