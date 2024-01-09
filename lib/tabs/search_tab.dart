import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:wordpress_app/blocs/category_bloc.dart';
import 'package:wordpress_app/models/category.dart';
import 'package:wordpress_app/pages/category_based_articles.dart';
import 'package:wordpress_app/pages/search.dart';
import 'package:wordpress_app/utils/cached_image_with_dark.dart';
import 'package:wordpress_app/utils/loading_card.dart';
import 'package:wordpress_app/utils/next_screen.dart';
import 'package:wordpress_app/utils/vertical_line.dart';
import 'package:easy_localization/easy_localization.dart';

import '../blocs/config_bloc.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final d = context.watch<CategoryBloc>().categoryData;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).primaryColor,
        color: Colors.white,
        onRefresh: () async => await context
            .read<CategoryBloc>()
            .fetchData(context.read<ConfigBloc>().configs!.blockedCategories),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 230,
              toolbarHeight: 0,
              elevation: 0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'search',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ).tr(),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: [
                              Icon(
                                AntDesign.search1,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                'search-for-contents',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600]),
                              ).tr(),
                            ],
                          ),
                        ),
                        onTap: () => nextScreenPopupiOS(context, const SearchPage()),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          verticalLine(context, 20),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'categories',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ).tr(),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 5, bottom: 20, left: 0, right: 0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.3),
                        itemCount: d.isEmpty ? 10 : d.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (d.isEmpty) {
                            return const LoadingCard(
                              height: null,
                            );
                          }

                          return _CategoryCard(
                            d: d[index],
                          );
                        },
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CategoryCard extends StatelessWidget {
  final Category d;
  const _CategoryCard({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String heroTag = 'category${d.id}';
    return InkWell(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Hero(
              tag: heroTag,
              child: CustomCacheImageWithDarkFilterBottom(
                imageUrl: d.categoryThumbnail,
                radius: 5,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name.toString().toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      onTap: () {
        nextScreeniOS(
            context,
            CategoryBasedArticles(
              category: d,
              heroTag: heroTag,
            ));
      },
    );
  }
}
