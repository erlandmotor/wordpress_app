import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/config/config.dart';
import 'package:wordpress_app/models/article.dart';
import 'package:wordpress_app/cards/card3.dart';
import 'package:wordpress_app/services/wordpress_service.dart';
import 'package:wordpress_app/utils/empty_image.dart';
import 'package:wordpress_app/utils/loading_card.dart';
import 'package:wordpress_app/widgets/loading_indicator_widget.dart';

import '../blocs/theme_bloc.dart';
import '../config/custom_ad_config.dart';
import '../constants/constant.dart';
import '../services/app_service.dart';
import '../widgets/custom_ad.dart';
import '../widgets/native_ad_widget.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({Key? key}) : super(key: key);

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> with AutomaticKeepAliveClientMixin {
  final List<Article> _articles = [];
  ScrollController? _controller;
  int _page = 1;
  bool? _loading;
  bool? _hasData;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final int _postAmount = 10;

  @override
  void initState() {
    _controller = ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller!.addListener(_scrollListener);
    _fetchArticles();
    _hasData = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  Future _fetchArticles() async {
    await WordPressService().fetchVideoPosts(_page, _postAmount).then((value) {
      _articles.addAll(value);
      if (_articles.isEmpty) {
        _hasData = false;
      }
      setState(() {});
    });
  }

  _scrollListener() async {
    var isEnd = _controller!.offset >= _controller!.position.maxScrollExtent && !_controller!.position.outOfRange;
    if (isEnd && _articles.isNotEmpty) {
      setState(() {
        _page += 1;
        _loading = true;
      });
      await _fetchArticles().then((value) {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  Future _onRefresh() async {
    setState(() {
      _loading = null;
      _articles.clear();
      _hasData = true;
      _page = 1;
    });
    await _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.read<ConfigBloc>().configs!;
    super.build(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('video-contents').tr(),
        actions: [
          IconButton(
            icon: const Icon(
              Feather.rotate_cw,
              size: 22,
            ),
            onPressed: () async => await _onRefresh(),
          )
        ],
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        onRefresh: () async => await _onRefresh(),
        child: SingleChildScrollView(
          controller: _controller,
          child: _hasData == false
              ? Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.80,
                  width: double.infinity,
                  child: EmptyPageWithImage(image: Config.noContentImage, title: 'no-contents'.tr()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListView.separated(
                      itemCount: _articles.isEmpty ? 6 : _articles.length + 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(15),
                      separatorBuilder: (ctx, inx) => const SizedBox(
                        height: 15,
                      ),
                      itemBuilder: (context, index) {
                        if (_articles.isEmpty && _hasData == true) {
                          return const LoadingCard(height: 280);
                        } else if (index < _articles.length) {
                          if ((index + 1) % configs.postIntervalCount == 0) {
                            return Column(
                              children: [
                                Card3(article: _articles[index], heroTag: 'video${_articles[index].id}'),
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
                            return Card3(article: _articles[index], heroTag: 'video1${_articles[index].id}');
                          }
                        }

                        return null;
                      },
                    ),
                    Opacity(opacity: _loading == true ? 1.0 : 0.0, child: const LoadingIndicatorWidget())
                  ],
                ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
