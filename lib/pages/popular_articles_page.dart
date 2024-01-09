import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/config/config.dart';
import 'package:wordpress_app/cards/sliver_card1.dart';
import 'package:wordpress_app/services/app_service.dart';
import 'package:wordpress_app/utils/empty_image.dart';
import 'package:wordpress_app/utils/loading_card.dart';
import '../blocs/theme_bloc.dart';
import '../config/custom_ad_config.dart';
import '../constants/constant.dart';
import '../models/article.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';

import '../services/wordpress_service.dart';
import '../widgets/custom_ad.dart';
import '../widgets/native_ad_widget.dart';

class PopularArticlesPage extends StatefulWidget {
  const PopularArticlesPage({Key? key}) : super(key: key);

  @override
  State<PopularArticlesPage> createState() => _PopularArticlesPageState();
}

class _PopularArticlesPageState extends State<PopularArticlesPage> {
  final List<Article> _articles = [];
  bool? _hasData;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final String _timeRange = 'last30days';
  final int _postLimit = 30;

  @override
  void initState() {
    _fetchArticles();
    _hasData = true;
    super.initState();
  }

  Future _fetchArticles() async {
    await WordPressService().fetchPopularPosts(_timeRange, _postLimit).then((value) {
      _articles.addAll(value);
      if (_articles.isEmpty) {
        _hasData = false;
      }
      setState(() {});
    });
  }

  Future _onRefresh() async {
    setState(() {
      _hasData = true;
      _articles.clear();
    });
    await _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.read<ConfigBloc>().configs!;
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              backgroundColor: Theme.of(context).primaryColor,
              expandedHeight: MediaQuery.of(context).size.height * 0.15,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Container(
                  color: Theme.of(context).primaryColor,
                  width: double.infinity,
                ),
                title: const Text('popular-contents', style: TextStyle(color: Colors.white, fontFamily: 'Manrope')).tr(),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 15, right: 20),
              ),
            ),
            _hasData == false
                ? SliverFillRemaining(
                    child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.20,
                      ),
                      EmptyPageWithImage(image: Config.noContentImage, title: 'no-contents'.tr()),
                    ],
                  ))
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (_articles.isEmpty && _hasData == true) {
                            return Container(padding: const EdgeInsets.only(bottom: 15), child: const LoadingCard(height: 250));
                          } else if (index < _articles.length) {
                            if ((index + 1) % configs.postIntervalCount == 0) {
                              return Column(
                                children: [
                                  SliverCard1(article: _articles[index], heroTag: 'popularposts$index'),

                                  //native ads
                                  Visibility(
                                      visible: AppService.nativeAdVisible(Constants.adPlacements[1], configs),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: NativeAdWidget(
                                          isDarkMode: context.read<ThemeBloc>().darkTheme ?? false,
                                          isSmallSize: false,
                                        ),
                                      )),

                                  //custom ad
                                  Visibility(
                                    visible: AppService.customAdVisible(Constants.adPlacements[1], configs),
                                    child: Container(
                                        height: CustomAdConfig.defaultBannerHeight,
                                        padding: const EdgeInsets.only(bottom: 15),
                                        child: CustomAdWidget(assetUrl: configs.customAdAssetUrl, targetUrl: configs.customAdDestinationUrl, radius: 5,)),
                                  )
                                ],
                              );
                            } else {
                              return SliverCard1(article: _articles[index], heroTag: 'popularPosts1$index');
                            }
                          }
                          return null;
                        },
                        childCount: _articles.isEmpty ? 6 : _articles.length + 1,
                      ),
                    ),
                  )
          ],
        ),
        onRefresh: () async => _onRefresh(),
      ),
    );
  }
}
