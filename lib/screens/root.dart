import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sst_announcer/screens/posts/post_page.dart';
import 'package:sst_announcer/screens/settings/settings_page.dart';

// App Host is the widget that holds the bottom navigation bar and shows the other screens
class AppHost extends HookWidget {
  const AppHost({super.key});

  @override
  Widget build(BuildContext context) {
    var chosenIndex = useState(0);

    return Scaffold(
      body: switch (chosenIndex.value) {
        0 => const PostsPage(),
        1 => const SettingsPage(),
        _ => throw ArgumentError(
            "There is a number which does not fit in the destinations."),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: chosenIndex.value,
        onDestinationSelected: (index) {
          chosenIndex.value = index;
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.local_post_office), label: "Posts"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
