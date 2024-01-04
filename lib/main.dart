import 'package:dart_rss/dart_rss.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sst_announcer/blogspot_url.dart';
import 'package:sst_announcer/logic/extensions/atom_item_extensions.dart';
import 'package:sst_announcer/screens/app_host.dart';
import 'package:workmanager/workmanager.dart';

import 'logic/database/post_storage/database.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var db = AppDatabase();

    var response = await http.get(Uri.parse(BaseUrl.blogUrl));

    var atomFeed = AtomFeed.parse(response.body);

    var posts = atomFeed.items.map((e) => e.toCustomFormat());

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

    await db.close();
    return true;
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: kDebugMode,
  );

  Workmanager().registerPeriodicTask(
    "fetch-posts",
    "fetchPosts",
    // When no frequency is provided the default 15 minutes is set.
    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    frequency: const Duration(hours: 1),
  );

  runApp(const ProviderScope(child: MyApp()));
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
