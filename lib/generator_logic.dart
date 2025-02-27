// generator_logic.dart

// ignore_for_file: non_constant_identifier_names, unnecessary_getters_setters

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScheduleGenerator {
  final String _skipString = '🚨--< skip >--🚨';
  String _sluzba = "Služba mužské WC";
  final String _defaultSluzba = "Služba mužské WC";
  List<String> _sluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  final List<String> _defaultSluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  int _kolkomesiacov = 3;
  final List<String> _vyslednyRozvrh = [];
  DateTime _referenceDate = DateTime.now();

  Future<void> generateScheduleFromNearestSunday({
    required DateTime selectedDate,
    required int kolkomesiacovgenerovat,
    DateTime? skipDate,
    String? skipString,
  }) async {
    skipString ??= _skipString;
    DateTime generatorDate = selectedDate;
    int counterSluzobnikov = _counterSluzobnikovGenerator(
        kolkomesiacovgenerovat: kolkomesiacovgenerovat, selectedDate: _referenceDate);
    bool yearChanged1 = false;
    // bool yearChanged2 = false;

    _sluzobnici.sort();
    _vyslednyRozvrh.clear();
    initializeDateFormatting('sk_SK', null);
    _vyslednyRozvrh.add(_sluzba);

    //  based on if current month does not have any more coming sundays
    // first, check if there are any sundays after today in the current month
    kolkomesiacovgenerovat = checkAndActOnIfCurrentMonthHasNextSundays(kolkomesiacovgenerovat);

    for (int i = 0; i < kolkomesiacovgenerovat; i++) {
      int numberOfDaysInMonth = DateTime(generatorDate.year, generatorDate.month + 1, 0).day;

      // handling pesky year changes
      if (_referenceDate.year != generatorDate.year && yearChanged1 == false) {
        yearChanged1 = true;
        _vyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
      }
      // // handling absolutely not going to happen second year change scenario lol
      // if (_referenceDate.year != DateTime.now().year && yearChanged2 == false) {
      //   yearChanged2 = true;
      //   _vyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
      // }

      // check if current month have any next sundays, if not, do not display current month string
      // this is only helping in generating without custom date
      for (int day = 1; day <= numberOfDaysInMonth; day++) {
        DateTime checkDateObject = DateTime(_referenceDate.year, _referenceDate.month, day);
        if (checkDateObject.weekday == DateTime.sunday && checkDateObject.isAfter(DateTime.now())) {
          _vyslednyRozvrh.add("----  ${DateFormat('MMMM', 'sk').format(generatorDate)} ----");
          break;
        }
      }

      for (int day = 1; day <= numberOfDaysInMonth; day++) {
        DateTime date = DateTime(generatorDate.year, generatorDate.month, day);
        if (date.weekday == DateTime.sunday && date.isAfter(DateTime.now())) {
          if (skipDate != null) {
            if (skipDate == date) {
              _vyslednyRozvrh.add('${DateFormat('dd-MM').format(date)}  $skipString');
              counterSluzobnikov++;
            } else {
              String sluzobnik = _sluzobnici[counterSluzobnikov % _sluzobnici.length];
              _vyslednyRozvrh.add("${DateFormat('dd-MM').format(date)}   $sluzobnik");
              counterSluzobnikov++;
            }
          } else {
            String sluzobnik = _sluzobnici[counterSluzobnikov % _sluzobnici.length];
            _vyslednyRozvrh.add("${DateFormat('dd-MM').format(date)}   $sluzobnik");
            counterSluzobnikov++;
          }
        }
      }
      generatorDate = DateTime(generatorDate.year, generatorDate.month + 1);
    }
  }

  int checkAndActOnIfCurrentMonthHasNextSundays(int kolkomesiacovgenerovat) {
    bool hasFutureSundays = false;
    int referenceNumberOfDays = DateTime(_referenceDate.year, _referenceDate.month + 1, 0).day;

    for (int day = 1; day <= referenceNumberOfDays; day++) {
      DateTime referenceDateObject = DateTime(_referenceDate.year, _referenceDate.month, day);
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

  List<String> get VyslednyRozvrh => _vyslednyRozvrh;

  int get Kolkomesiacov => _kolkomesiacov;

  String get Sluzba => _sluzba;

  List<String> get Sluzobnici => _sluzobnici;

  String get defaultSluzba => _defaultSluzba;
  List<String> get DefaultSluzobnici => _defaultSluzobnici;

  set Sluzba(String value) {
    _sluzba = value;
  }

  set Sluzobnici(List<String> value) {
    _sluzobnici = value;
  }

  set Kolkomesiacov(int value) {
    _kolkomesiacov = value;
  }

  set SelectedDate(DateTime value) {
    _referenceDate = value;
  }
}
