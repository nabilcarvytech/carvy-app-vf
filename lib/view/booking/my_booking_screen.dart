import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/check_internet_connection.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/booking/cancelled_trip_screen.dart';
import 'package:carvy/view/booking/liveBooking.dart';
import 'package:carvy/view/booking/up_comming_trip.dart';
import 'package:carvy/view/booking/previous_trip_screen.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import '../../controller/booking_controller.dart';
import '../../controller/booking_record_controller.dart';
import '../../controller/payment_controller.dart';
import '../../utils/common_widget.dart';
import '../../utils/navigation_guard.dart';
import '../../utils/render_debug.dart';
import '../../utils/payment_flow_debug.dart';
import '../../work_space.dart';

class MyBooking extends StatefulWidget {
  final bool? fromPropBooking;
  int? initialTabIndex;

  MyBooking({super.key, this.fromPropBooking, this.initialTabIndex});
  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> with TickerProviderStateMixin {
  late BookingController bookingController;
  final BookingRecordController bookingRecordController = Get.find();

  TabController? tabController;
  late VoidCallback _tabListener;
  int index = 0;
  late final int _initialTab;
  bool _routeReady = false;
  bool _stackReady = false;
  bool _disposed = false;
  bool _isTransitioning = true;
  final Set<int> _mountedTabIndexes = {};

  bool _isEmbeddedInHomeMain() =>
      context.findAncestorWidgetOfExactType<HomeMain>() != null;

  /// Route poussée (profil) ou [Get.offAll] post-paiement — pas l'onglet HomeMain.
  Future<void> _prepareStandaloneEntry() async {
    if (!mounted || _disposed || _isEmbeddedInHomeMain()) return;

    paymentFlowLog(
      'MyBooking — standalone entry',
      'unlock actions + refresh (profile or post-payment)',
    );
    NavigationGuard.endImmediately();
    bookingController.clearBookingData();
    if (Get.isRegistered<BookingRecordController>()) {
      bookingRecordController.restoreListeners();
      final type = _typeForIndex(_initialTab);
      await bookingRecordController.getBookingRecord(
        type: type,
        offset: 0,
        bypassNavigationGuard: true,
      );
    }

    if (mounted && !_disposed) {
      setState(() => _isTransitioning = false);
    }
  }

  void _scheduleTransitionUnlock() {
    if (!mounted || _disposed) return;
    if (!_isEmbeddedInHomeMain()) {
      setState(() => _isTransitioning = false);
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_disposed) {
        setState(() => _isTransitioning = false);
        paymentFlowLog('STEP 10a2 — isTransitioning=false', 'cell actions unlocked');
      }
    });
  }

  String _typeForIndex(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'ongoing';
      case 2:
        return 'previous';
      case 3:
        return 'cancelled';
      default:
        return 'upcoming';
    }
  }

  void _fetchActiveTabRecord({bool allowRetry = true}) {
    if (!mounted || _disposed) return;
    if (NavigationGuard.isNavigating) {
      if (allowRetry) _scheduleFetchAfterNavigation();
      return;
    }
    if (!Get.isRegistered<BookingRecordController>()) return;
    if (bookingRecordController.isClosed) return;

    final type = _typeForIndex(index);
    if (bookingRecordController.shouldSkipInitialFetch(
      type,
      isActiveTab: index == _initialTab,
    )) {
      paymentFlowLog('STEP 10c — fetch skipped', 'type=$type, index=$index');
      if (allowRetry && NavigationGuard.isNavigating) {
        _scheduleFetchAfterNavigation();
      }
      return;
    }

    paymentFlowLog('STEP 10c — fetch active tab', 'type=$type, index=$index');
    bookingRecordController.getBookingRecord(type: type, offset: 0);
  }

  void _scheduleFetchAfterNavigation() {
    paymentFlowLog('STEP 10c-retry — scheduling fetch after navigation');
    NavigationGuard.runWhenIdle(() async {
      if (!mounted || _disposed) return;
      _fetchActiveTabRecord(allowRetry: false);
    });
  }

  void _initTabControllerAfterMount() {
    if (!mounted || _disposed || tabController != null) return;

    tabController = TabController(
      initialIndex: _initialTab,
      vsync: this,
      length: 4,
    );
    index = tabController!.index;
    _mountedTabIndexes.add(index);
    tabController!.addListener(_tabListener);

    setState(() => _routeReady = true);
    renderDebugLog(
      'MyBooking._initTabControllerAfterMount',
      'STEP 10b — TabController ready, index=$index (IndexedStack mode, stack NOT mounted yet)',
    );
    paymentFlowLog('STEP 10b — MyBooking TabController ready',
        'initialTab=$_initialTab, stackReady=false');

    // Frame 2 : monte l'IndexedStack (pas de TabBarView — un seul onglet actif).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _disposed || tabController == null) return;
      paymentFlowLog('STEP 10b2 — mounting IndexedStack',
          'activeIndex=${tabController!.index}, isNavigating=${NavigationGuard.isNavigating}');
      renderDebugLog(
        'MyBooking._mountIndexedStack',
        'STEP 10b2 — IndexedStack mount scheduled, activeIndex=${tabController!.index}',
      );
      setState(() => _stackReady = true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _disposed || tabController == null) return;
        if (NavigationGuard.isNavigating) {
          paymentFlowLog('STEP 10c — fetch deferred, scheduling retry');
          _scheduleFetchAfterNavigation();
          return;
        }
        _fetchActiveTabRecord();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    handleBoackfromPayment = false;
    bookingController = Get.find();
    _initialTab = widget.initialTabIndex ?? 0;
    _isTransitioning = true;
    paymentFlowLog('STEP 10a — MyBooking initState',
        'initialTab=$_initialTab, IndexedStack deferred, stackReady=false');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _disposed) return;
      _prepareStandaloneEntry();
      _scheduleTransitionUnlock();
    });

    _tabListener = () {
      if (!mounted || _disposed || tabController == null) return;

      final newIndex = tabController!.index;
      if (index != newIndex) {
        index = newIndex;
        _mountedTabIndexes.add(newIndex);
        renderDebugLog(
          'MyBooking._tabListener',
          'tab changed → index=$newIndex, mountedTabs=$_mountedTabIndexes',
        );
        paymentFlowLog('STEP 10d — tab index changed', 'index=$newIndex');
        setState(() {});

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _disposed || tabController == null) return;
          if (NavigationGuard.isNavigating) {
            NavigationGuard.runWhenIdle(() async {
              if (!mounted || _disposed || tabController == null) return;
              final type = _typeForIndex(index);
              if (!Get.isRegistered<BookingRecordController>()) return;
              if (bookingRecordController.isClosed) return;
              if (bookingRecordController.isLoading.value) return;
              if (bookingRecordController.hasDataForType(type)) return;
              bookingRecordController.getBookingRecord(type: type, offset: 0);
            });
            return;
          }

          final type = _typeForIndex(index);
          if (!Get.isRegistered<BookingRecordController>()) return;
          if (bookingRecordController.isClosed) return;
          if (bookingRecordController.isLoading.value) return;
          if (bookingRecordController.hasDataForType(type)) return;

          bookingRecordController.getBookingRecord(type: type, offset: 0);
        });
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _disposed) return;
      _initTabControllerAfterMount();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    paymentFlowLog('MyBooking.dispose', 'tabController disposed');
    final controller = tabController;
    if (controller != null) {
      controller.removeListener(_tabListener);
      controller.dispose();
      tabController = null;
    }
    super.dispose();
  }

  bool get _tabControllerUsable =>
      !_disposed && _routeReady && tabController != null;

  void _onBackPressed(BuildContext context) {
    final nav = Navigator.of(context);

    if (nav.canPop()) {
      try {
        generalController.tabController.animateTo(0);
      } catch (_) {}
      generalController.currentIndex.value = 0;
      nav.pop();
      return;
    }

    final inHomeShell =
        context.findAncestorWidgetOfExactType<HomeMain>() != null;
    if (inHomeShell) {
      try {
        if (generalController.tabController.index != 0) {
          generalController.tabController.animateTo(0);
        }
      } catch (_) {}
      generalController.currentIndex.value = 0;
      return;
    }

    Get.offAll(() => HomeMain(initialIndex: 0));
  }

  Widget _buildTabChild(int tabIndex) {
    if (!_mountedTabIndexes.contains(tabIndex)) {
      renderDebugLog(
        'MyBooking._buildTabChild',
        'tab=$tabIndex → placeholder (never visited)',
      );
      return const SizedBox.shrink();
    }

    renderDebugLog(
      'MyBooking._buildTabChild',
      'tab=$tabIndex → building widget',
    );

    switch (tabIndex) {
      case 1:
        return LiveBooking(
          fromPropBooking: widget.fromPropBooking ?? false,
          tabIndex: 1,
          initialTabIndex: _initialTab,
          isTransitioning: _isTransitioning,
        );
      case 2:
        return PreviousTrip(
          fromPropBooking: widget.fromPropBooking ?? false,
          tabIndex: 2,
          initialTabIndex: _initialTab,
          isTransitioning: _isTransitioning,
        );
      case 3:
        return CancelledTrip(
          fromPropBooking: widget.fromPropBooking ?? false,
          tabIndex: 3,
          initialTabIndex: _initialTab,
          isTransitioning: _isTransitioning,
        );
      default:
        return MyUpCommingTrip(
          fromPropBooking: widget.fromPropBooking ?? false,
          tabIndex: 0,
          initialTabIndex: _initialTab,
          isTransitioning: _isTransitioning,
        );
    }
  }

  /// IndexedStack : ne monte que les onglets déjà visités + l'onglet actif.
  Widget _buildIndexedStackBody() {
    final tc = tabController;
    if (tc == null || _disposed) return const SizedBox.shrink();

    if (!_stackReady) {
      renderDebugLog(
        'MyBooking._buildIndexedStackBody',
        'STEP 10b — stackReady=false → SizedBox.shrink()',
      );
      return const SizedBox.shrink();
    }

    final activeIndex = tc.index;
    renderDebugLog(
      'MyBooking._buildIndexedStackBody',
      'STEP 10b2 — IndexedStack building, activeIndex=$activeIndex, '
      'mountedTabs=$_mountedTabIndexes, isTransitioning=$_isTransitioning',
    );
    paymentFlowLog('STEP 10b3 — IndexedStack build',
        'activeIndex=$activeIndex, mountedTabs=$_mountedTabIndexes');

    return IndexedStack(
      index: activeIndex,
      sizing: StackFit.expand,
      children: [
        _buildTabChild(0),
        _buildTabChild(1),
        _buildTabChild(2),
        _buildTabChild(3),
      ],
    );
  }

  Widget _buildShellScaffold(BuildContext context, {required Widget body}) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onBackPressed(context);
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
            backgroundColor: notifires.getbgcolor,
            appBar: AppBar(
              backgroundColor: vehicalThemColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leadingWidth: 56,
              centerTitle: true,
              leading: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _onBackPressed(context),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: whiteColor,
                  size: 20,
                ),
              ),
              title: Text(
                "My Booking".tr,
                style: heading2Grey1(context).copyWith(color: whiteColor),
              ),
            ),
            body: body,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<PaymentController>()) {
      renderDebugLog('MyBooking.build', 'blocked — PaymentController still alive');
      paymentFlowLog('MyBooking.build BLOCKED', 'PaymentController registered');
      return const SizedBox.shrink();
    }
    if (NavigationGuard.isNavigating && !_routeReady) {
      renderDebugLog('MyBooking.build', 'blocked — NavigationGuard during STEP 10b');
      paymentFlowLog('MyBooking.build BLOCKED', 'NavigationGuard + !routeReady');
      return const SizedBox.shrink();
    }

    renderDebugLog(
      'MyBooking.build',
      'routeReady=$_routeReady, stackReady=$_stackReady, disposed=$_disposed, '
      'tabIndex=${tabController?.index}, isTransitioning=$_isTransitioning',
    );
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    if (!_routeReady || !_tabControllerUsable) {
      renderDebugLog('MyBooking.build', 'shell only (IndexedStack NOT mounted yet)');
      paymentFlowLog('MyBooking.build', 'shell only — waiting TabController');
      return _buildShellScaffold(context, body: const SizedBox.shrink());
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onBackPressed(context);
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: ConnectivityWrapper(
            child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: AppBar(
                backgroundColor: vehicalThemColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leadingWidth: 56,
                centerTitle: true,
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _onBackPressed(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: whiteColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  "My Booking".tr,
                  style: heading2Grey1(context).copyWith(color: whiteColor),
                ),
              ),
              body: token.isEmpty
                  ? Center(child: notloginwidget())
                  : SafeArea(
                      child: Column(
                        children: <Widget>[
                          TabBar(
                            indicatorColor: getColorBasedOnActiveModuleid(),
                            controller: tabController,
                            labelColor: getColorBasedOnActiveModuleid(),
                            labelStyle: heading3Grey1(context),
                            unselectedLabelColor: notifires.getGrey3Whitecolor,
                            tabs: [
                              Tab(text: "Upcoming".tr),
                              Tab(text: "Live".tr),
                              Tab(text: "Completed".tr),
                              Tab(text: "Cancelled".tr),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: _buildIndexedStackBody()),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
