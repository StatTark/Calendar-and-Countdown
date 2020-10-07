import 'package:intl/intl.dart';

bool validateDayIsEmpty(value, selectedStartHour, selectedFinishHour, {id}) {
  for (int i = 0; i < value.length; i++) {
    if ((value[i].id == Null) || (value[i].id == id) || (value[i].startTime == "null")) {
      continue;
    }
    var formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(DateTime.now());
    var vStart = DateTime.parse(formatted + " ${value[i].startTime}");
    var vFinish = DateTime.parse(formatted + " ${value[i].finishTime}");
    var start = DateTime.parse(formatted + " $selectedStartHour");
    var finish = DateTime.parse(formatted + " $selectedFinishHour");

    print("ssh : $selectedStartHour sfh : $selectedFinishHour");
    print("start : $start finish : $finish");
    print("vstart : $vStart vfinish : $vFinish");
    // startTime == value[i].startTime && startTime == ...
    if(start == vStart){
      return false;
    }
    //
    if(start.isBefore(vStart) && finish.isAfter(vStart)){
      return false;
    }
    // value[i].startTime < selectedStartHour  < value[i].finishTime
    if (start.isAfter(vStart) && start.isBefore(vFinish)) {
      return false;
    }
    // value[i].startTime < selectedFinishHour  < value[i].finishTime
    if (finish.isBefore(vFinish) && finish.isAfter(vStart)) {
      return false;
    }
  }
  return true;
}