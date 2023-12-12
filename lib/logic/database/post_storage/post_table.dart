import 'package:drift/drift.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';

@UseRowClass(Post, constructor: "fromDb")
class Posts extends Table {
  TextColumn get uid => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get creators => text()();
  TextColumn get postLink => text()();
  TextColumn get categories => text()();
  DateTimeColumn get publishDate => dateTime()();
  DateTimeColumn get modifiedDate => dateTime()();
  TextColumn get customCategories => text()();

  @override
  // TODO: implement primaryKey
  Set<Column<Object>>? get primaryKey => {uid};
}
