// ignore_for_file: avoid_print

import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;

class Mobile extends StatefulWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  int _currentIndex = 0;
  int _pillButtonBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: NavigationBody(
        children: [
          ScaffoldPage(
            header: const PageHeader(title: Text('Mobile')),
            content: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: PageHeader.horizontalPadding(context),
              ),
              children: [
                Text(
                  'Chips',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                Wrap(spacing: 10.0, runSpacing: 10.0, children: [
                  Chip(
                    image: const CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: const Text('Default'),
                    onPressed: () {
                      showBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return BottomSheet(
                            // header: ListTile(
                            //   title: Text(
                            //     'Title',
                            //     style: FluentTheme.of(context)
                            //         .typography
                            //         .subtitle!
                            //         .copyWith(fontWeight: FontWeight.bold),
                            //   ),
                            //   trailing: Row(
                            //     children: List.generate(
                            //       6,
                            //       (_) => Padding(
                            //         padding: EdgeInsets.only(left: 24.0),
                            //         child: Icon(FluentIcons.circle_shape),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            description:
                                const Text('Description or Details here'),
                            children: [
                              const ListTile(
                                leading: Icon(FluentIcons.mail),
                                title: Text('Label'),
                                subtitle: Text('Label'),
                                trailing: Icon(FluentIcons.chevron_right),
                              ),
                              TappableListTile(
                                leading: const Icon(FluentIcons.mail),
                                title: const Text('Label'),
                                subtitle: const Text('Label'),
                                trailing: const Icon(FluentIcons.chevron_right),
                                onTap: () {
                                  print('tapped tile');
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const Chip(
                    image: CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: Text('Disabled'),
                    // Comment the onPressed function to disable the chip
                    // onPressed: () => print('pressed chip'),
                  ),
                  Chip.selected(
                    image: const CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: const Text('Active and selected'),
                    onPressed: () => print('pressed selected chip'),
                  ),
                  const Chip.selected(
                    image: CircleAvatar(
                      radius: 12.0,
                      child: FlutterLogo(size: 14.0),
                    ),
                    text: Text('Selected'),
                    // Comment the onPressed function to disable the chip
                    // onPressed: () => print('pressed chip'),
                  ),
                ]),
                Text(
                  'Snackbar',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                Wrap(runSpacing: 10.0, spacing: 10.0, children: [
                  Snackbar(
                    content: const Text('Single-line snackbar'),
                    action: TextButton(
                      child: const Text('ACTION'),
                      // style: const ButtonThemeData(margin: EdgeInsets.zero),
                      onPressed: () {
                        showSnackbar(
                          context,
                          const Snackbar(
                              content: Text('New update is available!')),
                        );
                      },
                    ),
                  ),
                  Snackbar(
                    content: const Text(
                      'Multi-line snackbar block. Used when the content is too big',
                    ),
                    extended: true,
                    action: TextButton(
                      child: const Text('ACTION'),
                      onPressed: () {
                        showSnackbar(
                          context,
                          Snackbar(
                            content: const Text('New update is availble!'),
                            action: TextButton(
                              child: const Text('DOWNLOAD'),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]),
                Text(
                  'Other',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                PillButtonBar(
                  selected: _pillButtonBarIndex,
                  onChanged: (i) => setState(() => _pillButtonBarIndex = i),
                  items: const [
                    PillButtonBarItem(text: Text('All')),
                    PillButtonBarItem(text: Text('Mail')),
                    PillButtonBarItem(text: Text('People')),
                    PillButtonBarItem(text: Text('Events')),
                  ],
                ),
              ],
            ),
          ),
          const ScaffoldPage(header: PageHeader(title: Text('Android'))),
          const ScaffoldPage(header: PageHeader(title: Text('iOS'))),
        ],
        index: _currentIndex,
      ),
      bottomBar: BottomNavigation(
        index: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationItem(
            icon: Icon(FluentIcons.split),
            title: Text('Both'),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.phone_android_outlined),
            selectedIcon: Icon(Icons.phone_android),
            title: Text('Android'),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.phone_iphone_outlined),
            selectedIcon: Icon(Icons.phone_iphone),
            title: Text('iOS'),
          ),
        ],
      ),
    );
  }
}
