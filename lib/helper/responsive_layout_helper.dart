import 'package:flutter/material.dart';
import 'package:carvy/utils/theme_style.dart';

/// Breakpoints and grid metrics for vehicle listing cards (phone → tablet).
class VehicleListingLayout {
  VehicleListingLayout._(this.width);

  static const double phoneBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double maxContentWidth = Dimensions.containerWidth;

  final double width;

  static VehicleListingLayout of(BuildContext context) {
    return VehicleListingLayout._(MediaQuery.sizeOf(context).width);
  }

  int get columnCount {
    if (width >= tabletBreakpoint) return 3;
    if (width >= phoneBreakpoint) return 2;
    return 1;
  }

  bool get isTablet => width >= phoneBreakpoint;

  EdgeInsets get pagePadding {
    if (width >= tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
    if (width >= phoneBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  EdgeInsets get gridPadding {
    if (width >= phoneBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    }
    return EdgeInsets.zero;
  }

  EdgeInsets get cardPadding {
    if (width >= phoneBreakpoint) {
      return const EdgeInsets.all(6);
    }
    return const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5);
  }

  double get cardBorderRadius => isTablet ? 16 : 12;

  SliverGridDelegate get gridDelegate {
    if (columnCount == 1) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 280,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      );
    }

    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: columnCount >= 3 ? 320 : 360,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.72,
    );
  }

  /// Home preview sections: show more tiles when multiple columns fit.
  int previewItemCount(int listLength) {
    if (listLength <= 0) return 0;
    final maxPreview = columnCount >= 3 ? 6 : (columnCount >= 2 ? 4 : 4);
    return listLength > maxPreview ? maxPreview : listLength;
  }

  static Widget constrainContent(BuildContext context, Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
