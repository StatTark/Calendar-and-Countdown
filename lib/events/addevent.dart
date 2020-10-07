import 'package:ajanda/helpers/constants.dart';
import 'package:device_info/device_info.dart';

import '../widgets/dayPicker.dart';
import 'package:ajanda/widgets/navigateToSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../databasehelper/dataBaseHelper.dart';
import '../databasemodels/events.dart';
import '../events/mailSender.dart';
import '../helpers/ads.dart';
import '../pages/mainmenu.dart';
import '../widgets/notificationTimePicker.dart';
import '../widgets/showDialog.dart';
import '../helpers/languageDictionary.dart';

class AddEvent extends StatefulWidget {
  var date;

  AddEvent({inputDate, }) {
    date = inputDate;
  }

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Advert _advert = Advert();

  var _db = DbHelper.instance;

  String _selectedDate = DateTime.now().toString().split(" ")[0];
  String _selectedStartHour = DateTime.now().toString().split(" ")[1].split(":")[0] +
      ":" +
      DateTime.now().toString().split(" ")[1].split(":")[1];
  String _selectedFinishHour = DateTime.now()
          .add(Duration(
            hours: 1,
          ))
          .toString()
          .split(" ")[1]
          .split(":")[0] +
      ":" +
      DateTime.now().add(Duration(hours: 1)).toString().split(" ")[1].split(":")[1];
  String errmsg = "";

  bool _iscorrect = true;
  bool _isfullday = false;
  bool _iscountdownchecked = false;
  bool _options = false;
  bool _periodicCheckboxValue = false;

  var _radioValue;
  bool _switchValue = false;
  bool dialogValue = false;

  /// Device infos
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// Baslik ve aciklama kontrolleri
  final _titlecontroller = TextEditingController();
  final _descriptioncontroller = TextEditingController();

  /// Mail degiskenleri
  List<String> _attachments = [];
  var _cc = "";
  var _bb = "";
  var _recipient = "";
  var _subject = "";
  var _body = "";

  /// Periyodik etkinlik degiskenleri
  int _periodRadio = 0;
  String _frequency = "";
  List<bool> _periodicDays = [];
  IconData _iconData = Icons.arrow_drop_down;
  IconData _iconData2 = Icons.arrow_drop_down;

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.date != null ? _selectedDate = widget.date : print("[ADDEVENT] widget.date null");
    });
    asyncCall();
  }

  @override
  void dispose() {
    _titlecontroller.dispose();
    _descriptioncontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(proTranslate["Yeni Etkinlik Ekle"][Language.languageIndex]),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.help_outline,
              size: 36,
            ),
            onPressed: () => showButtonAboutDialog(context),
          ),
        ],
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                  width: MediaQuery.of(context).size.width - 126,
                  child: TextFormField(
                    controller: _titlecontroller,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: proTranslate["Etkinlik ismi"][Language.languageIndex],
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      return value.isEmpty
                          ? proTranslate["Etkinlik ismi boş bırakılamaz"][Language.languageIndex]
                          : null;
                    },
                  )),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Divider(
                  height: 3,
                  thickness: 3,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(22.0, 4.0, 22.0, 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.date_range),
                            Text(
                              "$_selectedDate",
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            )
                          ],
                        ),
                        if (_isfullday != true)
                          Row(
                            children: <Widget>[
                              Icon(Icons.timer),
                              Text(
                                "$_selectedStartHour",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              )
                            ],
                          ),
                        if (_isfullday != true)
                          Row(
                            children: <Widget>[
                              Icon(Icons.timer_off),
                              Text(
                                "$_selectedFinishHour",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                    IconButton(
                      iconSize: 25,
                      onPressed: () {
                        if (_isfullday != true) {
                          showTimePicker(
                            cancelText: proTranslate["Geri"][Language.languageIndex],
                            confirmText: proTranslate["Tamam"][Language.languageIndex],
                            helpText: proTranslate["BİTİŞ SAAT'İ SEÇ"][Language.languageIndex],
                            context: context,
                            initialTime:
                                TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
                          ).then((value) {
                            setState(() {
                              try {
                                _selectedFinishHour = ((value.hour.toString().length == 1)
                                        ? ("0" + value.hour.toString())
                                        : value.hour.toString()) +
                                    ":" +
                                    ((value.minute.toString().length == 1)
                                        ? ("0" + value.minute.toString())
                                        : value.minute.toString());
                              } catch (e) {
                                print(
                                    "[ERROR] [ADDEVENT] [showTimePicker] [_selectedFinishHour] $e");
                              }
                            });
                          });
                          showTimePicker(
                            cancelText: proTranslate["Geri"][Language.languageIndex],
                            confirmText: proTranslate["Tamam"][Language.languageIndex],
                            helpText: proTranslate["BAŞLANGIÇ SAAT'İ SEÇ"][Language.languageIndex],
                            context: context,
                            initialTime:
                                TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
                          ).then((value) {
                            setState(() {
                              try {
                                _selectedStartHour = ((value.hour.toString().length == 1)
                                        ? ("0" + value.hour.toString())
                                        : value.hour.toString()) +
                                    ":" +
                                    ((value.minute.toString().length == 1)
                                        ? ("0" + value.minute.toString())
                                        : value.minute.toString());
                              } catch (e) {
                                print(
                                    "[ERROR] [ADDEVENT] [showTimePicker] [_selectedStartHour] $e");
                              }
                            });
                          });
                        }
                        if (widget.date == null)
                          showDatePicker(
                            cancelText: proTranslate["Geri"][Language.languageIndex],
                            confirmText: proTranslate["Tamam"][Language.languageIndex],
                            helpText: Language.languageIndex == 1
                                ? proTranslate["TARİH SEÇ"]
                                : "TARİH SEÇ",
                            context: context,
                            locale:
                                Language.languageIndex == 0 ? Locale('tr', '') : Locale('en', ''),
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          ).then((value) {
                            setState(() {
                              try {
                                _selectedDate = value.year.toString() +
                                    "-" +
                                    ((value.month.toString().length == 1)
                                        ? ("0" + value.month.toString())
                                        : value.month.toString()) +
                                    "-" +
                                    (value.day.toString().length == 1
                                        ? "0" + value.day.toString()
                                        : value.day.toString());
                              } catch (e) {
                                print("[ERROR] [ADDEVENT] [showDatePicker] $e");
                              }
                            });
                          });
                      },
                      icon: Icon(Icons.add_circle),
                    ),
                    // Notification ayarlari
                    Container(
                      // padding: EdgeInsets.only(right: 40.0),
                      child: IconButton(
                        icon: Icon(Icons.notifications_active),
                        onPressed: () async {
                          var dialog = NotificationPicker();
                          await showDialog(context: context, child: dialog);
                          setState(() {
                            _radioValue = dialog.radioValue;
                          });
                        },
                      ),
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(Icons.mail),
                        onPressed: () async {
                          if (_recipient != "") {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmailSender(
                                          attacs: _attachments,
                                          cctext: _cc,
                                          bbtext: _bb,
                                          recipienttext: _recipient,
                                          subjecttext: _subject,
                                          bodytext: _body,
                                        ))).then((value) {
                              if (value != null) {
                                setState(() {
                                  _attachments = value[0];
                                  _cc = value[1];
                                  _bb = value[2];
                                  _recipient = value[3];
                                  _subject = value[4];
                                  _body = value[5];
                                });
                              }
                            });
                          } else {
                            await Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => EmailSender()))
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  _attachments = value[0];
                                  _cc = value[1];
                                  _bb = value[2];
                                  _recipient = value[3];
                                  _subject = value[4];
                                  _body = value[5];
                                });
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Divider(
                  height: 3,
                  thickness: 3,
                ),
              ),
              // Hata mesaji alani
              if (!_iscorrect)
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  //height: 75,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
                  child: Text(
                    errmsg,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(10.0, 4.0, 20.0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _options = !_options;
                        if (_options) {
                          _iconData = Icons.arrow_drop_up;
                        } else {
                          _iconData = Icons.arrow_drop_down;
                        }
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(_iconData),
                        Text(
                          proTranslate["Seçenekler"][Language.languageIndex],
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_options)
                Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 0),
                    child: Column(
                      children: <Widget>[
                        // Butun gun secenegi
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isfullday = !_isfullday;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: _isfullday,
                                onChanged: (value) => {
                                  setState(() {
                                    _isfullday = value;
                                  })
                                },
                              ),
                              Text(
                                proTranslate["Bütün gün"][Language.languageIndex],
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        // Geri sayim aktiflestirmesi
                        InkWell(
                          onTap: () {
                            setState(() {
                              _iscountdownchecked = !_iscountdownchecked;
                            });
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Checkbox(
                                  value: _iscountdownchecked,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _iscountdownchecked = value;
                                    });
                                  },
                                ),
                                Text(
                                  proTranslate["Geri sayım etkinleştir"][Language.languageIndex],
                                  style: TextStyle(fontSize: 20),
                                ),
                                IconButton(
                                    icon: Icon(Icons.info),
                                    onPressed: () {
                                      showWarningDialog(
                                          context: context,
                                          explanation: proTranslate[
                                                  "Geri sayım sayfasında etkinliğinize ne kadar süre kaldığını görebilirsiniz."]
                                              [Language.languageIndex]);
                                    }),
                              ],
                            ),
                          ),
                        ),
                        // Sabit bildirim
                        InkWell(
                          onTap: () {
//                            if (widget.warningstatus == 0) {
//                              navigateToSettingsDialog(context);
//                            }
                            setState(() {
                              _switchValue = !_switchValue;
                            });
                          },
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Checkbox(
                                  value: _switchValue,
                                  onChanged: (val) {
                                    setState(() {
                                      _switchValue = val;
                                    });
                                  },
                                ),
                                Text(
                                  proTranslate["Sabit bildirim"][Language.languageIndex],
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                IconButton(
                                    icon: Icon(Icons.info),
                                    onPressed: () {
                                      showWarningDialog(
                                          context: context,
                                          explanation: proTranslate[
                                                  "Sabit bildirim uygulama açıksa 1 dakikada bir güncellenir uygulama kapalı ise belirli aralıklarla güncellenir!"]
                                              [Language.languageIndex]);
                                    })
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _periodicCheckboxValue = !_periodicCheckboxValue;
                                if (_periodicCheckboxValue) {
                                  _iconData2 = Icons.arrow_drop_up;
                                } else {
                                  _iconData2 = Icons.arrow_drop_down;
                                }
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  _iconData2,
                                  size: 36,
                                ),
                                Text(
                                  proTranslate["Periyodik Etkinlik"][Language.languageIndex],
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_periodicCheckboxValue)
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: InkWell(
                                  onTap: () => setSelectedRadio(1),
                                  child: Row(
                                    children: <Widget>[
                                      Radio(
                                        value: 1,
                                        groupValue: _periodRadio,
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Text(proTranslate["Günlük"][Language.languageIndex],
                                          style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: InkWell(
                                  onTap: () => setSelectedRadio(2),
                                  child: Row(
                                    children: <Widget>[
                                      Radio(
                                        value: 2,
                                        groupValue: _periodRadio,
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Text(proTranslate["Haftalık"][Language.languageIndex],
                                          style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: InkWell(
                                  onTap: () => setSelectedRadio(3),
                                  child: Row(
                                    children: <Widget>[
                                      Radio(
                                        value: 3,
                                        groupValue: _periodRadio,
                                        onChanged: (val) {
                                          setSelectedRadio(val);
                                        },
                                      ),
                                      Text(proTranslate["Aylık"][Language.languageIndex],
                                          style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  DayPickerForPeriodic dayPicker = DayPickerForPeriodic();
                                  await showDialog(context: context, child: dayPicker);
                                  setState(() {
                                    _periodicDays = dayPicker.days;
                                    if (_periodicDays == null) {
                                      _periodicDays = [];
                                      _periodRadio = 0;
                                    } else {
                                      _periodRadio = 4;
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 29.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.calendar_today,
                                      ),
                                      Text(
                                        proTranslate["  Özel"][Language.languageIndex],
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    )),
              // Etkinlik aciklamasi
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
                height: 200.0,
                child: TextField(
                  controller: _descriptioncontroller,
                  maxLines: 7,
                  decoration: InputDecoration(
                    labelText: proTranslate["Etkinlik açıklaması ..."][Language.languageIndex],
                    hintText: proTranslate["Etkinlik detaylarının girileceği alan..."]
                        [Language.languageIndex],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              // Temizle ve kaydet butonlari
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      elevation: 18,
                      onPressed: () => {clearAreas()},
                      child: Text(
                        proTranslate["Temizle"][Language.languageIndex],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      color: Colors.blue,
                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      splashColor: Colors.lightBlueAccent,
                    ),
                    RaisedButton(
                      onPressed: () => {validateandsave()},
                      elevation: 18,
                      child: Text(
                        proTranslate["Kaydet"][Language.languageIndex],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      color: Colors.blue,
                      splashColor: Colors.lightBlueAccent,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  void asyncCall() async {
    await _db.getSettings().then((value) async{
      if(value[0].warning!= 1){
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.brand == "xiaomi" ||
            androidInfo.brand == "vivo" ||
            androidInfo.brand == "oneplus") {
          navigateToSettingsDialog(context);
      }
    }});
  }

  setSelectedRadio(int val) {
    setState(() {
      _periodRadio = val;
    });
  }

  List<int> parseHours(String value) {
    List<String> strHours = value.split(":");
    List<int> intHours = [];
    intHours.add(int.parse(strHours[0]));
    intHours.add(int.parse(strHours[1]));
    return intHours;
  }

  void clearAreas() {
    _titlecontroller.clear();
    _descriptioncontroller.clear();
    setState(() {
      _iscountdownchecked = false;
      _isfullday = false;
      _switchValue = false;
      _attachments = [];
      _cc = "";
      _bb = "";
      _recipient = "";
      _subject = "";
      _body = "";
      _periodRadio = 0;
      _frequency = "";
    });
  }

  void validateandsave() async {
    final FormState state = _formKey.currentState;

    setState(() {
      /// Eger tum gun degilse baslangic ve bitis zamanlari kontrol ediliyor olumsuzluk varsa hata mesaji yaziliyor
      if (!_isfullday) {
        _iscorrect = parseHours(_selectedFinishHour)[0] < parseHours(_selectedStartHour)[0] ||
                (parseHours(_selectedFinishHour)[0] == parseHours(_selectedStartHour)[0] &&
                    parseHours(_selectedFinishHour)[1] < parseHours(_selectedStartHour)[1])
            ? false
            : true;
        errmsg += _iscorrect == false
            ? "\n${proTranslate["Bitiş zamanı başlangıç zamanından önce olamaz"][Language.languageIndex]}"
            : "";
      }
    });
    String imagePaths = "";
    for (int i = 0; i < _attachments.length; i++) {
      imagePaths += "${_attachments[i]}-";
    }
    for (int i = 0; i < _periodicDays.length; i++) {
      setState(() {
        _frequency += _periodicDays[i] ? "1" : "0";
      });
    }
    _frequency.contains("1") ? _periodRadio = 4 : print("[ADDEVENT] frequency doesnt have '1'");
    if (state.validate() && _iscorrect) {
      var newEvent = (_isfullday)
          ? Event(
              title: _titlecontroller.text,
              date: _selectedDate,
              desc: _descriptioncontroller.text,
              isActive: _iscountdownchecked ? 1 : 0,
              choice: _radioValue.toString(),
              countDownIsActive: _switchValue ? 1 : 0,
              attachments: imagePaths,
              cc: _cc,
              bb: _bb,
              recipient: _recipient,
              subject: _subject,
              body: _body,
              periodic: _periodRadio,
              frequency: _frequency,
            )
          : Event(
              title: _titlecontroller.text,
              date: _selectedDate,
              startTime: _selectedStartHour,
              finishTime: _selectedFinishHour,
              desc: _descriptioncontroller.text,
              isActive: _iscountdownchecked ? 1 : 0,
              choice: _radioValue == null ? "0" : _radioValue.toString(),
              countDownIsActive: _switchValue ? 1 : 0,
              attachments: imagePaths,
              cc: _cc,
              bb: _bb,
              recipient: _recipient,
              subject: _subject,
              body: _body,
              periodic: _periodRadio,
              frequency: _frequency,
            );
      if (newEvent.recipient != "" && newEvent.choice == "0") {
        newEvent.choice = "1";
      }
      await _db.insertEvent(newEvent);
      await _db.createNotifications();
      _advert.showIntersitial();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu()));
      print("[ADDUNKNOWNEVENT] Form Uygun");
    } else {
      print("[ADDUNKNOWNEVENT] Form uygun değil");
    }
  }
}
