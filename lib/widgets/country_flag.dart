import 'package:flutter/material.dart';
import 'package:wordpress_app/utils/cached_image.dart';

class CountryFlag extends StatelessWidget {
  final String countryCode;

  const CountryFlag({
    Key? key,
    required this.countryCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String url = 'https://www.countryflagicons.com/FLAT/48/${countryCode.toUpperCase()}.png';
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomCacheImage(imageUrl: url, radius: 0),
    );
  }
}
