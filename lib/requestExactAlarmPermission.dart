import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

Future<void> requestExactAlarmPermission(BuildContext context) async {
  if (Platform.isAndroid && androidVersion >= 12) {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    );
    await intent.launch();
  }
}

int get androidVersion {
  return int.parse(Platform.operatingSystemVersion.split(' ')[1].split('.')[0]);
}
