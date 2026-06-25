import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/navigation_guard.dart';

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

  const BookingTabListBody({
    super.key,
    required this.controller,
    required this.fromPropBooking,
    required this.listType,
    required this.btnText,
    required this.emptyMessage,
    required this.stateSetter,
    required this.onItemCancelled,
  });

  @override
  State<BookingTabListBody> createState() => _BookingTabListBodyState();
}

class _BookingTabListBodyState extends State<BookingTabListBody> {
  Worker? _loadingWorker;
  Worker? _listWorker;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _subscribeAfterMount();
    });
  }

  void _subscribeAfterMount() {
    if (_subscribed || !mounted) return;
    _subscribed = true;
    final c = widget.controller;
    _loadingWorker = ever(c.isLoading, (_) => _safeRebuild());
    _listWorker = ever(c.bookingsList, (_) => _safeRebuild());
    _safeRebuild();
  }

  void _safeRebuild() {
    if (!mounted || !context.mounted) return;
    if (NavigationGuard.isNavigating) return;
    setState(() {});
  }

  @override
  void dispose() {
    _loadingWorker?.dispose();
    _listWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();

    final c = widget.controller;
    final loading = c.isLoading.value;
    final list = c.bookingsList;

    if (loading && list.isEmpty) {
      return myBookingScreenShimmer();
    }
    if (list.isEmpty) {
      return Center(
        child: buildNoDataWidget(context, widget.emptyMessage),
      );
    }

    return myBookingListWidget(
      List<Bookings>.from(list),
      widget.btnText,
      widget.stateSetter,
      widget.fromPropBooking,
      widget.listType,
      widget.onItemCancelled,
    );
  }
}
