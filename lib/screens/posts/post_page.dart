import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/providers/db_provider.dart';
import 'package:sst_announcer/screens/posts/filter_select_bottom_sheet.dart';
import 'package:sst_announcer/widgets/announcement_card.dart';

class PostsPage extends HookConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var showSearch = useState((animating: false, show: false));
    var scrollController = useScrollController();

    var searchController = useTextEditingController();
    var searchFocusNode = useFocusNode(canRequestFocus: true);

    var allPosts = ref.watch(dbInstanceProvider);

    var categoryFilters = useState<Set<String>>({});

    useEffect(() {
      scrollController.addListener(() {
        if (searchController.text == "") {
          if (showSearch.value.animating && showSearch.value.show) return;
          if (!showSearch.value.animating && !showSearch.value.show) return;

          showSearch.value = (animating: true, show: false);
        }
      });
      return null;
    }, []);

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            title:
                Text(searchController.text == "" ? "Announcements" : "Search"),
            floating: true,
            snap: true,
            stretch: true,
            scrolledUnderElevation: .5,
            actions: [
              ActionChip(
                  backgroundColor: (categoryFilters.value.isEmpty)
                      ? null
                      : Theme.of(context).colorScheme.primaryContainer,
                  label: Row(
                    children: [
                      (categoryFilters.value.isEmpty)
                          ? const Text("Filter")
                          : Text("${categoryFilters.value.length}"),
                      const SizedBox(
                        width: 4,
                      ),
                      const Icon(Icons.filter_list)
                    ],
                  ),
                  onPressed: () async {
                    categoryFilters.value = await getCategoryFilters(
                        context, categoryFilters.value);
                    ref.read(dbInstanceProvider.notifier).filteredPosts(
                        searchController.text, categoryFilters.value);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
            ],
            bottom: (showSearch.value.show || showSearch.value.animating)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(70),
                    child: Animate(
                      onComplete: (controller) {
                        if (showSearch.value.show) {
                          showSearch.value = (animating: false, show: true);
                        } else {
                          showSearch.value = (animating: false, show: false);
                        }
                      },
                      onPlay: (controller) {
                        showSearch.value =
                            (animating: true, show: showSearch.value.show);
                      },
                      effects: [
                        FadeEffect(
                            begin: showSearch.value.show ? 0 : 5,
                            end: showSearch.value.show ? 5 : 0,
                            duration: 500.ms,
                            curve: Curves.linear),
                      ],
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SearchBar(
                            leading: const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.search),
                            ),
                            onChanged: (term) async {
                              ref
                                  .read(dbInstanceProvider.notifier)
                                  .filteredPosts(term, categoryFilters.value);
                            },
                            focusNode: searchFocusNode,
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 10),
                                  () {
                                searchFocusNode.requestFocus();
                              });
                            },
                            hintText: "Search for a Post",
                            controller: searchController,
                          ),
                        ),
                      ),
                    ))
                : null,
            shadowColor: Colors.transparent,
          ),
          if (allPosts.value != null)
            SliverList.builder(
              itemCount: allPosts.value!.length + 3,
              itemBuilder: (context, index) {
                Post? target;

                try {
                  target = allPosts.value![index];
                } catch (e) {
                  target = null;
                }

                if (target == null &&
                    (categoryFilters.value.isNotEmpty ||
                        searchController.text != "")) {
                  return Container();
                }

                if (index == allPosts.value!.length + 3 - 1) {
                  return AnnouncementCard(
                    post: target,
                    built: () {
                      ref.read(dbInstanceProvider.notifier).fetchMorePosts();
                    },
                  );
                }

                return AnnouncementCard(post: target);
              },
            )
        ],
      ),
      floatingActionButton: (!showSearch.value.show)
          ? FloatingActionButton(
              onPressed: () async {
                showSearch.value = (show: true, animating: true);
                await scrollController.animateTo(0,
                    duration: 300.ms, curve: Curves.linear);
                await Future.delayed(const Duration(milliseconds: 10), () {
                  searchFocusNode.requestFocus();
                });
              },
              child: const Icon(Icons.search),
            )
          : null,
    );
  }
}
