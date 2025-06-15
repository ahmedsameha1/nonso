import 'package:flutter/material.dart';
import 'package:nonso/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialApp createWidgetInASkeleton(Widget widget) {
  return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: widget,
      ));
}

MaterialApp createWidgetInASkeletonWithoutScaffold(Widget widget) {
  return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: widget);
}

Future<AppLocalizations> getLocalizations(WidgetTester t, Locale locale) async {
  late AppLocalizations result;
  await t.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            result = AppLocalizations.of(context)!;
            return Container();
          },
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  return result;
}
