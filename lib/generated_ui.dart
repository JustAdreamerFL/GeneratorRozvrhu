// generator_ui.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'generator.dart';

class GeneratorRozvrhu2 extends StatefulWidget {
  const GeneratorRozvrhu2({super.key});

  @override
  State<GeneratorRozvrhu2> createState() => _GeneratorRozvrhu2State();
}

class _GeneratorRozvrhu2State extends State<GeneratorRozvrhu2> {
  final ScheduleGenerator _generator = ScheduleGenerator();
  final TextEditingController _nazovSluzbyTcontroller = TextEditingController();
  final TextEditingController _sluzobniciTcontroller = TextEditingController();
  final List<TextEditingController> _controllers = [];
  final ScrollController _randomScrollController = ScrollController();
  final DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generator.Sluzobnici = _generator.DefaultSluzobnici;
    _generator.SelectedDate = _selectedDate;
    _generator.hiddenGenerator(
        kolkomesiacovgenerovat: _generator.Kolkomesiacov, selectedDate: _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedDate != _currentDate)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
              child: FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Icon(Icons.clear),
                    Text('Clear date'),
                  ],
                ),
                onPressed: () async {
                  setState(() {
                    _selectedDate = _currentDate;
                  });
                  _generator.hiddenGenerator(
                      kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                      selectedDate: _selectedDate);
                },
              ),
            )
          else
            const SizedBox(
              width: 0,
            ),
          FloatingActionButton.large(
              foregroundColor: colorScheme.surfaceContainer,
              backgroundColor: colorScheme.onPrimaryContainer,
              child: const Icon(Icons.calendar_month_sharp),
              onPressed: () async {
                selectDate(context);
              }),
        ],
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
              [
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
                              controller: _nazovSluzbyTcontroller,
                              decoration:
                                  const InputDecoration(labelText: 'Názov Služby', hintText: " "),
                              onChanged: (value) {
                                _generator.Sluzba = value.isEmpty ? "" : value;
                                setState(() {
                                  _generator.hiddenGenerator(
                                      kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                                      selectedDate: _selectedDate);
                                });
                              }),
                        ),
                        if (_generator.Sluzba != "Služba WC")
                          IconButton(
                            onPressed: () {
                              _nazovSluzbyTcontroller.clear();
                              _generator.Sluzba = _generator.defaultSluzba;
                              setState(() {
                                _generator.hiddenGenerator(
                                    kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                                    selectedDate: _selectedDate);
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
                            controller: _sluzobniciTcontroller,
                            onChanged: (value) {
                              List<String> sluzobnici =
                                  value.split(" ").map((e) => e.trim()).toList();
                              if (value.isEmpty) {
                                sluzobnici = [];
                              }
                              setState(() {
                                _generator.Sluzobnici = sluzobnici.isEmpty ? [] : sluzobnici;
                                _generator.hiddenGenerator(
                                    kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                                    selectedDate: _selectedDate);
                              });
                            },
                            decoration:
                                const InputDecoration(labelText: 'Služobníci', hintText: " "),
                          ),
                        ),
                        if (_generator.Sluzobnici != _generator.DefaultSluzobnici)
                          IconButton(
                            onPressed: () {
                              _sluzobniciTcontroller.clear();
                              _generator.Sluzobnici = _generator.DefaultSluzobnici;
                              setState(() {
                                _generator.hiddenGenerator(
                                    kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                                    selectedDate: _selectedDate);
                              });
                            },
                            icon: const Icon(Icons.refresh_outlined),
                          ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        children: [
                          // Text('Mesiace'), //TODO: add this text
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
                              _generator.hiddenGenerator(
                                  kolkomesiacovgenerovat: _generator.Kolkomesiacov,
                                  selectedDate: _selectedDate);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
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
                                          children: [
                                            Text(
                                              _controllers[index].text =
                                                  _generator.VyslednyRozvrh[index],
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
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      currentDate: _selectedDate,
      firstDate: _currentDate,
      lastDate: _currentDate.add(const Duration(days: 365 * 10)),
      helpText: 'Date for schedule',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _generator.hiddenGenerator(
          kolkomesiacovgenerovat: _generator.Kolkomesiacov, selectedDate: _selectedDate);
    }
  }
}
