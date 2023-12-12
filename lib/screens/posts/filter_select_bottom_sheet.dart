import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Set<String>> getCategoryFilters(
    BuildContext context, Set<String> currentFilters) async {
  var url = Uri.parse(
      "https://www.blogger.com/feeds/2263345748458699524/posts/default?start-index=1&max-results=1");
  var response = await http.get(url);

  var atomFeed = AtomFeed.parse(response.body);

  var currentCategories = currentFilters.toSet();

  var categories = atomFeed.categories
      .where((e) => e.term != null && e.term != "")
      .map((e) => e.term!)
      .toList();

  // ignore: use_build_context_synchronously
  await showModalBottomSheet(
    enableDrag: false,
    showDragHandle: false,
    context: context,
    builder: (context) => BottomSheet(
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Filters",
              ),
              actions: [
                if (currentCategories.isNotEmpty)
                  IconButton(
                      onPressed: () {
                        setState(() {
                          currentCategories.clear();
                        });
                      },
                      icon: const Icon(Icons.filter_list_off)),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: [
                            ...(categories.map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                      selected: currentCategories.contains(e),
                                      label: Text(e),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            currentCategories.add(e);
                                          } else {
                                            currentCategories.remove(e);
                                          }
                                        });
                                      }),
                                )))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    ),
  );

  return currentCategories;
}
