import 'package:dart_rss/dart_rss.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';

extension Converters on AtomItem {
  Post toCustomFormat() {
    return Post(
        uid: id!,
        title: title!,
        content: content!,
        creators: authors.toCustomFormat(),
        postLink: HtmlUnescape().convert(links[2].href!),
        categories: categories
            .where((element) => element.term != null && element.term != "")
            .map((e) => e.term!)
            .toList(),
        publishDate: DateTime.parse(published!),
        modifiedDate: DateTime.parse(updated!),
        customCategories: []);
  }
}

extension AuthorConverter on List<AtomPerson> {
  List<({String name, String email})> toCustomFormat() {
    return map((e) => (name: e.name!, email: e.email!)).toList();
  }
}
