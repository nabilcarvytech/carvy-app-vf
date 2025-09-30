import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import '../utils/common_widget.dart';

class InitialValueCheckBox extends StatefulWidget {
  final bool? ismaketypr;
  final List<dynamic> initialValue;
  final List<dynamic> options;
  final String? searchHintText;

  const InitialValueCheckBox({
    super.key,
    this.ismaketypr,
    required this.initialValue,
    required this.options,
    this.searchHintText,
  });

  @override
  State<InitialValueCheckBox> createState() => _InitialValueCheckBoxState();
}

class _InitialValueCheckBoxState extends State<InitialValueCheckBox> {
  SearchControllerHome filterController = Get.find();
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    int itemsToShow = _showMore ? widget.initialValue.length : 5;

    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow,
          itemBuilder: (context, index) {
            if (index >= widget.initialValue.length) {
              return const SizedBox
                  .shrink(); // Return empty SizedBox if index exceeds the list length
            }

            final option = widget.initialValue[index];
            final isSelected = widget.ismaketypr == true
                ? filterController.maketypesValus.contains(option)
                : filterController.selectedtypesvalues.contains(option);
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      side: BorderSide(color: notifires.getgreycolor),
                      activeColor: getColorBasedOnActiveModuleid(),
                      checkColor: whiteColor,
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            widget.ismaketypr == true
                                ? filterController.maketypesValus.add(option)
                                : filterController.selectedtypesvalues
                                    .add(option);
                          } else {
                            widget.ismaketypr == true
                                ? filterController.maketypesValus.remove(option)
                                : filterController.selectedtypesvalues
                                    .remove(option);
                          }
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(-11, 0),
                    child: Text(
                      widget.options[index],
                      style: regular2(context),
                      overflow: TextOverflow
                          .ellipsis, // Handle overflow with ellipsis
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.options.length > 5)
          Transform.translate(
            offset: const Offset(-11, 0),
            child: TextButton(
              child: Row(
                children: [
                  Text(
                    _showMore ? 'Show Less'.tr : 'Show More'.tr,
                    style: TextStyle(
                      color: getColorBasedOnActiveModuleid(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _showMore ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: getColorBasedOnActiveModuleid(),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _showMore = !_showMore; // Toggle the _showMore state
                });
              },
            ),
          ),
      ],
    );
  }
}

class MyCustomCheckBox extends StatefulWidget {
  final List<dynamic> initialValue;
  final List<dynamic> options;
  final String? searchHintText;
  final bool? isOdometer;

  const MyCustomCheckBox({
    super.key,
    required this.initialValue,
    required this.options,
    this.searchHintText,
    this.isOdometer,
  });

  @override
  State<MyCustomCheckBox> createState() => _MyCustomCheckBoxState();
}

class _MyCustomCheckBoxState extends State<MyCustomCheckBox> {
  SearchControllerHome filterController = Get.find();
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    int itemsToShow = _showMore ? widget.initialValue.length : 5;
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow,
          itemBuilder: (context, index) {
            if (index >= widget.initialValue.length) {
              return const SizedBox.shrink();
            }
            final option = widget.initialValue[index];
            final isSelected = widget.isOdometer == true
                ? filterController.odometerValues.contains(option)
                : filterController.featuresvalues.contains(option);
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      side: BorderSide(color: notifires.getgreycolor),
                      activeColor: getColorBasedOnActiveModuleid(),
                      checkColor: whiteColor,
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (widget.isOdometer == false) {
                              filterController.featuresvalues.add(option);
                            } else {
                              filterController.odometerValues.add(option);
                            }
                          } else {
                            if (widget.isOdometer == false) {
                              filterController.featuresvalues.remove(option);
                            } else {
                              filterController.odometerValues.remove(option);
                            }
                          }
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(-11, 0),
                    child: Text(
                      widget.options[index],
                      style: regular2(context).copyWith(
                          // fontWeight: FontWeight.w500,
                          ),
                      overflow: TextOverflow
                          .ellipsis, // Handle overflow with ellipsis
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.options.length > 5)
          Transform.translate(
            offset: const Offset(-11, 0),
            child: TextButton(
              child: Row(
                children: [
                  Text(
                    _showMore ? 'Show Less'.tr : 'Show More'.tr,
                    style: TextStyle(
                      color: getColorBasedOnActiveModuleid(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _showMore ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: getColorBasedOnActiveModuleid(),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _showMore = !_showMore; // Toggle the _showMore state
                });
              },
            ),
          ),
      ],
    );
  }
}

class MyCustomCheckBoxForFit extends StatefulWidget {
  final List<dynamic> id;
  final List<dynamic> name;
  final List<dynamic> image;
  final String? listtype;
  final String? searchHintText;

  const MyCustomCheckBoxForFit({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    this.listtype,
    this.searchHintText,
  });

  @override
  State<MyCustomCheckBoxForFit> createState() => _MyCustomCheckBoxForFitState();
}

class _MyCustomCheckBoxForFitState extends State<MyCustomCheckBoxForFit> {
  SearchControllerHome filterController = Get.find();
  final bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    int itemsToShow = _showMore
        ? widget.id.length
        : widget.listtype == "size"
            ? widget.id.length
            : widget.id.length;

    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        widget.listtype == "fit"
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 90,
                  mainAxisSpacing: 10,
                ),
                itemCount: itemsToShow,
                itemBuilder: (context, index) {
                  if (index >= widget.name.length) {
                    return const SizedBox
                        .shrink(); // Return empty SizedBox if index exceeds the list length
                  }
                  final option = widget.id[index];
                  final isSelected = filterController.fitvalue.contains(option);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          filterController.fitvalue.remove(option);
                        } else {
                          filterController.fitvalue.add(option);
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 15, right: 5, top: 5, bottom: 5),
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? getColorBasedOnActiveModuleid()
                                  : whiteColor,
                              border: Border.all(
                                  color: isSelected
                                      ? getColorBasedOnActiveModuleid()
                                      : notifires.getGrey3Whitecolor)),
                          width: double.maxFinite,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.name[index],
                                  style: regular2(context).copyWith(
                                    color: isSelected ? whiteColor : grey2,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 30,
                                  child: myNetworkImageFillBox(
                                      '${widget.image[index]}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : widget.listtype == "rentingforrent"
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsToShow,
                    itemBuilder: (context, index) {
                      if (index >= widget.id.length) {
                        return const SizedBox
                            .shrink(); // Return empty SizedBox if index exceeds the list length
                      }

                      final option = widget.id[index];
                      bool isSelected =
                          filterController.featuresvalues.contains(option);

                      return SizedBox(
                        height: 33,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(-12, 0),
                              child: Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                  side:
                                      BorderSide(color: notifires.getgreycolor),
                                  activeColor: getColorBasedOnActiveModuleid(),
                                  checkColor: whiteColor,
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        filterController.featuresvalues
                                            .add(option);
                                      } else {
                                        filterController.featuresvalues
                                            .remove(option);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-16, 0),
                              child: Text(
                                widget.name[index],
                                style: regular2(context).copyWith(
                                    color: notifires.getGrey2Whitecolor),
                                overflow: TextOverflow
                                    .ellipsis, // Handle overflow with ellipsis
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : widget.listtype == "size"
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 50,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: itemsToShow,
                        itemBuilder: (context, index) {
                          if (index >= widget.name.length) {
                            return const SizedBox
                                .shrink(); // Return empty SizedBox if index exceeds the list length
                          }
                          final option = widget.id[index];
                          final isSelected =
                              filterController.sizevalue.contains(option);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  filterController.sizevalue.remove(option);
                                } else {
                                  filterController.sizevalue.add(option);
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  height: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSelected
                                          ? getColorBasedOnActiveModuleid()
                                          : whiteColor,
                                      border: Border.all(
                                          color: isSelected
                                              ? getColorBasedOnActiveModuleid()
                                              : notifires.getGrey3Whitecolor)),
                                  width: double.maxFinite,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.name[index],
                                          style: regular2(context).copyWith(
                                            color:
                                                isSelected ? whiteColor : grey2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : widget.listtype == "color"
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemsToShow,
                            itemBuilder: (context, index) {
                              if (index >= widget.id.length) {
                                return const SizedBox
                                    .shrink(); // Return empty SizedBox if index exceeds the list length
                              }

                              final option = widget.id[index];
                              bool isSelected =
                                  filterController.colorvalue.contains(option);

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.translate(
                                    offset: const Offset(-12, 0),
                                    child: Transform.scale(
                                      scale: 1.4,
                                      child: Checkbox(
                                        side: BorderSide(
                                            color: notifires.getgreycolor),
                                        activeColor:
                                            getColorBasedOnActiveModuleid(),
                                        checkColor: whiteColor,
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              filterController.colorvalue
                                                  .add(option);
                                            } else {
                                              filterController.colorvalue
                                                  .remove(option);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Transform.translate(
                                      offset: const Offset(-16, 0),
                                      child: Text(
                                        widget.name[index],
                                        style: regular2(context).copyWith(),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle overflow with ellipsis
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : widget.listtype == "collection"
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: itemsToShow,
                                itemBuilder: (context, index) {
                                  if (index >= widget.id.length) {
                                    return const SizedBox
                                        .shrink(); // Return empty SizedBox if index exceeds the list length
                                  }

                                  final option = widget.id[index];
                                  bool isSelected = filterController
                                      .collectionvalue
                                      .contains(option);

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Transform.translate(
                                        offset: const Offset(-12, 0),
                                        child: Transform.scale(
                                          scale: 1.4,
                                          child: Checkbox(
                                            side: BorderSide(
                                                color: notifires.getgreycolor),
                                            activeColor:
                                                getColorBasedOnActiveModuleid(),
                                            checkColor: whiteColor,
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  filterController
                                                      .collectionvalue
                                                      .add(option);
                                                } else {
                                                  filterController
                                                      .collectionvalue
                                                      .remove(option);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Transform.translate(
                                          offset: const Offset(-16, 0),
                                          child: Text(
                                            widget.name[index],
                                            style: regular2(context).copyWith(),
                                            overflow: TextOverflow
                                                .ellipsis, // Handle overflow with ellipsis
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : const SizedBox(),
      ],
    );
  }
}

class MyCustomCheckBoxModelYear extends StatefulWidget {
  final List<dynamic> initialValue;
  final List<dynamic> options;

  const MyCustomCheckBoxModelYear({
    super.key,
    required this.initialValue,
    required this.options,
  });

  @override
  State<MyCustomCheckBoxModelYear> createState() =>
      _MyCustomCheckBoxModelYearState();
}

class _MyCustomCheckBoxModelYearState extends State<MyCustomCheckBoxModelYear> {
  SearchControllerHome filterController = Get.find();
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    int itemsToShow = _showMore ? widget.initialValue.length : 5;

    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow,
          itemBuilder: (context, index) {
            if (index >= widget.initialValue.length) {
              return const SizedBox
                  .shrink(); // Return empty SizedBox if index exceeds the list length
            }

            final option = widget.initialValue[index];
            final isSelected =
                filterController.selectedModelYear.contains(option);

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      side: BorderSide(color: notifires.getgreycolor),
                      activeColor: getColorBasedOnActiveModuleid(),
                      checkColor: whiteColor,
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            filterController.selectedModelYear.add(option);
                          } else {
                            filterController.selectedModelYear.remove(option);
                          }
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(-11, 0),
                    child: Text(
                      "${widget.options[index]}",

                      style: regular2(context).copyWith(
                          // fontWeight: FontWeight.w500,
                          ),
                      overflow: TextOverflow
                          .ellipsis, // Handle overflow with ellipsis
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.options.length > 5)
          Transform.translate(
            offset: const Offset(-11, 0),
            child: TextButton(
              child: Row(
                children: [
                  Text(
                    _showMore ? 'Show Less'.tr : 'Show More'.tr,
                    style: TextStyle(
                      color: getColorBasedOnActiveModuleid(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _showMore ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: getColorBasedOnActiveModuleid(),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _showMore = !_showMore; // Toggle the _showMore state
                });
              },
            ),
          ),
      ],
    );
  }
}
