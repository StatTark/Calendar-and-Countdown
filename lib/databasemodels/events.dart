import '../helpers/constants.dart';

class Event {
  /// Etkinlik detaylari
  int _id;
  String _title;
  String _date;
  String _startTime;
  String _finishTime;
  String _desc;

  /// Geri sayim ve bildirimler icin gerekli degiskenler
  int _isActive;
  String _choice;
  int _countDownIsActive;

  /// Mail icin gerekli bilgiler
  String _attachments;
  String _cc;
  String _bb;
  String _recipient;
  String _subject;
  String _body;

  /// Periyodik islemler icin gerekli bilgiler
  int _periodic;
  String _frequency;

  /// Constructor
  Event({int id,
    String title,
    String date,
    String startTime,
    String finishTime,
    String desc,
    int isActive,
    String choice,
    int countDownIsActive,
    String attachments,
    String cc,
    String bb,
    String recipient,
    String subject,
    String body,
    int periodic,
    String frequency,
  }) {
    this._id = id;
    this._title = title;
    this._date = date;
    this._startTime = startTime;
    this._finishTime = finishTime;
    this._desc = desc;
    this._isActive = isActive;
    this._choice = choice;
    this._countDownIsActive = countDownIsActive;
    this._attachments = attachments;
    this._cc = cc;
    this._bb = bb;
    this._recipient = recipient;
    this._subject = subject;
    this._body = body;
    this._periodic = periodic;
    this._frequency = frequency;
  }

  /// Getters
  int get id => _id;

  String get title => _title;

  String get date => _date;

  String get startTime => _startTime;

  String get finishTime => _finishTime;

  String get desc => _desc;

  int get isActive => _isActive;

  String get choice => _choice;

  int get countDownIsActive => _countDownIsActive;

  String get attachments => _attachments;

  String get cc => _cc;

  String get bb => _bb;

  String get recipient => _recipient;

  String get subject => _subject;

  String get body => _body;

  int get periodic => _periodic;

  String get frequency => _frequency;

  /// Setters
  set id(int newId) {
    _id = newId;
  }

  set title(String newTitle) {
    _title = newTitle;
  }

  set date(String newDate) {
    _date = newDate;
  }

  set startTime(String newStartTime) {
    _startTime = newStartTime;
  }

  set finishTime(String newFinishTime) {
    _finishTime = newFinishTime;
  }

  set desc(String newDesc) {
    _desc = newDesc;
  }

  set isActive(int newState) {
    _isActive = newState;
  }

  set choice(String newChoice) {
    _choice = newChoice;
  }

  set countDownIsActive(int countDownIsActive) {
    _countDownIsActive = countDownIsActive;
  }

  set attachments(String attachments) {
    _attachments = attachments;
  }


  set cc(String ccController) {
    _cc = ccController;
  }

  set bb(String bbcController) {
    _bb = bbcController;
  }

  set recipient(String recipientController) {
    _recipient = recipientController;
  }

  set subject(String subjectController) {
    _subject = subjectController;
  }

  set body(String bodyController) {
    _body = bodyController;
  }

  set periodic(int period) => _periodic=period;

  set frequency(String freq) => _frequency =freq;

  /// Event'i map objesine donusturuyor
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (_id != null) {
      map[EventConstants.COLUMN_ID] = _id;
    }

    map[EventConstants.COLUMN_TITLE] = _title;
    map[EventConstants.COLUMN_DATE] = _date;
    map[EventConstants.COLUMN_STARTTIME] = _startTime;
    map[EventConstants.COLUMUN_FINISHTIME] = _finishTime;
    map[EventConstants.COLUMN_DESCRIPTION] = _desc;
    map[EventConstants.COLUMN_ISACTIVE] = _isActive;
    map[EventConstants.COLUMN_NOTIFICATION] = _choice;
    map[EventConstants.COLUMN_COUNTDOWNISACTIVE] = _countDownIsActive;
    map[EventConstants.COLUMN_ATTACHMENTS] = _attachments;
    map[EventConstants.COLUMN_CC] = _cc;
    map[EventConstants.COLUMN_BB] = _bb;
    map[EventConstants.COLUMN_RECIPIENT] = _recipient;
    map[EventConstants.COLUMN_SUBJECT] = _subject;
    map[EventConstants.COLUMN_BODY] = _body;
    map[EventConstants.COLUMN_PERIODIC] = _periodic;
    map[EventConstants.COLUMN_FREQUENCY] = _frequency;

    return map;
  }
  /// Map objesinden event olusturan named constructor
  Event.fromMap(Map input) {
    this._id = input[EventConstants.COLUMN_ID];
    this._title = input[EventConstants.COLUMN_TITLE];
    this._date = input[EventConstants.COLUMN_DATE];
    this._startTime = input[EventConstants.COLUMN_STARTTIME].toString();
    this._finishTime = input[EventConstants.COLUMUN_FINISHTIME].toString();
    this._desc = input[EventConstants.COLUMN_DESCRIPTION];
    this._isActive = input[EventConstants.COLUMN_ISACTIVE];
    this._choice = input[EventConstants.COLUMN_NOTIFICATION];
    this._countDownIsActive = input[EventConstants.COLUMN_COUNTDOWNISACTIVE];
    this._attachments = input[EventConstants.COLUMN_ATTACHMENTS];
    this._cc = input[EventConstants.COLUMN_CC];
    this._bb = input[EventConstants.COLUMN_BB];
    this._recipient = input[EventConstants.COLUMN_RECIPIENT];
    this._subject = input[EventConstants.COLUMN_SUBJECT];
    this._body = input[EventConstants.COLUMN_BODY];
    this._periodic = input[EventConstants.COLUMN_PERIODIC];
    this._frequency = input[EventConstants.COLUMN_FREQUENCY];
  }
}
