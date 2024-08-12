// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GeneratorRozvrhu extends StatefulWidget {
  const GeneratorRozvrhu({super.key});

  @override
  State<GeneratorRozvrhu> createState() => _GeneratorRozvrhuState();
}

class _GeneratorRozvrhuState extends State<GeneratorRozvrhu> {
  @override
  // Ked sa prvy krat zobrazi tento widget v tree, vygeneruje
  void initState() {
    super.initState();
    Sluzobnici = DefaultSluzobnici;
    int kolkomesiacovgenerovat = 3;
    DateTime SelectedDate = DateTime.now();
    hiddenGenerator(kolkomesiacovgenerovat: kolkomesiacovgenerovat, SelectedDate: SelectedDate);
  }

  var ScreenWidth = ((BuildContext context) => MediaQuery.of(context).size.width);

  String Sluzba = "Služba WC";
  String DefaultSluzba = "Služba WC";
  List<String> Sluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  List<String> DefaultSluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  String HintTextSluzobnici = "Rado Mišo Timo Aďo Šimon";
  int kolkomesiacov = 3;
  List<String> VyslednyRozvrh = [];
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  // textfield controllers
  TextEditingController SLuzobniciTcontroller = TextEditingController();
  TextEditingController NazovSluzbyTcontroller = TextEditingController();
  final List<TextEditingController> _controllers = [];

  ///// Generator
  void generateScheduleFromNearestSunday(
      {required DateTime dateToGenerateFrom,
      required int countersluzobnikovParameter,
      required int kolkomesiacov}) {
    DateTime generatorDate = dateToGenerateFrom;
    int counterSluzobnikov = countersluzobnikovParameter;
    bool yearChanged1 = false;
    bool yearChanged2 = false;
    VyslednyRozvrh.clear();
    initializeDateFormatting('sk_SK', null);
    VyslednyRozvrh.add(Sluzba);

    for (int i = 0; i < kolkomesiacov; i++) {
      //handling pesky year changes
      if (selectedDate.year != generatorDate.year && yearChanged1 == false) {
        yearChanged1 = true;
        VyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
      }
      // handling absolutely not critiacal year change scenario lol
      if (selectedDate.year != currentDate.year && yearChanged2 == false) {
        yearChanged2 = true;
        VyslednyRozvrh.add('----  ${DateFormat('yyyy', 'sk').format(generatorDate)} ----');
      }
      VyslednyRozvrh.add("----  ${DateFormat('MMMM', 'sk').format(generatorDate)} ----");

      int numberOfDaysInMonth = DateTime(generatorDate.year, generatorDate.month + 1, 0).day;
      for (int day = 1; day <= numberOfDaysInMonth; day++) {
        DateTime date = DateTime(generatorDate.year, generatorDate.month, day);
        if (date.weekday == DateTime.sunday) {
          if (date.isAfter(DateTime.now())) {
            String Sluzobnik = Sluzobnici[counterSluzobnikov % Sluzobnici.length];
            VyslednyRozvrh.add("${DateFormat('dd-MM').format(date)}   $Sluzobnik");
            counterSluzobnikov++;
          }
        }
      }
      generatorDate = DateTime(generatorDate.year, generatorDate.month + 1);
    }
  }

  void hiddenGenerator({required int kolkomesiacovgenerovat, required DateTime SelectedDate}) {
    // Its a date from which the generator starats cyclicng throucgh sundays
    DateTime generatorDateObject = (DateTime(SelectedDate.year));
    //will set int for how many months should the sluzobnicic counter add up
    int ThisMuchMonths = (DateTime(selectedDate.year).month + SelectedDate.month);

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
        dateToGenerateFrom: SelectedDate,
        countersluzobnikovParameter: CounterSluzobnikov,
        kolkomesiacov: kolkomesiacovgenerovat);
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Rozvrh'),
        centerTitle: true,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedDate != currentDate)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: FloatingActionButton(
                child: const Icon(Icons.highlight_remove_sharp),
                onPressed: () async {
                  setState(() {
                    selectedDate = currentDate;
                  });
                  hiddenGenerator(
                      kolkomesiacovgenerovat: kolkomesiacov, SelectedDate: selectedDate);
                },
              ),
            )
          else
            const SizedBox(
              width: 0,
            ),
          FloatingActionButton(
              child: const Icon(Icons.calendar_month_sharp),
              onPressed: () async {
                selectDate(context);
              }),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: TextFormField(
                            controller: NazovSluzbyTcontroller,
                            decoration:
                                InputDecoration(labelText: 'Názov Služby', hintText: " $Sluzba"),
                            onChanged: (value) {
                              Sluzba = value;
                              if (value == "") {
                                Sluzba = DefaultSluzba;
                              }
                              setState(() {
                                hiddenGenerator(
                                    kolkomesiacovgenerovat: kolkomesiacov,
                                    SelectedDate: selectedDate);
                              });
                            }),
                      ),
                      if (Sluzba != DefaultSluzba)
                        IconButton(
                          onPressed: () {
                            NazovSluzbyTcontroller.clear();
                            Sluzba = DefaultSluzba;
                            setState(() {
                              hiddenGenerator(
                                  kolkomesiacovgenerovat: kolkomesiacov,
                                  SelectedDate: selectedDate);
                            });
                          },
                          icon: const Icon(Icons.refresh_outlined),
                        ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: TextFormField(
                          controller: SLuzobniciTcontroller,
                          onChanged: (value) {
                            Sluzobnici = value.split(" ");
                            if (value == "") {
                              Sluzobnici = DefaultSluzobnici;
                            }
                            setState(() {
                              hiddenGenerator(
                                  kolkomesiacovgenerovat: kolkomesiacov,
                                  SelectedDate: selectedDate);
                            });
                          },
                          decoration: InputDecoration(
                              labelText: 'Služobníci', hintText: " $HintTextSluzobnici"),
                        ),
                      ),
                      if (Sluzobnici != DefaultSluzobnici)
                        IconButton(
                          onPressed: () {
                            SLuzobniciTcontroller.clear();
                            Sluzobnici = DefaultSluzobnici;
                            setState(() {
                              hiddenGenerator(
                                  kolkomesiacovgenerovat: kolkomesiacov,
                                  SelectedDate: selectedDate);
                            });
                          },
                          icon: const Icon(Icons.refresh_outlined),
                        ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Slider(
                      value: kolkomesiacov.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: '$kolkomesiacov',
                      onChanged: (double newValue) {
                        setState(() {
                          kolkomesiacov = newValue.toInt();
                        });
                        hiddenGenerator(
                            kolkomesiacovgenerovat: kolkomesiacov, SelectedDate: selectedDate);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: ListView.builder(
                      itemCount: VyslednyRozvrh.length,
                      itemBuilder: (context, index) {
                        _controllers.add(TextEditingController());

                        return AnimationConfiguration.staggeredList(
                            duration: const Duration(microseconds: 70000),
                            position: index,
                            child: SlideAnimation(
                                verticalOffset: 3,
                                child: ScaleAnimation(
                                  scale: 0.95,
                                  child: FadeInAnimation(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        TextField(
                                          cursorOpacityAnimates: true,
                                          decoration: null,
                                          maxLength: 70,
                                          enableInteractiveSelection: true,
                                          controller: _controllers[index],
                                          cursorColor: Theme.of(context).colorScheme.error,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          _controllers[index].text = VyslednyRozvrh[index],
                                          style: TextStyle(color: Colors.transparent),
                                        ),
                                      ],
                                    ),
                                  ),
                                )));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      currentDate: selectedDate,
      firstDate: currentDate,
      lastDate: currentDate.add(const Duration(days: 365 * 10)),
      helpText: 'Date for schedule',
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      hiddenGenerator(kolkomesiacovgenerovat: kolkomesiacov, SelectedDate: selectedDate);
    }
  }
}
