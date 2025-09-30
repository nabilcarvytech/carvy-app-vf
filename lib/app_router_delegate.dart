import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/helper/web_router.dart';

class AppRouterDelegate extends GetDelegate {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: currentConfiguration != null
          ? [currentConfiguration!.currentPage!]
          : [GetNavConfig.fromRoute(WebRoutes.initial)!.currentPage!],
    );
  }
}
