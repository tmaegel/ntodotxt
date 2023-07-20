import 'package:flutter/material.dart';
import 'package:todotxt/common_widgets/app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Settings",
        icon: const Icon(Icons.arrow_back),
        action: () => _cancelAction(context),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Option 1"),
            subtitle: Text("Option description"),
            trailing: SettingsSwitch(),
          ),
          ListTile(
            title: Text("Option 2"),
            subtitle: Text("Option description"),
            trailing: SettingsSwitch(),
          ),
          ListTile(
            title: Text("Option 3"),
            subtitle: Text("Option description"),
            trailing: SettingsSwitch(),
          ),
          ListTile(
            title: Text("Option 4"),
            subtitle: Text("Option description"),
            trailing: SettingsSwitch(),
          ),
          ListTile(
            title: Text("Option 5"),
            subtitle: Text("Option description"),
            trailing: SettingsSwitch(),
          ),
          ListTile(
            title: Text("Option 6"),
            subtitle: Text("Option description"),
            trailing: SettingsSwitch(),
          ),
        ],
      ),
    );
  }

  void _cancelAction(BuildContext context) {}
}

class SettingsSwitch extends StatefulWidget {
  const SettingsSwitch({super.key});

  @override
  State<SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsSwitch> {
  bool status = true;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Switch(
      thumbIcon: thumbIcon,
      value: status,
      onChanged: (bool value) {
        setState(() {
          status = value;
        });
      },
    );
  }
}
