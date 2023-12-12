import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_datatype.freezed.dart';
part 'post_datatype.g.dart';

@freezed
class Post with _$Post {
  const factory Post(
      {required String uid,
      required String title,
      required String content,
      required List<({String name, String email})> creators,
      required String postLink,
      required List<String> categories,
      required DateTime publishDate,
      required DateTime modifiedDate,
      required List<String> customCategories}) = _Post;

  factory Post.fromDb(
      String uid,
      String title,
      String content,
      String creators,
      String postLink,
      String categories,
      DateTime publishDate,
      DateTime modifiedDate,
      String customCategories) {
    // Parse creators first:
    var creatorsTemp = creators;

    List<({String name, String email})> creatorsFinal = [];

    if (creatorsTemp.replaceAll("[(", "").replaceAll(")]", "") !=
        creatorsTemp) {
      // There is only one element
      var creatorsStringList =
          creatorsTemp.replaceAll("[(", "").replaceAll(")]", "");

      var nameData = creatorsStringList.split(", ")[1];
      var emailData = creatorsStringList.split(", ")[0];

      creatorsFinal.add(
          (name: nameData.split(": ")[1], email: emailData.split(": ")[1]));
    }

    creatorsTemp = creatorsTemp.replaceAll("[", "").replaceAll("]", "");

    var creatorsStringList = creatorsTemp.split(", ");

    if (creatorsFinal.isEmpty) {
      // If the other code didnt touch the final array, it probably failed.
      for (var element in creatorsStringList) {
        element = element.replaceAll("(", "").replaceAll(")", "");
        var nameData = element.split(", ")[1];
        var emailData = element.split(", ")[0];

        creatorsFinal.add(
            (name: nameData.split(": ")[1], email: emailData.split(": ")[1]));
      }
    }

    // Parse categories:
    var categoriesFinal =
        categories.replaceAll("[", "").replaceAll("]", "").split(", ");

    // Parse custom categories
    var customCategoriesFinal =
        customCategories.replaceAll("[", "").replaceAll("]", "").split(", ");

    return Post(
        uid: uid,
        title: title,
        content: content,
        creators: creatorsFinal,
        postLink: postLink,
        categories: categoriesFinal,
        publishDate: publishDate,
        modifiedDate: modifiedDate,
        customCategories: customCategoriesFinal);
  }

  factory Post.fromJson(Map<String, Object?> json) => _$PostFromJson(json);
}
