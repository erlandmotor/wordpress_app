import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wordpress_app/config/language_config.dart';
import 'package:wordpress_app/services/app_service.dart';
import 'app.dart';
import 'constants/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox(Constants.bookmarkTag);
  await Hive.openBox(Constants.resentSearchTag);
  await Hive.openBox(Constants.notificationTag);
  LanguageConfig.setLocaleMessagesForTimeAgo();
  AppService.setDisplayToHighRefreshRate();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(EasyLocalization(
    supportedLocales: LanguageConfig.supportedLocales,
    path: 'assets/translations',
    fallbackLocale: LanguageConfig.fallbackLocale,
    startLocale: LanguageConfig.startLocale,
    child: const MyApp(),
  ));
}
