import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(settingsBox).listenable(),
        builder: (context, Box settings, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Dark Mode'),
                  trailing: Icon(
                    settings.get('darkMode', defaultValue: false) ? Icons.check_box : Icons.check_box_outline_blank,
                    semanticLabel: settings.get('darkMode', defaultValue: false) ? 'Disable Dark Mode' : 'Enable Dark Mode',
                  ),
                  onTap: () {
                    settings.put('darkMode', !settings.get('darkMode', defaultValue: false));
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            height: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Warning!',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                Text('This will remove any existing tasks',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        child: const Text('I Understand'),
                                        onPressed: () {
                                          resetApp();
                                          Navigator.pop(context);
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: ElevatedButton(
                                          child: const Text('Cancel'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Reset Todos'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
