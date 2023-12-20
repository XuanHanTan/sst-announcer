import 'package:dart_rss/domain/atom_feed.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sst_announcer/blogspot_url.dart';
import 'package:sst_announcer/logic/database/post_storage/database.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/extensions/atom_item_extensions.dart';

part 'db_provider.g.dart';

@Riverpod(keepAlive: true)
class DbInstance extends _$DbInstance {
  AppDatabase db = AppDatabase();

  @override
  FutureOr<List<Post>> build() async {
    return db.getAllPosts();
  }

  Future filteredPosts(String? searchTerm, Set<String>? categories) async {
    var posts = await db.getAllPosts();

    if ((searchTerm == null || searchTerm == "") && categories == null) {
      ref.invalidateSelf();
    }

    if (searchTerm != null && searchTerm != "") {
      posts = posts
          .where((element) =>
              element.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    if (categories != null && categories.isNotEmpty) {
      posts = posts.where((element) {
        // If the post contains at least one category which is in the categories parameter accept it
        if (element.categories.any((element) => categories.contains(element))) {
          return true;
        }
        return false;
      }).toList();
    }

    state = AsyncData(posts);
  }

  Future fetchMorePosts({int? numberToFetch}) async {
    var url = Uri.parse(
        "${BaseUrl.blogUrl}?start-index=${state.value?.length == null || state.value?.isEmpty == true ? 1 : state.value!.length + 1}&max-results=${numberToFetch ?? 10}");
    var response = await http.get(url);

    var atomFeed = AtomFeed.parse(response.body);

    var posts = atomFeed.items.map((e) => e.toCustomFormat());

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

    state = AsyncValue.data([...(state.value ?? []), ...posts]);
  }
}
