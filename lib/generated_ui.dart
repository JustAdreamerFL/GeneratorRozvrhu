// TODO: ak v current mesiaci nie je už ďaľšia nedela, skipni ten mesiac ale nech to vygeneruje stále korektný počet zvolených mesiacov
//TODO: jednotlive chips pre meno sluzobnika, a dva tlacidla pre oznacenie kazdeho a odoznacenie kazdeho, schovane v modal sheet

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'generator_logic.dart';

class UIGeneratorRozvrhu extends StatefulWidget {
  const UIGeneratorRozvrhu({super.key});

  @override
  State<UIGeneratorRozvrhu> createState() => _UIGeneratorRozvrhuState();
}

class _UIGeneratorRozvrhuState extends State<UIGeneratorRozvrhu> {
  final ScheduleGenerator _generator = ScheduleGenerator();
  final TextEditingController _nazovSluzbyTcontroller = TextEditingController();
  final TextEditingController _sluzobniciTcontroller = TextEditingController();
  final List<TextEditingController> _controllers = [];
  final ScrollController _randomScrollController = ScrollController();
  final DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedSkipDate;
  bool isSelectedSkip = false;
  bool isSelectedDate = false;
  @override
  void initState() {
    _generator.Sluzobnici = _generator.DefaultSluzobnici;
    _generator.SelectedDate = _selectedDate;
    unawaited(_generator.generateScheduleFromNearestSunday(
        selectedDate: _selectedDate, kolkomesiacovgenerovat: _generator.Kolkomesiacov));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: Padding(
        // fiix for weird unalignment from sides
        padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
        child: dateRows(theme, colorScheme, context),
      ),
      body: CustomScrollView(
        controller: _randomScrollController,
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            centerTitle: true,
            title: const Text('Rozvrh Služieb Generátor'),
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surface,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              //tu začina body
              [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    nazov_textfield(),
                    sluzobnici_textfield(),
                    mesiace_slider(),
                    const SizedBox(height: 10),
                    generated_text(context)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox generated_text(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: CustomScrollView(
        controller: _randomScrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: _generator.VyslednyRozvrh.length,
              (BuildContext context, int index) {
                _controllers.add(TextEditingController());
                return AnimationConfiguration.staggeredList(
                  duration: const Duration(
                    microseconds: 160000,
                  ), //TODO: make editable via slider in some settings
                  position: index,
                  child: SlideAnimation(
                    verticalOffset: 5,
                    child: ScaleAnimation(
                      duration: const Duration(
                        microseconds: 80000,
                      ), //TODO: half the variable
                      scale: 0.8,
                      child: FadeInAnimation(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [generated_content_widgets(index, context)],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stack generated_content_widgets(int index, BuildContext context) {
    return Stack(
      children: [
        Text(
          _controllers[index].text = _generator.VyslednyRozvrh[index],
          style: const TextStyle(
            color: Color.fromARGB(0, 255, 0, 0),
          ),
        ),
        TextField(
          cursorOpacityAnimates: true,
          decoration: null,
          enableInteractiveSelection: false,
          controller: _controllers[index],
          cursorColor: Theme.of(context).colorScheme.error,
          textAlign: TextAlign.center,
          //style: TextStyle(color: Color.fromARGB(0, 255, 0, 0)),
        ),
      ],
    );
  }

  ConstrainedBox mesiace_slider() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          const SizedBox(height: 15),
          const Text('Mesiace', style: null),
          Slider(
            value: _generator.Kolkomesiacov.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '${_generator.Kolkomesiacov}',
            onChanged: (double newValue) {
              setState(() {
                _generator.Kolkomesiacov = newValue.toInt();
              });
              _generator.generateScheduleFromNearestSunday(
                  kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                  selectedDate: _selectedDate,
                  skipDate: _selectedSkipDate);
            },
          ),
        ],
      ),
    );
  }

  Stack sluzobnici_textfield() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextFormField(
            controller: _sluzobniciTcontroller,
            onChanged: (value) {
              List<String> sluzobnici = value.split(" ").map((e) => e.trim()).toList();
              if (value.isEmpty) {
                sluzobnici = [];
              }
              setState(() {
                _generator.Sluzobnici = sluzobnici.isEmpty ? [] : sluzobnici;
                _generator.generateScheduleFromNearestSunday(
                    kolkomesiacovgenerovat: _generator.Kolkomesiacov, selectedDate: _selectedDate);
              });
            },
            decoration: const InputDecoration(labelText: 'Služobníci', hintText: " "),
          ),
        ),
        if (_generator.Sluzobnici != _generator.DefaultSluzobnici)
          IconButton(
            onPressed: () {
              _sluzobniciTcontroller.clear();
              _generator.Sluzobnici = _generator.DefaultSluzobnici;
              setState(() {
                _generator.generateScheduleFromNearestSunday(
                    kolkomesiacovgenerovat: _generator.Kolkomesiacov, selectedDate: _selectedDate);
              });
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
      ],
    );
  }

  Stack nazov_textfield() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextFormField(
              controller: _nazovSluzbyTcontroller,
              decoration: const InputDecoration(labelText: 'Názov Služby', hintText: " "),
              onChanged: (value) {
                _generator.Sluzba = value.isEmpty ? "" : value;
                setState(() {
                  _generator.generateScheduleFromNearestSunday(
                      kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                      selectedDate: _selectedDate);
                });
              }),
        ),
        if (_generator.Sluzba != "Služba mužské WC")
          IconButton(
            onPressed: () {
              _nazovSluzbyTcontroller.clear();
              _generator.Sluzba = _generator.defaultSluzba;
              setState(() {
                _generator.generateScheduleFromNearestSunday(
                    kolkomesiacovgenerovat: _generator.Kolkomesiacov, selectedDate: _selectedDate);
              });
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
      ],
    );
  }

  Row dateRows(ThemeData theme_data, ColorScheme color_scheme, BuildContext context) {
    return Row(
      //rows at the bottom to set a skip date or generate from date
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_selectedSkipDate != null)
              FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Icon(Icons.clear),
                    Text('Clear skip'),
                  ],
                ),
                onPressed: () async {
                  setState(() {
                    _selectedSkipDate = null;
                    isSelectedSkip = !isSelectedSkip;
                  });
                  _generator.generateScheduleFromNearestSunday(
                      kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                      selectedDate: _selectedDate);
                },
              )
            else
              const SizedBox(),
            const SizedBox(
              height: 5,
            ),
            FloatingActionButton.small(
                foregroundColor: isSelectedSkip
                    ? theme_data.floatingActionButtonTheme.foregroundColor
                    : color_scheme.onPrimary,
                backgroundColor: isSelectedSkip
                    ? theme_data.floatingActionButtonTheme.backgroundColor
                    : color_scheme.primary,
                child: const Icon(Icons.calendar_month_sharp),
                onPressed: () async {
                  selectSkipDateDialog(context);
                }),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_selectedDate != _currentDate)
              FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Icon(Icons.clear),
                    Text('Clear date'),
                  ],
                ),
                onPressed: () async {
                  setState(() {
                    _selectedDate = _currentDate;
                    isSelectedDate = !isSelectedDate;
                  });
                  _generator.generateScheduleFromNearestSunday(
                      kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                      selectedDate: _selectedDate);
                },
              )
            else
              const SizedBox(),
            const SizedBox(
              height: 5,
            ),
            FloatingActionButton.small(
                foregroundColor: isSelectedDate
                    ? theme_data.floatingActionButtonTheme.foregroundColor
                    : color_scheme.onPrimary,
                backgroundColor: isSelectedDate
                    ? theme_data.floatingActionButtonTheme.backgroundColor
                    : color_scheme.primary,
                child: const Icon(Icons.calendar_month_sharp),
                onPressed: () async {
                  selectDateDialog(context);
                }),
          ],
        ),
      ],
    );
  }

  Future<void> selectDateDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      currentDate: _selectedDate,
      firstDate: _currentDate,
      lastDate: _currentDate.add(const Duration(days: 365 * 10)),
      helpText: 'Date for schedule',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (isSelectedDate != true) {
          isSelectedDate = !isSelectedDate;
        }
      });
      _generator.generateScheduleFromNearestSunday(
          kolkomesiacovgenerovat: _generator.Kolkomesiacov,
          selectedDate: _selectedDate,
          skipDate: _selectedSkipDate);
    }
  }

  Future<void> selectSkipDateDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      selectableDayPredicate: (day) {
        if (day.weekday == DateTime.sunday) {
          return true;
        } else {
          return false;
        }
      },
      currentDate: _selectedSkipDate,
      firstDate: _currentDate,
      lastDate: _currentDate.add(const Duration(days: 365 * 10)),
      helpText: 'Skip this date',
    );
    if (picked != null) {
      setState(() {
        _selectedSkipDate = picked;
        if (isSelectedSkip != true) {
          isSelectedSkip = !isSelectedSkip;
        }
      });
      _generator.generateScheduleFromNearestSunday(
        kolkomesiacovgenerovat: _generator.Kolkomesiacov,
        selectedDate: _selectedDate,
        skipDate: picked,
      );
    }
  }
}
