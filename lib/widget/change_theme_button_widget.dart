import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_app_usage/datahandler/appdata.dart';


class ChangeThemeButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppData>(context);

    return Switch.adaptive(
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        final provider = Provider.of<AppData>(context, listen: false);
        provider.toggleTheme(value);
      },
    );
  }
}