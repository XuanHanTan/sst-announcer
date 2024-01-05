import 'dart:io';

import 'package:dart_rss/dart_rss.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sst_announcer/blogspot_url.dart';
import 'package:sst_announcer/logic/extensions/atom_item_extensions.dart';
import 'package:sst_announcer/screens/app_host.dart';
import 'package:sst_announcer/screens/posts/post_viewer.dart';
import 'package:workmanager/workmanager.dart';

import 'logic/database/post_storage/database.dart';

const initializationSettingsAndroid =
    AndroidInitializationSettings('notif_icon');
const initializationSettingsDarwin = DarwinInitializationSettings();
const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

BuildContext? hostPageContext;

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var db = AppDatabase();

    var response = await http.get(Uri.parse(BaseUrl.blogUrl));

    var atomFeed = AtomFeed.parse(response.body);

    var posts = atomFeed.items.map((e) => e.toCustomFormat());

    final latestPostInDb = await db.getLatestPost();

    try {
      await db.batch((batch) {
        batch.insertAll(
            db.posts,
            posts.map((e) => PostsCompanion(
                  uid: Value(e.uid),
                  title: Value(e.title),
                  content: Value(e.content),
                  creators: Value(e.creators.toString()),
                  postLink: Value(e.postLink),
                  categories: Value(e.categories.toString()),
                  publishDate: Value(e.publishDate),
                  modifiedDate: Value(e.modifiedDate),
                  customCategories: Value(e.customCategories.toString()),
                )),
            mode: InsertMode.insertOrReplace);
      });
    } catch (e, stacktrace) {
      print("$e \n\n $stacktrace");
    }

    if (latestPostInDb != null) {
      final notifPosts = posts.toList().reversed.takeWhile((e) =>
          e.publishDate.millisecondsSinceEpoch >
          latestPostInDb.publishDate.millisecondsSinceEpoch);

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      for (final eachNotifPost in notifPosts) {
        final androidNotificationDetails = AndroidNotificationDetails(
          'new-posts',
          'New posts',
          channelDescription:
              'Notifications when new posts are uploaded on the Students\' Blog',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ticker: 'New post',
          styleInformation: BigTextStyleInformation(eachNotifPost.content,
              htmlFormatBigText: true),
        );
        final notificationDetails =
            NotificationDetails(android: androidNotificationDetails);
        await flutterLocalNotificationsPlugin.show(
          eachNotifPost.publishDate.millisecondsSinceEpoch,
          "New post from ${eachNotifPost.creators.first.name}${eachNotifPost.creators.length > 1 ? " and others" : ""}",
          eachNotifPost.title,
          notificationDetails,
          payload: eachNotifPost.uid,
        );
      }

      await FlutterAppBadger.updateBadgeCount(notifPosts.length);
    }

    await db.close();

    return true;
  });
}

void main() async {
  Widget initialPage = const MyApp();

  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: kDebugMode,
  );

  if (Platform.isAndroid) {
    Workmanager().registerPeriodicTask(
      "fetch-posts",
      "fetchPosts",
      // When no frequency is provided the default 15 minutes is set.
      // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
      frequency: const Duration(hours: 1),
    );
  }

  // initialise the plugin. notif_icon needs to be a added as a drawable resource to the Android head project
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
  }
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  // Open correct post viewer page if opened from notification
  final notifAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notifAppLaunchDetails != null &&
      notifAppLaunchDetails.didNotificationLaunchApp) {
    final payload = notifAppLaunchDetails.notificationResponse!.payload;

    if (payload != null) {
      final db = AppDatabase();
      final post = await db.getPost(payload);

      if (post != null) {
        initialPage = PostViewerPage(post: post);
      }
    }
  }

  runApp(ProviderScope(child: initialPage));
}

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');

    final db = AppDatabase();
    final post = await db.getPost(payload!);

    if (post != null) {
      Navigator.push(
        hostPageContext!,
        CupertinoPageRoute(
          builder: (context) => PostViewerPage(post: post),
        ),
      );
    }

    await FlutterAppBadger.removeBadge(); // TODO: set post as read in db
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
          brightness: Brightness.dark),
      home: const AppHost(),
    );
  }
}
