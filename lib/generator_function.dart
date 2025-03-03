import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<List<String>> generateScheduleFromNearestSunday({
  required String sluzba,
  required List<String> sluzobnici,
  required int kolkomesiacovgenerovat,
  required DateTime selectedDate,
  DateTime? skipDate,
  String? skipString,
}) async {
  if (sluzobnici.isEmpty) {
    return ["Pridaj dakoho, inak bude zle."];
  }
  skipString ??= '🚨--< skip >--🚨';
  DateTime referenceDate = DateTime.now();
  DateTime generatorDate = selectedDate;
  int counterSluzobnikov = _counterSluzobnikovGenerator(
      kolkomesiacovgenerovat: kolkomesiacovgenerovat, selectedDate: referenceDate);
  bool yearChanged1 = false;
  // bool yearChanged2 = false;

  sluzobnici.sort();
  List<String> vyslednyRozvrh = [];
  vyslednyRozvrh.clear();
  initializeDateFormatting('sk_SK', null);
  vyslednyRozvrh.add(sluzba);

  //  based on if current month does not have any more coming sundays
  // first, check if there are any sundays after today in the current month
  kolkomesiacovgenerovat =
      checkAndActOnIfCurrentMonthHasNextSundays(kolkomesiacovgenerovat, referenceDate);

  for (int i = 0; i < kolkomesiacovgenerovat; i++) {
    int numberOfDaysInMonth = DateTime(generatorDate.year, generatorDate.month + 1, 0).day;

    // handling pesky year changes
    if (referenceDate.year != generatorDate.year && yearChanged1 == false) {
      yearChanged1 = true;
      vyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
    }
    // // handling absolutely not going to happen second year change scenario lol
    // if (referenceDate.year != DateTime.now().year && yearChanged2 == false) {
    //   yearChanged2 = true;
    //   _vyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
    // }

    // check if current month have any next sundays, if not, do not display current month string
    // this is only helping in generating without custom date
    for (int day = 1; day <= numberOfDaysInMonth; day++) {
      DateTime checkDateObject = DateTime(referenceDate.year, referenceDate.month, day);
      if (checkDateObject.weekday == DateTime.sunday && checkDateObject.isAfter(DateTime.now())) {
        vyslednyRozvrh.add("----  ${DateFormat('MMMM', 'sk').format(generatorDate)} ----");
        break;
      }
    }

    for (int day = 1; day <= numberOfDaysInMonth; day++) {
      DateTime date = DateTime(generatorDate.year, generatorDate.month, day);
      if (date.weekday == DateTime.sunday && date.isAfter(DateTime.now())) {
        if (skipDate != null) {
          if (skipDate == date) {
            vyslednyRozvrh.add('${DateFormat('dd-MM').format(date)}  $skipString');
            counterSluzobnikov++;
          } else {
            String sluzobnik = sluzobnici[counterSluzobnikov % sluzobnici.length];
            vyslednyRozvrh.add("${DateFormat('dd-MM').format(date)}   $sluzobnik");
            counterSluzobnikov++;
          }
        } else {
          String sluzobnik = sluzobnici[counterSluzobnikov % sluzobnici.length];
          vyslednyRozvrh.add("${DateFormat('dd-MM').format(date)}   $sluzobnik");
          counterSluzobnikov++;
        }
      }
    }
    generatorDate = DateTime(generatorDate.year, generatorDate.month + 1);
  }
  return vyslednyRozvrh;
}

int checkAndActOnIfCurrentMonthHasNextSundays(int kolkomesiacovgenerovat, DateTime referenceDate) {
  bool hasFutureSundays = false;

  int referenceNumberOfDays = DateTime(referenceDate.year, referenceDate.month + 1, 0).day;

  for (int day = 1; day <= referenceNumberOfDays; day++) {
    DateTime referenceDateObject = DateTime(referenceDate.year, referenceDate.month, day);
    if (referenceDateObject.weekday == DateTime.sunday &&
        referenceDateObject.isAfter(DateTime.now())) {
      hasFutureSundays = true;
      break;
    }
  }
  // socendly, only increment if there are no future Sundays
  if (!hasFutureSundays) {
    kolkomesiacovgenerovat += 1;
  }
  return kolkomesiacovgenerovat;
}

_counterSluzobnikovGenerator({
  required int kolkomesiacovgenerovat,
  required DateTime selectedDate,
}) {
  // Its a date from which the generator starts cycling through sundays
  DateTime generatorDateObject = (DateTime(selectedDate.year));
  //will set int for how many months should the sluzobnicic counter add up
  int ThisMuchMonths = (DateTime(selectedDate.year).month + selectedDate.month);

  int CounterSluzobnikov = 0;
  //when this counter fills up, generator has reached an end
  int CounterMesiacov = 0;
  int numberOfDaysInMonth =
      DateTime(generatorDateObject.year, generatorDateObject.month + 1, 0).day;

  while (CounterMesiacov != ThisMuchMonths) {
    CounterMesiacov++;
    for (int day = 1; day <= numberOfDaysInMonth; day++) {
      DateTime date = DateTime(generatorDateObject.year, generatorDateObject.month, day);
      if (date.weekday == DateTime.sunday) {
        CounterSluzobnikov++;
      }
    }
    generatorDateObject = DateTime(generatorDateObject.year, generatorDateObject.month + 1);
  }
  return CounterSluzobnikov;
}
