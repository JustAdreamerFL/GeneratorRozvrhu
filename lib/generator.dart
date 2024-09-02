// generator_logic.dart

// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScheduleGenerator {
  String _sluzba = "Služba WC";
  final String _defaultSluzba = "Služba WC";
  List<String> _sluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  final List<String> _defaultSluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  int _kolkomesiacov = 3;
  final List<String> _vyslednyRozvrh = [];
  DateTime _selectedDate = DateTime.now();

  void generateScheduleFromNearestSunday({
    required DateTime dateToGenerateFrom,
    required int countersluzobnikovParameter,
    required int kolkomesiacov,
  }) {
    DateTime generatorDate = dateToGenerateFrom;
    int counterSluzobnikov = countersluzobnikovParameter;
    bool yearChanged1 = false;
    bool yearChanged2 = false;
    _sluzobnici.sort();
    _vyslednyRozvrh.clear();
    initializeDateFormatting('sk_SK', null);
    _vyslednyRozvrh.add(_sluzba);

    for (int i = 0; i < kolkomesiacov; i++) {
      // handling pesky year changes
      if (_selectedDate.year != generatorDate.year && yearChanged1 == false) {
        yearChanged1 = true;
        _vyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
      }
      // handling absolutely not critical year change scenario lol
      if (_selectedDate.year != DateTime.now().year && yearChanged2 == false) {
        yearChanged2 = true;
        _vyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
      }
      _vyslednyRozvrh.add("----  ${DateFormat('MMMM', 'sk').format(generatorDate)} ----");

      int numberOfDaysInMonth = DateTime(generatorDate.year, generatorDate.month + 1, 0).day;
      for (int day = 1; day <= numberOfDaysInMonth; day++) {
        DateTime date = DateTime(generatorDate.year, generatorDate.month, day);
        if (date.weekday == DateTime.sunday) {
          if (date.isAfter(DateTime.now())) {
            String sluzobnik = _sluzobnici[counterSluzobnikov % _sluzobnici.length];
            _vyslednyRozvrh.add("${DateFormat('dd-MM').format(date)}   $sluzobnik");
            counterSluzobnikov++;
          }
        }
      }
      generatorDate = DateTime(generatorDate.year, generatorDate.month + 1);
    }
  }

  void hiddenGenerator({
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
    generateScheduleFromNearestSunday(
        dateToGenerateFrom: selectedDate,
        countersluzobnikovParameter: CounterSluzobnikov,
        kolkomesiacov: kolkomesiacovgenerovat);
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
    _selectedDate = value;
  }
}
