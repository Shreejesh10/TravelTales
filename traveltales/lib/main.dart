import 'package:traveltales/traveltales.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:traveltales/api/notification/notificationService.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();
  runApp(const TravelTales());
}

