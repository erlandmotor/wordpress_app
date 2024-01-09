import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/config/config.dart';
import 'package:wordpress_app/cards/sliver_card1.dart';
import 'package:wordpress_app/models/post_tag.dart';
import 'package:wordpress_app/services/wordpress_service.dart';
import 'package:wordpress_app/utils/empty_image.dart';
import 'package:wordpress_app/utils/loading_card.dart';
import 'package:wordpress_app/widgets/loading_indicator_widget.dart';
import '../blocs/theme_bloc.dart';
import '../config/custom_ad_config.dart';
import '../constants/constant.dart';
import '../models/article.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/app_service.dart';
import '../widgets/custom_ad.dart';
import '../widgets/native_ad_widget.dart';

class TagBasedArticles extends StatefulWidget {
  final PostTag tag;
  const TagBasedArticles({Key? key, required this.tag}) : super(key: key);

  @override
  State<TagBasedArticles> createState() => _TagBasedArticlesState();
}

class _TagBasedArticlesState extends State<TagBasedArticles> {
  final List<Article> _articles = [];
  ScrollController? _controller;
  int page = 1;
  bool? _loading;
  bool? _hasData;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final int _postAmount = 10;

  @override
  void initState() {
    _controller = ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller!.addListener(_scrollListener);
    _hasData = true;
    _fetchData();
    super.initState();
  }

  Future _fetchData() async {
    await WordPressService().fetchPostsByTag(page, widget.tag.id, _postAmount).then((value) {
      _articles.addAll(value);
      _loading = false;
      if (_articles.isEmpty) {
        _hasData = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  _scrollListener() async {
    var isEnd = _controller!.offset >= _controller!.position.maxScrollExtent && !_controller!.position.outOfRange;
    if (isEnd && _articles.isNotEmpty) {
      setState(() {
        page += 1;
        _loading = true;
      });
      await _fetchData().then((value) {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  Future _onRefresh() async {
    setState(() {
      _loading = null;
      _hasData = true;
      _articles.clear();
      page = 1;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.read<ConfigBloc>().configs!;
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0.5,
              flexibleSpace: _flexibleSpaceBar(context),
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
                                  SliverCard1(article: _articles[index], heroTag: 'TagBased$index'),
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

                                  //custom ads
                                  Visibility(
                                    visible: AppService.customAdVisible(Constants.adPlacements[1], configs),
                                    child: Container(
                                        height: CustomAdConfig.defaultBannerHeight,
                                        padding: const EdgeInsets.only(top: 15),
                                        child: CustomAdWidget(assetUrl: configs.customAdAssetUrl, targetUrl: configs.customAdDestinationUrl, radius: 5,)),
                                  )
                                ],
                              );
                            } else {
                              return SliverCard1(article: _articles[index], heroTag: 'Tag1Based$index');
                            }
                          }

                          return Opacity(opacity: _loading == true ? 1.0 : 0.0, child: const LoadingIndicatorWidget());
                        },
                        childCount: _articles.isEmpty ? 6 : _articles.length + 1,
                      ),
                    ),
                  ),
          ],
        ),
        onRefresh: () async => _onRefresh(),
      ),
    );
  }

  FlexibleSpaceBar _flexibleSpaceBar(BuildContext context) {
    return FlexibleSpaceBar(
      centerTitle: true,
      title: Text('#${widget.tag.name}', style: const TextStyle(color: Colors.white, fontFamily: 'Manrope')),
    );
  }
}
