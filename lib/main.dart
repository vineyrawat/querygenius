import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  log("HIVE INITIALIZED");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'QueryGenius',
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int topIndex = 0;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
          title: Text('QueryGenius'),
          automaticallyImplyLeading: false,
          leading: null),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.add),
            title: const Text('Add Connection'),
            body: const AddConnection(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.plug_connected),
            title: const Text('Connections'),
            body: const ConnectionList(),
          ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: Container(),
          ),
        ],
        footerItems: [],
      ),
    );
  }
}

class ConnectionList extends StatefulWidget {
  const ConnectionList({
    super.key,
  });

  @override
  State<ConnectionList> createState() => _ConnectionListState();
}

class _ConnectionListState extends State<ConnectionList> {
  var connections = [];

  void fetchConnections() async {
    var connections = await Hive.openBox('connections');
    log(connections.length.toString());
  }

  @override
  void initState() {
    fetchConnections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Connections');
  }
}

class AddConnection extends StatefulWidget {
  const AddConnection({super.key});

  @override
  State<AddConnection> createState() => _AddConnectionState();
}

class _AddConnectionState extends State<AddConnection> {
  bool isLoading = false;
  Map data = {};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void handleAddConnection() async {
    setState(() {
      isLoading = true;
    });
    // log(data.values.toString());
    var connections = await Hive.openBox('connections');
    // log(connections.);
    var res = await connections
        .add({...data, 'createdAt': DateTime.now().toIso8601String()});
    log(res.toString());
    // clear data
    data.clear();
    setState(() {
      isLoading = false;
    });

    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: const Text('Connection has been added successfully :)'),
        action: IconButton(
          icon: const Icon(FluentIcons.check_mark),
          onPressed: close,
        ),
        severity: InfoBarSeverity.success,
      );
    });

    // show success toast
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            isLoading ? const Expanded(child: ProgressBar()) : const SizedBox(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Connection",
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(
                height: 20,
              ),
              InfoLabel(
                label: 'Connection Name',
                child: TextBox(
                  autofocus: true,
                  onChanged: (value) {
                    data['name'] = value;
                  },
                  placeholder: 'My New Connection',
                  expands: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InfoLabel(
                label: 'Host',
                child: TextBox(
                  onChanged: (value) {
                    data['host'] = value;
                  },
                  placeholder: 'Hostname',
                  expands: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InfoLabel(
                label: 'Port',
                child: TextBox(
                  onChanged: (value) {
                    data['port'] = value;
                  },
                  placeholder: 'Port number',
                  expands: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InfoLabel(
                label: 'Username',
                child: TextBox(
                  onChanged: (value) {
                    data['username'] = value;
                  },
                  placeholder: 'Username',
                  expands: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InfoLabel(
                label: 'Password',
                child: PasswordBox(
                  onChanged: (value) {
                    data['password'] = value;
                  },
                  placeholder: 'Password',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InfoLabel(
                label: 'Database (Optional)',
                child: TextBox(
                  onChanged: (value) {
                    data['database'] = value;
                  },
                  placeholder: 'Database name',
                  expands: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    onChanged: (value) {
                      data['secure'] = value;
                      setState(() {});
                    },
                    checked: data['secure'] ?? false,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("Secure"),
                  const Spacer(),
                  FilledButton(
                    onPressed: handleAddConnection,
                    child: const Text("Add Connection"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
