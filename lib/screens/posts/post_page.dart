import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PostsPage extends HookWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("All Posts"),
            floating: true,
            stretch: true,
            scrolledUnderElevation: .5,
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(70),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SearchBar(
                      leading: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.search),
                      ),
                      hintText: "Search for a Post",
                    ),
                  ),
                )),
            shadowColor: Colors.transparent,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: SizedBox(height: 100, child: Card()),
              );
            }, childCount: 100),
          )
        ],
      ),
    );
  }
}
