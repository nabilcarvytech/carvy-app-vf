import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/render_debug.dart';

/// Corps de liste réservation — **sans Obx global** sur le ListView.
/// Les mises à jour passent par [setState] après post-frame pour éviter
/// `_dependents.isEmpty` pendant les transitions [TabController].
class BookingTabListBody extends StatefulWidget {
  final BookingRecordController controller;
  final bool fromPropBooking;
  final String listType;
  final String btnText;
  final String emptyMessage;
  final StateSetter stateSetter;
  final void Function(int index) onItemCancelled;
  final bool isTransitioning;

  const BookingTabListBody({
    super.key,
    required this.controller,
    required this.fromPropBooking,
    required this.listType,
    required this.btnText,
    required this.emptyMessage,
    required this.stateSetter,
    required this.onItemCancelled,
    this.isTransitioning = false,
  });

  @override
  State<BookingTabListBody> createState() => _BookingTabListBodyState();
}

/// Scroll iOS / pull-to-refresh : rebond naturel sans reset de position.
const ScrollPhysics kBookingTabScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

class _BookingTabListBodyState extends State<BookingTabListBody> {
  Worker? _loadingWorker;
  Worker? _listWorker;
  Worker? _hideReturnWorker;
  Worker? _navigationWorker;
  bool _subscribed = false;
  final ScrollController _scrollController = ScrollController();
  int _lastListLength = 0;

  @override
  void initState() {
    super.initState();
    _lastListLength = widget.controller.bookingsList.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _subscribeAfterMount();
    });
  }

  void _subscribeAfterMount() {
    if (_subscribed || !mounted) return;
    _subscribed = true;
    final c = widget.controller;
    _loadingWorker = ever(c.isLoading, (loading) {
      renderDebugLog('ever(BookingRecordController.isLoading)', widget.listType);
      // Shimmer initial uniquement — évite un setState à chaque pagination.
      if (c.bookingsList.isEmpty || loading) {
        _safeRebuild();
      }
    });
    _listWorker = ever(c.bookingsList, (list) {
      renderDebugLog('ever(BookingRecordController.bookingsList)', widget.listType);
      final nextLength = list.length;
      if (nextLength != _lastListLength) {
        _lastListLength = nextLength;
        _safeRebuild();
      }
    });
    if (Get.isRegistered<BookingController>()) {
      _hideReturnWorker =
          ever(Get.find<BookingController>().showhideisReturn, (_) {
        renderDebugLog('ever(BookingController.showhideisReturn)', widget.listType);
        _safeRebuild();
      });
    }
    _navigationWorker = ever(NavigationGuard.isNavigatingObs, (_) {
      renderDebugLog('ever(NavigationGuard.isNavigating)', widget.listType);
      _safeRebuild();
    });
    _safeRebuild();
  }

  void _safeRebuild() {
    if (!mounted || !context.mounted) return;
    renderDebugLog(
      'BookingTabListBody._safeRebuild (setState)',
      'listType=${widget.listType}',
    );
    setState(() {});
  }

  @override
  void dispose() {
    _loadingWorker?.dispose();
    _listWorker?.dispose();
    _hideReturnWorker?.dispose();
    _navigationWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();

    final c = widget.controller;
    final loading = c.isLoading.value;
    final list = c.bookingsList;

    renderDebugLog(
      'Lecture Rx directe dans build (pas Obx)',
      'listType=${widget.listType}, isLoading=$loading, count=${list.length}',
    );

    renderDebugLog(
      'BookingTabListBody.build',
      'listType=${widget.listType}, loading=$loading, count=${list.length}',
    );

    if (loading && list.isEmpty) {
      return myBookingScreenShimmer();
    }
    if (list.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            primary: false,
            physics: kBookingTabScrollPhysics,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: buildNoDataWidget(context, widget.emptyMessage),
              ),
            ),
          );
        },
      );
    }

    return myBookingListWidget(
      List<Bookings>.from(list),
      widget.btnText,
      widget.stateSetter,
      widget.fromPropBooking,
      widget.listType,
      widget.onItemCancelled,
      isTransitioning: widget.isTransitioning,
      scrollController: _scrollController,
    );
  }
}
