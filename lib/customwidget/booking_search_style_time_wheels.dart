import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart' show getColorBasedOnActiveModuleid;
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

/// Bandeau d’étapes identique au [SearchWizard] (Emplacement → Date → Heure).
/// [currentStep] : index actif parmi **0..2** (sur l’étape heures de réservation = **2**).
class BookingSearchStyleStepHeader extends StatelessWidget {
  /// Index de l’étape active (0 = lieu, 1 = date, 2 = heure).
  final int currentStep;

  /// Arrondi haut façon bottom-sheet (comme la recherche).
  final bool roundedTop;

  const BookingSearchStyleStepHeader({
    super.key,
    required this.currentStep,
    this.roundedTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'icon': Icons.location_on_rounded, 'label': 'Location'.tr},
      {'icon': Icons.calendar_today_rounded, 'label': 'Date'.tr},
      {'icon': Icons.access_time_rounded, 'label': 'Time'.tr},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: notifires.getbgcolor,
        borderRadius: roundedTop
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: notifires.getgreycolor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted || isActive
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getgreycolor.withOpacity(0.3),
                        ),
                      ),
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive || isCompleted
                                ? getColorBasedOnActiveModuleid()
                                : notifires.getgreycolor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : steps[index]['icon'] as IconData,
                            color: isActive || isCompleted
                                ? Colors.white
                                : notifires.getgreycolor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[index]['label'] as String,
                          style: regular2(context).copyWith(
                            color: isActive
                                ? getColorBasedOnActiveModuleid()
                                : notifires.getgreycolor,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getgreycolor.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Même logique que le popup [BookingController.startTime].
void applyPickupTimeFromWheel(BookingController c, String value) {
  c.isenqablestarttime.value = true;
  c.selectedStartTime.value = value;
  final endSlots = c.getSlotsEndTime();
  final startSlots = c.getSlotsStartTime();
  final startIndex = startSlots.indexOf(value);
  final endIndex = startIndex + 3;
  if (endSlots.isEmpty) {
    c.selectedEndTime.value = '';
  } else if (endIndex < endSlots.length) {
    c.selectedEndTime.value = endSlots[endIndex];
  } else {
    c.selectedEndTime.value = endSlots.last;
  }
  c.isenableendTime.value = true;
}

/// Étape « heure » au même style que la recherche (résumé + roues ListWheel).
class BookingSearchStyleTimeStep extends StatelessWidget {
  final BookingController bookingController;
  final String locationLabel;
  final DateTime? tripStart;
  final DateTime? tripEnd;

  const BookingSearchStyleTimeStep({
    super.key,
    required this.bookingController,
    required this.locationLabel,
    required this.tripStart,
    required this.tripEnd,
  });

  String get _dateRangeLine {
    if (tripStart == null || tripEnd == null) return '';
    return '${DateFormat('MMM d').format(tripStart!)} - ${DateFormat('MMM d').format(tripEnd!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select time'.tr,
            style: heading2Grey1(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: getColorBasedOnActiveModuleid().withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: getColorBasedOnActiveModuleid(), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationLabel.isEmpty ? '—' : locationLabel,
                        style: regular2(context).copyWith(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.date_range_rounded,
                        color: getColorBasedOnActiveModuleid(), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _dateRangeLine.isEmpty ? '—' : _dateRangeLine,
                      style: regular2(context).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'agency_hours_booking_note'.tr,
              textAlign: TextAlign.center,
              style: regular2(context).copyWith(
                fontSize: 12,
                color: notifires.getgreycolor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => _BookingDualTimeWheels(controller: bookingController)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BookingDualTimeWheels extends StatelessWidget {
  final BookingController controller;

  const _BookingDualTimeWheels({required this.controller});

  @override
  Widget build(BuildContext context) {
    final startSlots = controller.getSlotsStartTime();
    final endSlots = controller.getSlotsEndTime();
    final st = controller.selectedStartTime.value;
    final et = controller.selectedEndTime.value;

    var startIndex = startSlots.indexOf(st);
    if (startIndex < 0) startIndex = 0;
    var endIndex = endSlots.indexOf(et);
    if (endIndex < 0) endIndex = 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                'Pick-up time'.tr,
                style: regular2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: notifires.getGrey1Whitecolor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              _TimeWheel(
                slots: startSlots,
                selectedIndex: startIndex,
                onChanged: (t) => applyPickupTimeFromWheel(controller, t),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text(
                'Drop-off time'.tr,
                style: regular2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: notifires.getGrey1Whitecolor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              _TimeWheel(
                slots: endSlots,
                selectedIndex: endIndex,
                onChanged: (t) {
                  controller.isenableendTime.value = true;
                  controller.selectedEndTime.value = t;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeWheel extends StatefulWidget {
  final List<String> slots;
  final int selectedIndex;
  final ValueChanged<String> onChanged;

  const _TimeWheel({
    required this.slots,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<_TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<_TimeWheel> {
  late FixedExtentScrollController _ctrl;
  int _slotsLen = 0;

  @override
  void initState() {
    super.initState();
    final idx = _safeIndex(widget.selectedIndex);
    _ctrl = FixedExtentScrollController(initialItem: idx);
    _slotsLen = widget.slots.length;
  }

  int _safeIndex(int i) {
    if (widget.slots.isEmpty) return 0;
    if (i < 0) return 0;
    if (i >= widget.slots.length) return widget.slots.length - 1;
    return i;
  }

  @override
  void didUpdateWidget(covariant _TimeWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idx = _safeIndex(widget.selectedIndex);
    if (widget.slots.length != _slotsLen) {
      _slotsLen = widget.slots.length;
      _ctrl.dispose();
      _ctrl = FixedExtentScrollController(initialItem: idx);
      setState(() {});
    } else if (_ctrl.hasClients && _ctrl.selectedItem != idx) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_ctrl.hasClients) return;
        _ctrl.jumpToItem(idx);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slots.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('—', style: regular2(context))),
      );
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: notifires.getGrey3Whitecolor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: getColorBasedOnActiveModuleid().withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: 40,
            perspective: 0.004,
            diameterRatio: 1.3,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              if (index >= 0 && index < widget.slots.length) {
                widget.onChanged(widget.slots[index]);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.slots.length,
              builder: (context, index) {
                final isSelected = _ctrl.hasClients
                    ? _ctrl.selectedItem == index
                    : index == _safeIndex(widget.selectedIndex);

                return Center(
                  child: Text(
                    widget.slots[index],
                    style: TextStyle(
                      fontSize: isSelected ? 16 : 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? notifires.getGrey1Whitecolor
                          : notifires.getgreycolor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
