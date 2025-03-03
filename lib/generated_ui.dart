import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'generator_function.dart';

class UIGeneratorRozvrhu extends StatefulWidget {
  const UIGeneratorRozvrhu({super.key});

  @override
  State<UIGeneratorRozvrhu> createState() => _UIGeneratorRozvrhuState();
}

class _UIGeneratorRozvrhuState extends State<UIGeneratorRozvrhu> {
  final TextEditingController _nazovSluzbyTcontroller = TextEditingController();
  // final TextEditingController _sluzobniciTcontroller = TextEditingController();
  final List<TextEditingController> _controllers = [];
  final ScrollController _randomScrollController = ScrollController();
  final DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  DateTime? selectedSkipDate;
  bool isSelectedSkip = false;
  bool isSelectedDate = false;
  final List<String> defaultSluzobniciList = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  List<String> selectedSluzobniciList = ["Rado", "Mišo", "Timo", "Aďo", "Šimon"];
  final String defaultSluzba = "Služba mužské WC";
  String sluzba = "Služba mužské WC";
  int kolkomesiacovgenerovat = 3;
  List<String> vyslednyRozvrh = [];

  @override
  void initState() {
    _initializeSchedule();
    // selectedSluzobniciList = defaultSluzobniciList;
    super.initState();
  }

  _initializeSchedule() async {
    vyslednyRozvrh = await generateScheduleFromNearestSunday(
        sluzba: sluzba,
        sluzobnici: selectedSluzobniciList,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    nazov_textfield(),
                    // sluzobnici_textfield(),
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

  // sluzobnici_chipfield() {
  //   var itemCount = 20;
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
  //     child: WrapBuilder(
  //         wrapAlignment: WrapAlignment.center,
  //         runAlignment: WrapAlignment.center,
  //         itemBuilder: (BuildContext context, ) {
  //           // return Chip(label: Text("data"));
  //           return Chip(label: Text("{$sluzobnicic}"));
  //         },
  //         itemCount: itemCount,
  //         reversed: false),
  //   );
  // }
  sluzobnici_chipfield() {
    List<Widget> sluzobniciChipWidgetsList = defaultSluzobniciList
        .asMap()
        .map((index, meno) => MapEntry(
            index,
            InputChip(
              isEnabled: true,
              selected: selectedSluzobniciList.contains(meno),
              onSelected: (_) async {
                if (selectedSluzobniciList.contains(meno)) {
                  selectedSluzobniciList.remove(meno);
                  setState(() {});

                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobniciList,
                      selectedDate: selectedDate,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                  setState(() {});
                } else {
                  selectedSluzobniciList.add(meno);
                  vyslednyRozvrh = await generateScheduleFromNearestSunday(
                      sluzba: sluzba,
                      sluzobnici: selectedSluzobniciList,
                      selectedDate: selectedDate,
                      kolkomesiacovgenerovat: kolkomesiacovgenerovat);
                  setState(() {});
                }
              },
              label: Text(meno),
            )))
        .values
        .toList();
    bool showSelectAll = !(selectedSluzobniciList.length == defaultSluzobniciList.length);
    bool showDeSelectAll = (selectedSluzobniciList.length == defaultSluzobniciList.length);
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
                            selectedSluzobniciList = [];
                            vyslednyRozvrh = await generateScheduleFromNearestSunday(
                                sluzba: sluzba,
                                sluzobnici: selectedSluzobniciList,
                                kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                                selectedDate: selectedDate);
                            setState(() {});
                          },
                        ),
                      if (showSelectAll)
                        ActionChip(
                          label: Text("✔️ všetkých"),
                          onPressed: () async {
                            selectedSluzobniciList = [...defaultSluzobniciList];
                            vyslednyRozvrh = await generateScheduleFromNearestSunday(
                                sluzba: sluzba,
                                sluzobnici: selectedSluzobniciList,
                                kolkomesiacovgenerovat: kolkomesiacovgenerovat,
                                selectedDate: selectedDate);
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                  // Column(
                  //   children: [
                  //     Text("selected"),
                  //     Row(
                  //       children: selectedSluzobniciList.map((sluzobnik) => Text(sluzobnik)).toList(),
                  //     ),
                  //   ],
                  // ),
                  // Column(
                  //   children: [
                  //     Text("default"),
                  //     Row(
                  //       children: defaultSluzobniciList.map((sluzobnik) => Text(sluzobnik)).toList(),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
    //   child: Wrap(
    //     alignment: WrapAlignment.center,
    //     runAlignment: WrapAlignment.center,
    //     children: sluzobniciChipWidgetsList,
    //   ),
    // );
  }

  SizedBox generated_text(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: CustomScrollView(
        controller: _randomScrollController,
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
            onChanged: selectedSluzobniciList.isEmpty
                ? null
                : (double newValue) async {
                    kolkomesiacovgenerovat = newValue.toInt();
                    vyslednyRozvrh = await generateScheduleFromNearestSunday(
                        sluzba: sluzba,
                        sluzobnici: selectedSluzobniciList,
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

  // Stack sluzobnici_textfield() {
  //   return Stack(
  //     alignment: Alignment.bottomRight,
  //     children: [
  //       ConstrainedBox(
  //         constraints: const BoxConstraints(maxWidth: 300),
  //         child: TextFormField(
  //           controller: _sluzobniciTcontroller,
  //           onChanged: (value) async {
  //             if (value.isEmpty) {
  //               vyslednyRozvrh = ["Pridaj dakoho, inak bude zle."];

  //               setState(() {});
  //             } else {
  //               selectedSluzobniciList = value.split(" ").map((e) => e.trim()).toList();
  //               vyslednyRozvrh = await generateScheduleFromNearestSunday(
  //                   sluzba: sluzba,
  //                   sluzobnici: selectedSluzobniciList,
  //                   selectedDate: selectedDate,
  //                   kolkomesiacovgenerovat: kolkomesiacovgenerovat);
  //               setState(() {});
  //             }
  //           },
  //           decoration: const InputDecoration(labelText: 'Služobníci', hintText: " "),
  //         ),
  //       ),
  //       if (selectedSluzobniciList != defaultSluzobniciList)
  //         IconButton(
  //           onPressed: () async {
  //             _sluzobniciTcontroller.clear();
  //             selectedSluzobniciList = defaultSluzobniciList;

  //             vyslednyRozvrh = await generateScheduleFromNearestSunday(
  //                 sluzba: sluzba,
  //                 sluzobnici: selectedSluzobniciList,
  //                 selectedDate: selectedDate,
  //                 kolkomesiacovgenerovat: kolkomesiacovgenerovat);
  //             setState(() {});
  //           },
  //           icon: const Icon(Icons.refresh_outlined),
  //         ),
  //     ],
  //   );
  // }

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
                    sluzobnici: selectedSluzobniciList,
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
                  sluzobnici: selectedSluzobniciList,
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
                      sluzobnici: selectedSluzobniciList,
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
                      sluzobnici: selectedSluzobniciList,
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
      helpText: 'Date for schedule',
    );
    if (picked != null) {
      selectedDate = picked;
      if (isSelectedDate != true) {
        isSelectedDate = !isSelectedDate;
      }

      vyslednyRozvrh = await generateScheduleFromNearestSunday(
          sluzba: sluzba,
          sluzobnici: selectedSluzobniciList,
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
      helpText: 'Skip this date',
    );
    if (picked != null) {
      selectedSkipDate = picked;
      if (isSelectedSkip != true) {
        isSelectedSkip = !isSelectedSkip;
      }
      vyslednyRozvrh = await generateScheduleFromNearestSunday(
          sluzba: sluzba,
          sluzobnici: selectedSluzobniciList,
          selectedDate: selectedDate,
          kolkomesiacovgenerovat: kolkomesiacovgenerovat,
          skipDate: picked);
      setState(() {});
    }
  }
}
