import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'generator_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UIGeneratorRozvrhu extends StatefulWidget {
  const UIGeneratorRozvrhu({super.key});

  @override
  State<UIGeneratorRozvrhu> createState() => _UIGeneratorRozvrhuState();
}

class _UIGeneratorRozvrhuState extends State<UIGeneratorRozvrhu> {
  final db = FirebaseFirestore.instance;
  final TextEditingController _nazovSluzbyTcontroller = TextEditingController();
  final TextEditingController _sluzobniciTcontroller = TextEditingController();
  final List<TextEditingController> _controllers = [];
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _generatedTextScrollController = ScrollController();
  final DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  DateTime? selectedSkipDate;
  bool isSelectedSkip = false;
  bool isSelectedDate = false;
  static final List<String> defaultSluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  List<String> selectedSluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  List<String> tempSluzobnici = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  static final String defaultSluzba = "Služba mužské WC";
  String sluzba = "Služba mužské WC";
  int kolkomesiacovgenerovat = 3;
  List<String> vyslednyRozvrh = [];

  @override
  void initState() {
    _initializeSchedule();
    _sluzobniciTcontroller.addListener(_updateTextFieldState);

    super.initState();
  }

  void _updateTextFieldState() {
    setState(() {
      // This empty setState will rebuild the UI when text changes
    });
  }

  _initializeSchedule() async {
    vyslednyRozvrh = await generateScheduleFromNearestSunday(
        sluzba: sluzba,
        sluzobnici: selectedSluzobnici,
        kolkomesiacovgenerovat: kolkomesiacovgenerovat,
        selectedDate: selectedDate);

    setState(() {});
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
        controller: _mainScrollController,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    nazov_textfield(),
                    sluzobnici_textfield(),
                    // debug_text(),
                    const SizedBox(height: 10),
                    sluzobnici_chipfield(),
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

  debug_text() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("default ${defaultSluzobnici.toString()}"),
          Text("selected ${selectedSluzobnici.toString()}"),
        ],
      ),
    );
  }

  sluzobnici_chipfield() {
    // if ((const ListEquality().equals(selectedSluzobnici, defaultSluzobnici))) {

    List<Widget> sluzobniciChipWidgetsList = tempSluzobnici
        .asMap()
        .map((index, meno) => MapEntry(
            index,
            InputChip(
              isEnabled: true,
              selected: selectedSluzobnici.contains(meno),
              onSelected: (_) async {
                if (selectedSluzobnici.contains(meno)) {
                  selectedSluzobnici.remove(meno);
                  setState(() {});

                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobnici,
                      selectedDate: selectedDate,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                  setState(() {});
                } else {
                  selectedSluzobnici.add(meno);
                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobnici,
                      selectedDate: selectedDate,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                  setState(() {});
                }
              },
              label: Text(meno),
            )))
        .values
        .toList();
    bool showSelectAll = !(selectedSluzobnici.length == tempSluzobnici.length);
    bool showDeSelectAll = (selectedSluzobnici.length == tempSluzobnici.length);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: sluzobniciChipWidgetsList,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      if (showDeSelectAll)
                        ActionChip(
                          label: Text("❌ všetkých"),
                          onPressed: () async {
                            selectedSluzobnici = [];
                            vyslednyRozvrh = await generateScheduleFromNearestSunday(
                                sluzba: sluzba,
                                sluzobnici: selectedSluzobnici,
                                kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                                selectedDate: selectedDate);
                            setState(() {});
                          },
                        ),
                      if (showSelectAll)
                        ActionChip(
                          label: Text("✅ všetkých"),
                          onPressed: () async {
                            selectedSluzobnici = [...tempSluzobnici];
                            vyslednyRozvrh = await generateScheduleFromNearestSunday(
                                sluzba: sluzba,
                                sluzobnici: selectedSluzobnici,
                                kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                                selectedDate: selectedDate);
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ],
              ),
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
        controller: _generatedTextScrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: vyslednyRozvrh.length,
              (BuildContext context, int index) {
                _controllers.add(TextEditingController());
                return AnimationConfiguration.staggeredList(
                  duration: const Duration(
                    microseconds: 160000,
                  ),
                  position: index,
                  child: SlideAnimation(
                    verticalOffset: 5,
                    child: ScaleAnimation(
                      duration: const Duration(
                        microseconds: 80000,
                      ),
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
          _controllers[index].text = vyslednyRozvrh[index],
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
            value: kolkomesiacovgenerovat.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$kolkomesiacovgenerovat',
            onChanged: selectedSluzobnici.isEmpty
                ? null
                : (double newValue) async {
                    kolkomesiacovgenerovat = newValue.toInt();
                    vyslednyRozvrh = await generateScheduleFromNearestSunday(
                        sluzba: sluzba,
                        sluzobnici: selectedSluzobnici,
                        selectedDate: selectedDate,
                        kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                        skipDate: selectedSkipDate);
                    setState(() {});
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
            onFieldSubmitted: (value) async {
              if (value.isNotEmpty) {
                tempSluzobnici.add(value);
                selectedSluzobnici.add(value);
                vyslednyRozvrh = await generateScheduleFromNearestSunday(
                    sluzba: sluzba,
                    sluzobnici: selectedSluzobnici,
                    kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                    selectedDate: selectedDate);
                _sluzobniciTcontroller.clear();
                setState(() {});
              }
            },
            decoration: const InputDecoration(labelText: 'Služobníci'),
          ),
        ),
        // if (ListEquality().equals(selectedSluzobnici, defaultSluzobnici))
        IconButton(
          onPressed: () async {
            _sluzobniciTcontroller.clear();
            selectedSluzobnici = [...defaultSluzobnici];

            vyslednyRozvrh = await generateScheduleFromNearestSunday(
                sluzba: sluzba,
                sluzobnici: selectedSluzobnici,
                selectedDate: selectedDate,
                kolkomesiacovgenerovat: kolkomesiacovgenerovat);
            setState(() {});
          },
          icon: const Icon(Icons.refresh_outlined),
        ),
        if (_sluzobniciTcontroller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: IconButton(
              onPressed: () async {
                final value = _sluzobniciTcontroller.text;
                if (value.isNotEmpty) {
                  tempSluzobnici.add(value);
                  selectedSluzobnici.add(value);
                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobnici,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                      selectedDate: selectedDate);
                  _sluzobniciTcontroller.clear();
                  setState(() {});
                }
              },
              icon: const Icon(Icons.check),
            ),
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
              onChanged: (value) async {
                sluzba = value.isEmpty ? "" : value;

                vyslednyRozvrh = await generateScheduleFromNearestSunday(
                    sluzba: sluzba,
                    sluzobnici: selectedSluzobnici,
                    selectedDate: selectedDate,
                    kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                setState(() {});
              }),
        ),
        if (sluzba != "Služba mužské WC")
          IconButton(
            onPressed: () async {
              _nazovSluzbyTcontroller.clear();
              sluzba = defaultSluzba;

              vyslednyRozvrh = await generateScheduleFromNearestSunday(
                  sluzba: sluzba,
                  sluzobnici: selectedSluzobnici,
                  selectedDate: selectedDate,
                  kolkomesiacovgenerovat: kolkomesiacovgenerovat);
              setState(() {});
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
            if (selectedSkipDate != null)
              FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Icon(Icons.clear),
                    Text('Clear skip'),
                  ],
                ),
                onPressed: () async {
                  selectedSkipDate = null;
                  isSelectedSkip = !isSelectedSkip;

                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobnici,
                      selectedDate: selectedDate,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                  setState(() {});
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
            if (selectedDate != currentDate)
              FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Icon(Icons.clear),
                    Text('Clear date'),
                  ],
                ),
                onPressed: () async {
                  selectedDate = currentDate;
                  isSelectedDate = !isSelectedDate;

                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobnici,
                      selectedDate: selectedDate,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                  setState(() {});
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
      currentDate: selectedDate,
      firstDate: currentDate,
      lastDate: currentDate.add(const Duration(days: 365 * 10)),
      helpText: 'Vyber dátum, od ktorého sa bude generovať rozvrh',
    );
    if (picked != null) {
      selectedDate = picked;
      if (isSelectedDate != true) {
        isSelectedDate = !isSelectedDate;
      }

      vyslednyRozvrh = await generateScheduleFromNearestSunday(
          sluzba: sluzba,
          sluzobnici: selectedSluzobnici,
          selectedDate: selectedDate,
          kolkomesiacovgenerovat: kolkomesiacovgenerovat,
          skipDate: selectedSkipDate);
      setState(() {});
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
      currentDate: selectedSkipDate,
      firstDate: currentDate,
      lastDate: currentDate.add(const Duration(days: 365 * 10)),
      helpText: 'Vyber týždeň ktorý bude v generovaní preskočený',
    );
    if (picked != null) {
      selectedSkipDate = picked;
      if (isSelectedSkip != true) {
        isSelectedSkip = !isSelectedSkip;
      }
      vyslednyRozvrh = await generateScheduleFromNearestSunday(
          sluzba: sluzba,
          sluzobnici: selectedSluzobnici,
          selectedDate: selectedDate,
          kolkomesiacovgenerovat: kolkomesiacovgenerovat,
          skipDate: picked);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _sluzobniciTcontroller.removeListener(_updateTextFieldState);
    _sluzobniciTcontroller.dispose();
    _nazovSluzbyTcontroller.dispose();
    for (TextEditingController controller in _controllers) {
      controller.dispose();
    }
    _mainScrollController.dispose();
    _generatedTextScrollController.dispose();
    super.dispose();
  }
}
