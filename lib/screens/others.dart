// ignore_for_file: avoid_print

import 'package:fluent_ui/fluent_ui.dart';

class Others extends StatefulWidget {
  const Others({Key? key}) : super(key: key);

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  final otherController = ScrollController();

  int currentIndex = 0;

  final flyoutController = FlyoutController();

  bool checked = false;

  @override
  void dispose() {
    flyoutController.dispose();
    otherController.dispose();
    super.dispose();
  }

  DateTime date = DateTime.now();

  late List<Tab> tabs;

  @override
  void initState() {
    super.initState();
    tabs = List.generate(3, (index) {
      late Tab tab;
      tab = Tab(
        text: Text('$index'),
        onClosed: () {
          _handleTabClosed(tab);
        },
      );
      return tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('Others')),
      content: ListView(
        padding: EdgeInsets.only(
          bottom: kPageDefaultVerticalPadding,
          left: PageHeader.horizontalPadding(context),
          right: PageHeader.horizontalPadding(context),
        ),
        controller: otherController,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InfoBar(
              title: Text("Randrom info"),
              content: Text("Content of boh"),
              isLong: true,
              severity: InfoBarSeverity.warning,
              action: () {
                // Do nothing
              }()
            ),
          ),
          ...List.generate(InfoBarSeverity.values.length, (index) {
            final severity = InfoBarSeverity.values[index];
            final titles = [
              'Long title',
              'Short title',
            ];
            final descs = [
              'Lorem Ipsum is simply dummy text of the printtry\'s standard dummy text ever galley of type and scrambled it to make a type specimen book',
              'Short desc',
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InfoBar(
                title: Text(titles[index.isEven ? 0 : 1]),
                content: Text(descs[index.isEven ? 0 : 1]),
                isLong: InfoBarSeverity.values.indexOf(severity).isEven,
                severity: severity,
                action: () {
                  if (index == 0) {
                    return Tooltip(
                      message: 'This is a tooltip',
                      child: Button(
                        child: const Text('Hover this button to see a tooltip'),
                        onPressed: () {
                          print('pressed button with tooltip');
                        },
                      ),
                    );
                  } else {
                    if (index == 3) {
                      return Flyout(
                        controller: flyoutController,
                        contentWidth: 450,
                        content: const FlyoutContent(
                          child: Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'),
                        ),
                        child: Button(
                          child: const Text('Open flyout'),
                          onPressed: () {
                            flyoutController.open = true;
                          },
                        ),
                      );
                    }
                  }
                }(),
                onClose: () {
                  print('closed');
                },
              ),
            );
          }),
          Wrap(children: [
            const ListTile(
              title: Text('ListTile Title'),
              subtitle: Text('ListTile Subtitle'),
            ),
            TappableListTile(
              leading: const CircleAvatar(),
              title: const Text('TappableListTile Title'),
              subtitle: const Text('TappableListTile Subtitle'),
              onTap: () {
                print('tapped tappable list tile');
              },
            ),
          ]),
          Row(children: const [
            Padding(
              padding: EdgeInsets.all(6),
              child: ProgressBar(value: 50),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ProgressRing(value: 85),
            ),
            Padding(
              padding: EdgeInsets.all(6),
              child: ProgressBar(),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ProgressRing(),
            ),
          ]),
          // Row(children: [
          //   CalendarView(
          //     onDateChanged: _handleDateChanged,
          //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
          //     lastDate: DateTime.now().add(Duration(days: 365 * 100)),
          //     initialDate: date,
          //     currentDate: date,
          //     onDisplayedMonthChanged: (date) {
          //       setState(() => this.date = date);
          //     },
          //   ),
          //   CalendarView(
          //     onDateChanged: _handleDateChanged,
          //     firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
          //     lastDate: DateTime.now().add(Duration(days: 365 * 100)),
          //     initialDate: date,
          //     currentDate: date,
          //     onDisplayedMonthChanged: (date) {
          //       setState(() => this.date = date);
          //     },
          //     initialCalendarMode: DatePickerMode.year,
          //   ),
          // ]),
          const SizedBox(height: 10),
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(
                  color: FluentTheme.of(context).accentColor, width: 1.0),
            ),
            child: TabView(
              currentIndex: currentIndex,
              onChanged: _handleTabChanged,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Tab item = tabs.removeAt(oldIndex);
                  tabs.insert(newIndex, item);
                  if (currentIndex == newIndex) {
                    currentIndex = oldIndex;
                  } else if (currentIndex == oldIndex) {
                    currentIndex = newIndex;
                  }
                });
              },
              onNewPressed: () {
                setState(() {
                  late Tab tab;
                  tab = Tab(
                    text: Text('${tabs.length}'),
                    onClosed: () {
                      _handleTabClosed(tab);
                    },
                  );
                  tabs.add(tab);
                });
              },
              tabs: tabs,
              bodies: List.generate(
                tabs.length,
                (index) => Container(
                  color: Colors.accentColors[index.clamp(
                    0,
                    Colors.accentColors.length - 1,
                  )],
                  child: Stack(children: [
                    const Positioned.fill(child: FlutterLogo()),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 250.0,
                        height: 200.0,
                        child: Acrylic(
                          child: Center(
                            child: Text(
                              'A C R Y L I C',
                              style:
                                  FluentTheme.of(context).typography.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabChanged(int index) {
    setState(() => currentIndex = index);
  }

  void _handleTabClosed(Tab tab) {
    setState(() {
      tabs.remove(tab);
      if (currentIndex > tabs.length - 1) currentIndex--;
    });
  }

  // void _handleDateChanged(DateTime date) {

  // }

}
