import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';

class BackendSettingsDialog extends StatelessWidget {
  final Map<String, Backend> items;

  const BackendSettingsDialog({super.key})
      : items = const {
          'Offline': Backend.offline,
          'WebDAV': Backend.webdav,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key("BackendSettingsDialog"),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(key),
            leading: Radio<Backend>(
              key: Key('${items[key]!.name}DialogRadioButton'),
              value: items[key]!,
              groupValue: Backend.values.byName(
                context.read<AuthCubit>().state.backend.name,
              ),
              onChanged: (Backend? value) => Navigator.pop(context, value),
            ),
          );
        },
      ),
    );
  }
}
