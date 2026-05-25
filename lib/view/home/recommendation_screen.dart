import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../../api/config.dart';
import '../../../customwidget/data_not_found.dart';
import '../../../helper/http_service.dart';
import '../../../utils/common_widget.dart';
import '../../controller/items_detail_controller.dart';
import '../../work_space.dart';
import '../bottombar/home_main.dart';

class RecommendationScreen extends StatefulWidget {
  final String? title;
  final String? agencyName;
  final String? locationId;
  final String? userId;
  final dynamic itemTypeId;
  final bool? comefromprofilepage; // it is for top category
  List? itemList; // it is for top category
  RecommendationScreen(
      {super.key,
      this.title,
      this.agencyName,
      this.locationId,
      this.userId,
      this.comefromprofilepage,
      this.itemList,
      this.itemTypeId});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final SearchControllerHome searchController = Get.find();
  ItemModel? itemModel;
  RefreshController refreshController = RefreshController();
  ItemDetailsController propertyDetailController = Get.find();
  num offset = 0;
  var list = [];
  int? _totalFromBackend;
  bool _hasMoreData = true;
  static const int _defaultLimit = 10;
  @override
  void initState() {
    super.initState();
    if (widget.locationId == "-1") {
    } else {
      fetchData();
      widget.itemList = list;
    }

    // fetchData();
  }

  var isLoading = false;
  fetchData() async {
    dynamic response;
    try {
      isLoading = true;
      setState(() {});

      if (widget.userId != null) {
        response = await httpGet(
          Config.submitVehicle,
          {"vendorId": widget.userId, "offset": "$offset"},
        );
      } else if (widget.title == "Recommended Vehicle") {
        response = await httpPost(Config.featuredItems, {"offset": "$offset"});
      } else if (widget.title == "Vehicles Near You") {
        response = await httpPost(Config.nearbyItems, {
          "offset": "$offset",
          "item_type": "${searchController.globalItemType.value}"
        });
      } else {
        response = await httpPost(
          Config.getItemsByLocation,
          {"location_id": widget.locationId, "offset": "$offset"},
        );
      }

      if (response != null && response['status'] == 200) {
        itemModel = ItemModel.fromJson(response);
        final newList = itemModel?.data?.items ?? [];
        final data = response['data'];
        int totalItems = _totalFromBackend ?? -1;
        int limit = _defaultLimit;

        if (data is Map && data['total'] != null) {
          _totalFromBackend = int.tryParse('${data['total']}');
          totalItems = _totalFromBackend ?? -1;
        }
        if (data is Map && data['limit'] != null) {
          limit = int.tryParse('${data['limit']}') ?? _defaultLimit;
        }

        print(
            '📑 [PAGINATION] Offset actuel: $offset | Items reçus: ${newList.length} | Total attendu: $totalItems');

        // Anti-doublons: on n'ajoute que les véhicules dont l'id n'existe pas déjà.
        final existingIds = list
            .map((e) => (e.id ?? '').toString().trim())
            .where((id) => id.isNotEmpty && id.toLowerCase() != 'null')
            .toSet();
        final uniqueNewItems = newList.where((item) {
          final id = (item.id ?? '').toString().trim();
          if (id.isEmpty || id.toLowerCase() == 'null') {
            return true;
          }
          if (existingIds.contains(id)) {
            print('⚠️ [PAGINATION] Doublon ignoré pour id=$id');
            return false;
          }
          existingIds.add(id);
          return true;
        }).toList();

        list.addAll(uniqueNewItems);
        widget.itemList = list;

        final newOffset = itemModel?.data?.offset;
        final reachedByTotal =
            _totalFromBackend != null && list.length >= _totalFromBackend!;
        final reachedByEmptyPage = newList.isEmpty;
        final reachedByOffset = newOffset == null || newOffset == -1;
        final reachedByShortPage = newList.length < limit;
        _hasMoreData = !(reachedByTotal ||
            reachedByEmptyPage ||
            reachedByOffset ||
            reachedByShortPage);

        if (_hasMoreData) {
          offset = newOffset!;
          refreshController.loadComplete();
        } else {
          offset = -1;
          refreshController.loadNoData();
        }

        isLoading = false;
        setState(() {});
      } else {
        isLoading = false;
        // UX silencieuse : ne jamais afficher d'erreur technique à l'utilisateur.
        _hasMoreData = false;
        offset = -1;
        refreshController.loadComplete();
      }
      refreshController.refreshCompleted();
      setState(() {});
    } catch (e) {
      // UX silencieuse : arrêter le scroll sans message visible.
      _hasMoreData = false;
      offset = -1;
      refreshController.loadComplete();
      setState(() {});
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  onLoading() {
    if (!_hasMoreData) {
      refreshController.loadNoData();
      return;
    }
    setState(() {});
    fetchData();
    setState(() {});
  }

  onRefresh() {
    itemModel = null;
    list = [];
    setState(() {});
    offset = 0;
    _totalFromBackend = null;
    _hasMoreData = true;
    refreshController.resetNoData();
    fetchData();
  }

  stateSetter(fn) => setState(() {});

  Widget _buildAgencyListingsTitle(BuildContext context) {
    final name = (widget.agencyName ?? '').trim();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              name,
              style: heading2Grey1(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'agency_ads'.tr,
          style: heading2Grey1(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return WillPopScope(
      onWillPop: () async {
        if (widget.comefromprofilepage == true) {
          Get.back();
        } else {
          if (webPlateForm) {
            Get.toNamed(
              WebRoutes.homeMain,
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => const HomeMain(
                          initialIndex: 0,
                        )));
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: notifires.getbgcolor,
          centerTitle: true,
          leadingWidth: 85,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
              onTap: () {
                if (widget.comefromprofilepage == true) {
                  Navigator.pop(context);
                } else {
                  if (webPlateForm) {
                    Get.toNamed(
                      WebRoutes.homeMain,
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const HomeMain(
                                  initialIndex: 0,
                                )));
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 8, bottom: 8, right: 20),
                child: PhysicalModel(
                  color: Colors.transparent,
                  shadowColor: notifires.getGrey4Whitecolor,
                  elevation: 5.0, // Adjust the elevation value as needed
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: notifires.getboxcolor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.arrow_back,
                        color: getColorBasedOnActiveModuleid()),
                  ),
                ),
              )),
          title: widget.comefromprofilepage == true &&
                  (widget.agencyName ?? '').trim().isNotEmpty
              ? _buildAgencyListingsTitle(context)
              : Text(
                  (widget.title ?? '').tr,
                  style: heading2Grey1(context),
                ),
        ),
        backgroundColor: notifires.getbgcolor,
        body: Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: SmartRefresher(
            controller: refreshController,
            footer: const ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
              loadingText: '',
              noDataText: '',
              failedText: '',
              canLoadingText: '',
              idleText: '',
            ),
            onRefresh: onRefresh,
            onLoading: () async {
              await onLoading();
              setState(() {
                isLoading =
                    false; // Set isLoading to false after loading is completed
              });
            },
            enablePullUp: _hasMoreData,
            child: isLoading
                ? Center(
                    child: verticleShimmerWidgetBookable(),
                  )
                : connectionLost == true
                    ? Center(
                        child:
                            connectionError(context, "Something went wrong".tr),
                      )
                    : widget.itemList!.isEmpty
                        ? Center(
                            child:
                                buildNoDataWidget(context, "No Data founds".tr),
                          )
                        : itemVerticalView(
                            widget.itemList!, false, false, stateSetter, false),
          ),
        ),
      ),
    );
  }
}
