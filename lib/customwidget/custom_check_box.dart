import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/model/make_type_model.dart';
import '../helper/filter_label_helper.dart';
import '../utils/common_widget.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BRAND MULTI SELECT - Smart Modal avec recherche pour les marques
// ═══════════════════════════════════════════════════════════════════════════
class BrandMultiSelect extends StatefulWidget {
  final List<Makes> makes;

  const BrandMultiSelect({
    super.key,
    required this.makes,
  });

  @override
  State<BrandMultiSelect> createState() => _BrandMultiSelectState();
}

class _BrandMultiSelectState extends State<BrandMultiSelect> {
  SearchControllerHome filterController = Get.find();
  static const int _maxVisibleItems =
      3; // Marques affichées sur la page principale (les autres dans le modal)

  // Ouvrir le Bottom Sheet avec toutes les marques
  void _openBrandModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BrandModalSheet(
        makes: widget.makes,
        onClose: () {
          setState(() {}); // Rafraîchir pour afficher les nouvelles sélections
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = filterController.maketypesValus.length;
    final visibleMakes = widget.makes.take(_maxVisibleItems).toList();
    final remainingCount = widget.makes.length - _maxVisibleItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // ─────────────────────────────────────────────────────────────
        // CHIPS: Marques sélectionnées avec bouton supprimer
        // ─────────────────────────────────────────────────────────────
        if (selectedCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filterController.maketypesValus.map((makeId) {
                final make = widget.makes.firstWhere(
                  (m) => m.id == makeId,
                  orElse: () => Makes(id: makeId, makeName: 'Unknown'),
                );

                return Container(
                  padding: const EdgeInsets.only(
                      left: 12, right: 4, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: getColorBasedOnActiveModuleid().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: getColorBasedOnActiveModuleid().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (make.imageUrl != null && make.imageUrl!.isNotEmpty)
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              make.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      Text(
                        make.makeName ?? '',
                        style: regular2(context).copyWith(
                          color: getColorBasedOnActiveModuleid(),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          setState(() {
                            filterController.maketypesValus.remove(makeId);
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: getColorBasedOnActiveModuleid()
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: getColorBasedOnActiveModuleid(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        // ─────────────────────────────────────────────────────────────
        // LISTE DES 5 MARQUES POPULAIRES
        // ─────────────────────────────────────────────────────────────
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleMakes.length,
          itemBuilder: (context, index) {
            final make = visibleMakes[index];
            final isSelected =
                filterController.maketypesValus.contains(make.id);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    filterController.maketypesValus.remove(make.id);
                  } else {
                    filterController.maketypesValus.add(make.id);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? getColorBasedOnActiveModuleid().withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Logo ou initiale
                    if (make.imageUrl != null && make.imageUrl!.isNotEmpty)
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            make.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.directions_car_rounded,
                              color: notifires.getgreycolor,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color:
                              getColorBasedOnActiveModuleid().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            (make.makeName ?? 'N')[0].toUpperCase(),
                            style: TextStyle(
                              color: getColorBasedOnActiveModuleid(),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    // Nom de la marque
                    Expanded(
                      child: Text(
                        make.makeName ?? '',
                        style: regular2(context).copyWith(
                          color: isSelected
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getGrey1Whitecolor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Checkbox
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? getColorBasedOnActiveModuleid()
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getgreycolor,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // ─────────────────────────────────────────────────────────────
        // BOUTON "VOIR TOUTES LES MARQUES"
        // ─────────────────────────────────────────────────────────────
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: _openBrandModal,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: getColorBasedOnActiveModuleid().withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: getColorBasedOnActiveModuleid().withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apps_rounded,
                      color: getColorBasedOnActiveModuleid(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${'See all'.tr} ${widget.makes.length} ${'brands'.tr}',
                      style: regular2(context).copyWith(
                        color: getColorBasedOnActiveModuleid(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: getColorBasedOnActiveModuleid(),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET MODAL - Liste complète des marques avec recherche
// ═══════════════════════════════════════════════════════════════════════════
class _BrandModalSheet extends StatefulWidget {
  final List<Makes> makes;
  final VoidCallback onClose;

  const _BrandModalSheet({
    required this.makes,
    required this.onClose,
  });

  @override
  State<_BrandModalSheet> createState() => _BrandModalSheetState();
}

class _BrandModalSheetState extends State<_BrandModalSheet> {
  SearchControllerHome filterController = Get.find();
  final TextEditingController _searchController = TextEditingController();
  List<Makes> _filteredMakes = [];

  @override
  void initState() {
    super.initState();
    _filteredMakes = widget.makes;
    _searchController.addListener(_filterMakes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMakes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMakes = widget.makes;
      } else {
        _filteredMakes = widget.makes
            .where(
                (make) => (make.makeName ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = filterController.maketypesValus.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: notifires.getbgcolor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ─────────────────────────────────────────────────────────────
          // HEADER
          // ─────────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            decoration: BoxDecoration(
              color: notifires.getbgcolor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                // Poignée
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: notifires.getgreycolor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Titre et bouton fermer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select brands'.tr,
                          style: heading2Grey1(context).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedCount > 0)
                          Text(
                            '$selectedCount ${'selected'.tr}',
                            style: regular2(context).copyWith(
                              color: getColorBasedOnActiveModuleid(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        widget.onClose();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: notifires.getGrey1Whitecolor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barre de recherche - Design clair et visible
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notifires.getgreycolor.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: regular2(context).copyWith(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search brand...'.tr,
                      hintStyle: regular2(context).copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: getColorBasedOnActiveModuleid()
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: getColorBasedOnActiveModuleid(),
                            size: 20,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 60,
                        minHeight: 48,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey.shade600,
                                  size: 16,
                                ),
                              ),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─────────────────────────────────────────────────────────────
          // LISTE DES MARQUES (scrollable)
          // ─────────────────────────────────────────────────────────────
          Expanded(
            child: _filteredMakes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: notifires.getgreycolor),
                        const SizedBox(height: 12),
                        Text(
                          'No brands found'.tr,
                          style: regular2(context)
                              .copyWith(color: notifires.getgreycolor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredMakes.length,
                    itemBuilder: (context, index) {
                      final make = _filteredMakes[index];
                      final isSelected =
                          filterController.maketypesValus.contains(make.id);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              filterController.maketypesValus.remove(make.id);
                            } else {
                              filterController.maketypesValus.add(make.id);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getColorBasedOnActiveModuleid()
                                    .withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: getColorBasedOnActiveModuleid()
                                        .withOpacity(0.3))
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Logo ou initiale
                              if (make.imageUrl != null &&
                                  make.imageUrl!.isNotEmpty)
                                Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      make.imageUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.directions_car_rounded,
                                        color: notifires.getgreycolor,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 14),
                                  decoration: BoxDecoration(
                                    color: getColorBasedOnActiveModuleid()
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (make.makeName ?? 'N')[0].toUpperCase(),
                                      style: TextStyle(
                                        color: getColorBasedOnActiveModuleid(),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              // Nom de la marque
                              Expanded(
                                child: Text(
                                  make.makeName ?? '',
                                  style: regular2(context).copyWith(
                                    color: isSelected
                                        ? getColorBasedOnActiveModuleid()
                                        : notifires.getGrey1Whitecolor,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              // Checkbox
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? getColorBasedOnActiveModuleid()
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? getColorBasedOnActiveModuleid()
                                        : notifires.getgreycolor,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 16)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ─────────────────────────────────────────────────────────────
          // BOUTON VALIDER
          // ─────────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: notifires.getbgcolor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Bouton Clear
                if (selectedCount > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          filterController.maketypesValus.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: notifires.getgreycolor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Clear'.tr,
                        style: regular2(context).copyWith(
                          color: notifires.getGrey1Whitecolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (selectedCount > 0) const SizedBox(width: 12),
                // Bouton Valider
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onClose();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getColorBasedOnActiveModuleid(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      selectedCount > 0
                          ? '${'Validate'.tr} ($selectedCount)'
                          : 'Validate'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          const SizedBox(height: 12),
          // GridView avec 3 colonnes pour Features et Odometer avec checkbox
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 éléments par ligne
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            mainAxisExtent:
                70, // Hauteur fixe plus grande pour afficher "km" complet
          ),
          itemCount: widget.initialValue.length,
          itemBuilder: (context, index) {
            final option = widget.initialValue[index];
            final String optionKey = option?.toString() ?? '';
            final isSelected = widget.isOdometer == true
                ? optionKey.isNotEmpty &&
                    filterController.selectedOdometers.contains(optionKey)
                : filterController.featuresvalues.contains(option);

            return InkWell(
              onTap: () {
                setState(() {
                  if (widget.isOdometer == false) {
                    if (isSelected) {
                      filterController.featuresvalues.remove(option);
                    } else {
                      filterController.featuresvalues.add(option);
                    }
                  } else {
                    if (optionKey.isEmpty) return;
                    if (isSelected) {
                      filterController.selectedOdometers.remove(optionKey);
                    } else if (!filterController.selectedOdometers
                        .contains(optionKey)) {
                      filterController.selectedOdometers.add(optionKey);
                    }
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? getColorBasedOnActiveModuleid().withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Checkbox
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (widget.isOdometer == false) {
                                if (!filterController.featuresvalues
                                    .contains(option)) {
                                  filterController.featuresvalues.add(option);
                                }
                              } else {
                                if (!filterController.selectedOdometers
                                    .contains(optionKey)) {
                                  if (optionKey.isEmpty) return;
                                  filterController.selectedOdometers
                                      .add(optionKey);
                                }
                              }
                            } else {
                              if (widget.isOdometer == false) {
                                filterController.featuresvalues.remove(option);
                              } else {
                                if (optionKey.isNotEmpty) {
                                  filterController.selectedOdometers
                                      .remove(optionKey);
                                }
                              }
                            }
                          });
                        },
                        activeColor: getColorBasedOnActiveModuleid(),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: notifires.getgreycolor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Nom de l'option - Texte complet avec "km" visible
                    Expanded(
                      child: Center(
                        child: FilterLabelHelper.ltrText(
                          widget.isOdometer == true
                              ? FilterLabelHelper.translateOdometerLabel(
                                  widget.options[index]?.toString())
                              : FilterLabelHelper.translateVehicleFeature(
                                  widget.options[index]?.toString()),
                          style: regular2(context).copyWith(
                            color: isSelected
                                ? getColorBasedOnActiveModuleid()
                                : notifires.getGrey1Whitecolor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 11,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                                FilterLabelHelper.translateVehicleFeature(
                                    widget.name[index]?.toString()),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          const SizedBox(height: 12),
          // GridView avec 3 colonnes pour les années avec checkbox
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 éléments par ligne
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            mainAxisExtent: 44, // Hauteur fixe des items
          ),
          itemCount: widget.initialValue.length,
          itemBuilder: (context, index) {
            final option = widget.initialValue[index];
            final isSelected =
                filterController.selectedYears.contains(option.toString());

            return InkWell(
              onTap: () {
                setState(() {
                  final key = option.toString();
                  if (isSelected) {
                    filterController.selectedYears.remove(key);
                  } else if (!filterController.selectedYears.contains(key)) {
                    filterController.selectedYears.add(key);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? getColorBasedOnActiveModuleid().withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkbox
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            final key = option.toString();
                            if (value == true) {
                              if (!filterController.selectedYears
                                  .contains(key)) {
                                filterController.selectedYears.add(key);
                              }
                            } else {
                              filterController.selectedYears.remove(key);
                            }
                          });
                        },
                        activeColor: getColorBasedOnActiveModuleid(),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: notifires.getgreycolor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Année
                    FilterLabelHelper.ltrText(
                      '${widget.options[index]}',
                      style: regular2(context).copyWith(
                        color: isSelected
                            ? getColorBasedOnActiveModuleid()
                            : notifires.getGrey1Whitecolor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// NOUVEAU: Widget pour le filtre de type de carburant (3 par ligne)
class MyCustomCheckBoxFuelType extends StatefulWidget {
  final List<dynamic> fuelTypes;

  const MyCustomCheckBoxFuelType({
    super.key,
    required this.fuelTypes,
  });

  @override
  State<MyCustomCheckBoxFuelType> createState() =>
      _MyCustomCheckBoxFuelTypeState();
}

class _MyCustomCheckBoxFuelTypeState extends State<MyCustomCheckBoxFuelType> {
  SearchControllerHome filterController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          const SizedBox(height: 12),
          // GridView avec 3 colonnes pour les types de carburant avec checkbox
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 éléments par ligne
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            mainAxisExtent: 44, // Hauteur fixe des items
          ),
          itemCount: widget.fuelTypes.length,
          itemBuilder: (context, index) {
            final fuelType = widget.fuelTypes[index];
            final isSelected =
                filterController.selectedFuels.contains(fuelType.id.toString());

            return InkWell(
              onTap: () {
                setState(() {
                  final key = fuelType.id.toString();
                  if (isSelected) {
                    filterController.selectedFuels.remove(key);
                  } else if (!filterController.selectedFuels.contains(key)) {
                    filterController.selectedFuels.add(key);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? getColorBasedOnActiveModuleid().withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkbox
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            final key = fuelType.id.toString();
                            if (value == true) {
                              if (!filterController.selectedFuels
                                  .contains(key)) {
                                filterController.selectedFuels.add(key);
                              }
                            } else {
                              filterController.selectedFuels.remove(key);
                            }
                          });
                        },
                        activeColor: getColorBasedOnActiveModuleid(),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: notifires.getgreycolor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Nom du type de carburant
                    Expanded(
                      child: Text(
                        FilterLabelHelper.translateFuelType(fuelType.name),
                        style: regular2(context).copyWith(
                          color: isSelected
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getGrey1Whitecolor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// NOUVEAU: Widget pour le filtre de transmission (3 par ligne)
class MyCustomCheckBoxTransmission extends StatefulWidget {
  final List<dynamic> transmissions;

  const MyCustomCheckBoxTransmission({
    super.key,
    required this.transmissions,
  });

  @override
  State<MyCustomCheckBoxTransmission> createState() =>
      _MyCustomCheckBoxTransmissionState();
}

class _MyCustomCheckBoxTransmissionState
    extends State<MyCustomCheckBoxTransmission> {
  SearchControllerHome filterController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          const SizedBox(height: 12),
          // GridView avec 3 colonnes pour les transmissions avec checkbox
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 éléments par ligne
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            mainAxisExtent: 44, // Hauteur fixe des items
          ),
          itemCount: widget.transmissions.length,
          itemBuilder: (context, index) {
            final transmission = widget.transmissions[index];
            final transmissionName = transmission.option ?? '';
            final displayName =
                FilterLabelHelper.translateTransmission(transmissionName);
            final isSelected = filterController.selectedTransmissions
                .contains(transmissionName);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    filterController.selectedTransmissions
                        .remove(transmissionName);
                  } else if (!filterController.selectedTransmissions
                      .contains(transmissionName)) {
                    filterController.selectedTransmissions
                        .add(transmissionName);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? getColorBasedOnActiveModuleid().withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkbox
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!filterController.selectedTransmissions
                                  .contains(transmissionName)) {
                                filterController.selectedTransmissions
                                    .add(transmissionName);
                              }
                            } else {
                              filterController.selectedTransmissions
                                  .remove(transmissionName);
                            }
                          });
                        },
                        activeColor: getColorBasedOnActiveModuleid(),
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: notifires.getgreycolor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Nom de la transmission
                    Expanded(
                      child: Text(
                        displayName,
                        style: regular2(context).copyWith(
                          color: isSelected
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getGrey1Whitecolor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
