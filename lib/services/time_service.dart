import 'package:note_repository/models/service.dart';

class TimeService extends Service {
  TimeService._();

  static String _twoDigit(int number) {
    if (number > 9) return '$number';
    return '0$number';
  }

  static String encode(DateTime dateTime) {
    return '${_twoDigit(dateTime.day)}.${_twoDigit(dateTime.month)}.${dateTime.year}+${_twoDigit(dateTime.hour)}:${_twoDigit(dateTime.minute)}';
  }

  static DateTime decode(String dateTimeInfo) {
    final List<String> datesAndTimes = dateTimeInfo.split('+');
    final List<String> dates = datesAndTimes[0].split('.');
    final List<String> times = datesAndTimes[1].split(':');
    return DateTime(
      int.parse(dates[2]),
      int.parse(dates[1]),
      int.parse(dates[0]),
      int.parse(times[0]),
      int.parse(times[1]),
    );
  }

  static String videoTime(Duration duration) {
    int secondCount = duration.inSeconds;
    int minuteCount = (secondCount / Duration.secondsPerMinute).floor();
    secondCount -= minuteCount * Duration.secondsPerMinute;
    final int hourCount = (minuteCount / Duration.minutesPerHour).floor();
    minuteCount -= hourCount * Duration.minutesPerHour;
    return '${hourCount > 0 ? '$hourCount:' : ''}${_twoDigit(minuteCount)}:${_twoDigit(secondCount)}';
  }
}
