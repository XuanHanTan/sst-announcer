import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/providers/db_provider.dart';
import 'package:sst_announcer/screens/posts/filter_select_bottom_sheet.dart';
import 'package:sst_announcer/screens/posts/post_viewer.dart';
import 'package:sst_announcer/widgets/announcement_card.dart';

Future<void> _refresh(WidgetRef ref, TextEditingController searchController,
    ValueNotifier<Set<String>> filters) async {
  await ref.read(dbInstanceProvider.notifier).refreshPosts();
  await ref
      .read(dbInstanceProvider.notifier)
      .filteredPosts(searchController.text, filters.value);
}

class PostsPage extends HookConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchController = useTextEditingController();

    var allPosts = ref.watch(dbInstanceProvider);

    var categoryFilters = useState<Set<String>>({});

    var postRefreshTriggeredViaNoResultFromSearch = useState(false);

    var isSearchingForSomething =
        searchController.text.isNotEmpty || categoryFilters.value.isNotEmpty;

    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: Text(
                      searchController.text == "" ? "Announcements" : "Search"),
                  floating: true,
                  snap: true,
                  pinned: true,
                  stretch: true,
                  scrolledUnderElevation: .5,
                  // actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
                  bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(75),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SearchBar(
                                leading: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.search),
                                ),
                                shadowColor: const MaterialStatePropertyAll(
                                    Colors.transparent),
                                onChanged: (term) async {
                                  ref
                                      .read(dbInstanceProvider.notifier)
                                      .filteredPosts(
                                          term, categoryFilters.value);
                                },
                                hintText: "Search for a Post",
                                controller: searchController,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 56 * 1.5,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () async {
                                  categoryFilters.value =
                                      await getCategoryFilters(
                                          context, categoryFilters.value);
                                  ref
                                      .read(dbInstanceProvider.notifier)
                                      .filteredPosts(searchController.text,
                                          categoryFilters.value);
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (categoryFilters.value.isNotEmpty)
                                        Text("${categoryFilters.value.length}"),
                                      if (categoryFilters.value.isNotEmpty)
                                        const SizedBox(
                                          width: 4,
                                        ),
                                      const Icon(Icons.filter_list),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                  shadowColor: Colors.transparent,
                ),
              ];
            },
            body: //
                (allPosts.value != null &&
                        (allPosts.value?.isNotEmpty ?? false) &&
                        !postRefreshTriggeredViaNoResultFromSearch
                            .value) // Check if the posts that we have are not null for displaying
                    ? SafeArea(
                        top: false,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _refresh(
                                ref, searchController, categoryFilters);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: isSearchingForSomething
                                ? allPosts.value!.length + 1
                                : allPosts.value!.length + 3,
                            itemBuilder: (context, index) {
                              Post? target;

                              try {
                                target = allPosts.value![index];
                              } catch (e) {
                                target = null;
                              }

                              if (!isSearchingForSomething) {
                                if (index == allPosts.value!.length) {
                                  // The index starts from zero rule helps out here
                                  return AnnouncementCard(
                                    post: target,
                                    built: () {
                                      ref
                                          .read(dbInstanceProvider.notifier)
                                          .fetchMorePosts();
                                    },
                                  );
                                } else if (index ==
                                        allPosts.value!.length + 1 ||
                                    index == allPosts.value!.length + 2) {
                                  return AnnouncementCard(post: target);
                                }
                              } else {
                                print(index);
                                if (index == allPosts.value!.length) {
                                  // Means that we are searching for something and we reached the end, ask the user to search through more posts
                                  return loadMorePostsButton(
                                    false,
                                      postRefreshTriggeredViaNoResultFromSearch,
                                      ref,
                                      searchController,
                                      categoryFilters,
                                      allPosts,
                                      context);
                                }
                              }

                              return AnnouncementCard(
                                post: target,
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) =>
                                        PostViewerPage(post: target!),
                                  ));
                                },
                              );
                            },
                          ),
                        ),
                      )
                    : (((allPosts.value?.isEmpty ?? true) &&
                                isSearchingForSomething) ||
                            postRefreshTriggeredViaNoResultFromSearch.value)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Hm...",
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                              Text(
                                  "It looks like we could not find any posts based on your search terms and/or filters",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge),
                              const Text(
                                "Please try using different search terms or filters, or searching through older posts",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              loadMorePostsButton(
                                true,
                                  postRefreshTriggeredViaNoResultFromSearch,
                                  ref,
                                  searchController,
                                  categoryFilters,
                                  allPosts,
                                  context)
                            ],
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          )));
  }

  FilledButton loadMorePostsButton(
      bool wasSearchTriggeredViaNoResultFromSearch,
      ValueNotifier<bool> postRefreshTriggeredViaNoResultFromSearch,
      WidgetRef ref,
      TextEditingController searchController,
      ValueNotifier<Set<String>> categoryFilters,
      AsyncValue<List<Post>> allPosts,
      BuildContext context) {
    return FilledButton(
      onPressed: () async {
        if (wasSearchTriggeredViaNoResultFromSearch) {

        postRefreshTriggeredViaNoResultFromSearch.value = true;
        }
        await ref.read(dbInstanceProvider.notifier).fetchMorePosts(triggerStateChange: false);
        await ref
            .read(dbInstanceProvider.notifier)
            .filteredPosts(searchController.text, categoryFilters.value);

        allPosts.whenData((list) {
          if (list.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nothing was found.")));
          }
          if (wasSearchTriggeredViaNoResultFromSearch) {

          postRefreshTriggeredViaNoResultFromSearch.value = false;
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Search through older posts"),
          const SizedBox(
            width: 8,
          ),
          if (postRefreshTriggeredViaNoResultFromSearch.value)
            SizedBox(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.background,
                ))
        ],
      ),
    );
  }
}
