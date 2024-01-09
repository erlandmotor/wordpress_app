import 'package:flutter/material.dart';
import 'package:wordpress_app/services/wordpress_service.dart';
import '../models/article.dart';

class FeaturedBloc extends ChangeNotifier {
  final List<Article> _articles = [];
  List<Article> get articles => _articles;

  bool _hasData = true;
  bool get hasData => _hasData;

  int _dotIndex = 0;
  int get dotIndex => _dotIndex;

  Future fetchData() async {
    _hasData = true;
    _articles.clear();
    notifyListeners();

    await WordPressService().fetchFeaturedPosts().then((value) {
      _articles.addAll(value);
      if (_articles.isEmpty) {
        _hasData = false;
      }
    });
    notifyListeners();
  }

  void saveDotIndex(int newIndex) {
    _dotIndex = newIndex;
    notifyListeners();
  }
}
