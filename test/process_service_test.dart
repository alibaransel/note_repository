import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:note_repository/services/process_service.dart';

void main() {
  test(
    'Process Service test',
    () async {
      await ProcessService().init();
      final List<int> nList = List.generate(40, (i) => Random().nextInt(10) + 35);
      final Stopwatch stopwatch = Stopwatch()..start();
      final dynamic result1 = singleIsolateDecode(nList);
      stopwatch.stop();
      final Duration singleIsolateDuration = stopwatch.elapsed;
      stopwatch
        ..reset()
        ..start();
      final dynamic result2 = await multiIsolateDecode(nList);
      stopwatch.stop();
      final Duration multiIsolateDuration = stopwatch.elapsed;
      expect(result1 == result2, true);
      expect(multiIsolateDuration < singleIsolateDuration, true);
    },
  );
}

int singleIsolateDecode(List<int> nList) {
  int result = 0;

  for (final int n in nList) {
    result += slowFib(n);
  }

  return result;
}

Future<int> multiIsolateDecode(List<int> nList) async {
  int result = 0;

  await Future.wait(
    List.generate(nList.length, (i) {
      return ProcessService().process(() {
        return slowFib(nList[i]);
      }).then((value) => result += value);
    }),
  );

  return result;
}

int slowFib(int n) {
  if (n < 3) return 1;
  return slowFib(n - 1) + slowFib(n - 2);
}
