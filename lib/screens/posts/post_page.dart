import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/providers/db_provider.dart';
import 'package:sst_announcer/screens/posts/filter_select_bottom_sheet.dart';
import 'package:sst_announcer/screens/posts/post_viewer.dart';
import 'package:sst_announcer/widgets/announcement_card.dart';

class PostsPage extends HookConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchController = useTextEditingController();

    var allPosts = ref.watch(dbInstanceProvider);

    var categoryFilters = useState<Set<String>>({});

    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title:
                Text(searchController.text == "" ? "Announcements" : "Search"),
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
                                .filteredPosts(term, categoryFilters.value);
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
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            categoryFilters.value = await getCategoryFilters(
                                context, categoryFilters.value);
                            ref.read(dbInstanceProvider.notifier).filteredPosts(
                                searchController.text, categoryFilters.value);
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
          (allPosts.value != null)
              ? ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: allPosts.value!.length + 4,
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
                    } else if (index == allPosts.value!.length + 1 ||
                        index == allPosts.value!.length + 2) {
                      return AnnouncementCard(post: target);
                    } else if (index == allPosts.value!.length + 3) {
                      return SizedBox(
                        height: MediaQuery.of(context).viewPadding.bottom,
                      );
                    }

                    return AnnouncementCard(
                      post: target,
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => PostViewerPage(post: target!),
                        ));
                      },
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator()),
    ));
  }
}
