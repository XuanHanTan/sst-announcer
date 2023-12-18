import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sst_announcer/logic/database/post_storage/post_datatype.dart';
import 'package:sst_announcer/logic/utils/feed.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard(
      {super.key, required this.post, this.built, this.onTap})
      : assert((post != null && built == null) || post == null);

  final Post? post;
  final VoidCallback? built;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    built?.call();

    return Padding(
      padding: const EdgeInsets.only(right: 5, left: 5, bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Card(
          child: Skeletonizer(
            enabled: post == null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                            post?.creators.first.name.split("").first ?? ""),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                          "${post?.creators.first.name ?? ""} ${(post?.creators.length != 1) ? "and ${(post?.creators.length ?? 1) - 1} other" : ""}"),
                      const Spacer(),
                      Text((post?.publishDate != null)
                          ? "${post!.publishDate.day}/${post!.publishDate.month}/${post!.publishDate.year} at ${post!.publishDate.hour.toString().padLeft(2, "0")}:${post!.publishDate.minute.toString().padLeft(2, "0")}"
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Wrap(
                    children: [
                      ...(post?.categories
                              .map((e) => (e != "")
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(e),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    )
                                  : Container())
                              .toList() ??
                          []),
                      ...(post?.customCategories
                              .map((e) => (e != "")
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(e),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    )
                                  : Container())
                              .toList() ??
                          [])
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
