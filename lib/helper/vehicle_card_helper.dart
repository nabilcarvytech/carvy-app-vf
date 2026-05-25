import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/helper/filter_label_helper.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/work_space.dart';

/// Libellés prix / caractéristiques des cartes véhicule (accueil, recherche, favoris).
class VehicleCardHelper {
  VehicleCardHelper._();

  static String translateTransmission(dynamic raw) {
    final value = (raw?.toString() ?? '').trim();
    if (value.isEmpty) return '';
    final lower = value.toLowerCase();
    if (lower.contains('auto') || lower == 'automatique') {
      return 'automatic'.tr;
    }
    if (lower.contains('man') || lower == 'manuelle') {
      return 'manual'.tr;
    }
    return FilterLabelHelper.translateTransmission(value);
  }

  /// Note véhicule : racine JSON puis `item_info` / champs alternatifs API.
  static double resolveItemRating(dynamic item) {
    if (item == null) return 0.0;

    double? parse(dynamic v) {
      if (v == null) return null;
      final n = double.tryParse(v.toString().trim());
      if (n == null || n <= 0) return null;
      return n;
    }

    final fromTop = parse(_readProperty(item, 'itemRating')) ??
        parse(_readProperty(item, 'item_rating')) ??
        parse(_readProperty(item, 'rating'));
    if (fromTop != null) return fromTop;

    final rawInfo = _readProperty(item, 'itemInfo') ?? _readProperty(item, 'item_info');
    if (rawInfo == null) return 0.0;

    try {
      final Map<String, dynamic> map = rawInfo is String
          ? Map<String, dynamic>.from(jsonDecode(rawInfo) as Map)
          : Map<String, dynamic>.from(rawInfo as Map);

      for (final key in [
        'item_rating',
        'rating',
        'average_rating',
        'vehicle_rating',
        'avg_rating',
      ]) {
        final v = parse(map[key]);
        if (v != null) return v;
      }

      final reviewData = map['review_data'];
      if (reviewData is List && reviewData.isNotEmpty) {
        double sum = 0;
        int count = 0;
        for (final r in reviewData) {
          if (r is Map) {
            final rv = parse(r['rating'] ?? r['vehicle_rating']);
            if (rv != null) {
              sum += rv;
              count++;
            }
          }
        }
        if (count > 0) return sum / count;
      }
    } catch (_) {}

    return 0.0;
  }

  static dynamic _readProperty(dynamic item, String name) {
    if (item is Map) return item[name];
    try {
      switch (name) {
        case 'itemRating':
          return (item as dynamic).itemRating;
        case 'item_rating':
          return (item as dynamic).item_rating;
        case 'rating':
          return (item as dynamic).rating;
        case 'itemInfo':
          return (item as dynamic).itemInfo;
        case 'item_info':
          return (item as dynamic).item_info;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static String formatItemRating(dynamic item) {
    return resolveItemRating(item).toStringAsFixed(1);
  }

  static String translateBrandName(dynamic raw) {
    final name = (raw?.toString() ?? '').trim();
    if (name.isEmpty) return '';
    final lower = name.toLowerCase();
    if (lower == 'autre' ||
        lower == 'other' ||
        lower == 'autres' ||
        lower == 'others') {
      return 'brand_other'.tr;
    }
    return name;
  }

  static String _formatPriceValue(String? price) {
    final p = (price ?? '').trim();
    if (p.length > 8) return p.substring(0, 7);
    return p;
  }

  static Widget _bulletDot(TextStyle style) {
    return Text(' • ', style: style);
  }

  /// Caractéristiques (transmission, marque, places) avec séparateurs gérés en RTL/LTR.
  static Widget buildSpecsWrap({
    required ItemInfo? itemInfo,
    required TextStyle chipStyle,
  }) {
    if (itemInfo == null) return const SizedBox.shrink();

    final segments = <Widget>[];

    void addLabel(String label) {
      if (label.trim().isEmpty) return;
      if (segments.isNotEmpty) {
        segments.add(_bulletDot(chipStyle));
      }
      final isNumeric = RegExp(r'\d').hasMatch(label);
      segments.add(
        Text(
          label,
          style: chipStyle,
          textDirection: isNumeric ? TextDirection.ltr : null,
        ),
      );
    }

    addLabel(translateTransmission(itemInfo.transmission));
    addLabel(translateBrandName(itemInfo.makeType));

    final seats = itemInfo.seatCapicity?.toString().trim() ?? '';
    if (seats.isNotEmpty) {
      addLabel('$seats ${'seats_label'.tr}');
    }

    if (segments.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: segments,
      ),
    );
  }

  /// Prix + suffixe « / jour » forcés en LTR pour l'arabe.
  static Widget buildPriceBlock({
    required String? price,
    required bool showPerDay,
    required TextStyle priceStyle,
    TextStyle? perDayStyle,
  }) {
    final priceText = _formatPriceValue(price);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '$currency $priceText',
              style: priceStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showPerDay)
            Text(
              'per_day'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: perDayStyle,
            ),
        ],
      ),
    );
  }

  static Widget buildSpecsAndPriceRow({
    required ItemInfo? itemInfo,
    required String? price,
    required bool showPerDay,
    required TextStyle chipStyle,
    required TextStyle priceStyle,
    TextStyle? perDayStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        buildSpecsWrap(itemInfo: itemInfo, chipStyle: chipStyle),
        const Spacer(),
        buildPriceBlock(
          price: price,
          showPerDay: showPerDay,
          priceStyle: priceStyle,
          perDayStyle: perDayStyle,
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}
