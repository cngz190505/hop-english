import 'package:flutter/material.dart';

/// Tüm listelerde iOS gibi yaylanarak kaydırma sağlar.
/// Sayfa başına/sonuna gelince geri yaylanır, mavi parlama çıkmaz.
class BouncyScrollBehavior extends MaterialScrollBehavior {
  const BouncyScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
