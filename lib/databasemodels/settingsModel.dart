import '../helpers/constants.dart';

class Setting {
  String _theme;
  String _fontName;
  int _warning;
  int _language;

  Setting({theme,fontName,warning,language}) {
    this._theme = theme;
    this._fontName = fontName;
    this._warning = warning;
    this._language = language;
  }
  String get theme => _theme;
  String get fontName => _fontName;
  int get warning => _warning;
  int get language => _language;

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

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map[SettingsConstants.COLUMN_THEME]= _theme;
    map[SettingsConstants.COLUMN_FONTNAME] = _fontName;
    map[SettingsConstants.COLUMN_WARNING] = _warning;
    map[SettingsConstants.COLUMN_LANGUAGE] = _language;
    return map;
  }

  Setting.fromMap(Map input) {
    this._theme = input[SettingsConstants.COLUMN_THEME];
    this._fontName = input[SettingsConstants.COLUMN_FONTNAME];
    this._warning = input[SettingsConstants.COLUMN_WARNING];
    this._language = input[SettingsConstants.COLUMN_LANGUAGE];
  }
}
