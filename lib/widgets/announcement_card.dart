import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/utils/feed.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.post, this.built})
      : assert((post != null && built == null) || post == null);

  final Post? post;
  final VoidCallback? built;

  @override
  Widget build(BuildContext context) {
    built?.call();

    return Card(
      child: Skeletonizer(
        enabled: post == null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child:
                        Text(post?.creators.first.name.split("").first ?? ""),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                      "${post?.creators.first.name ?? ""} ${(post?.creators.length != 1) ? "and ${(post?.creators.length ?? 1) - 1} other" : ""}"),
                  const Spacer(),
                  Text((post?.publishDate != null)
                      ? "${post!.publishDate.day}/${post!.publishDate.month}/${post!.publishDate.year} at ${post!.publishDate.hour}:${post!.publishDate.minute}"
                      : "LOADING"),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  // Title of Post
                  Expanded(
                    flex: 15,
                    child: Text(
                      post?.title ??
                          "LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING ",
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),

                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                parseHtmlString(post?.content ??
                    "LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING LOADING ")!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ),
      ),
    );
  }
}
