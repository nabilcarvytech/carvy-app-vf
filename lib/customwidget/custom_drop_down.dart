import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';

class CustomDropdown extends StatefulWidget {
  final List<dynamic> options;
  final String hintText;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? heading;
  final bool? identityTyoe;

  const CustomDropdown({
    super.key,
    this.heading,
    required this.options,
    required this.onSelected,
    required this.checkmarkColor,
    this.hintText = 'Nationality/Residency',
    this.identityTyoe = false,
  });

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  String? _selectedItem;

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      constraints:
          const BoxConstraints.expand(width: double.infinity, height: 250),
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.heading != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    widget.heading!,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    return ListTile(
                      title: Text(option),
                      trailing: _selectedItem == option
                          ? Icon(Icons.check, color: widget.checkmarkColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedItem = option;
                        });
                        Navigator.pop(context);
                        widget.onSelected(option);
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.identityTyoe == true
                ? Icon(Icons.perm_identity, color: acentColor)
                : Icon(Icons.home, color: acentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedItem ??
                    (widget.identityTyoe == true
                        ? "IdentityType".tr
                        : widget.hintText),
                style: regular3(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


class LegalFormDropdown extends StatefulWidget {
  final List<String> options;
  final Function(String) onSelected;
  final Color acentColor;
  final String? initialValue;

  const LegalFormDropdown({
    super.key,
    required this.options,
    required this.onSelected,
    required this.acentColor,
    this.initialValue,
  });

  @override
  State<LegalFormDropdown> createState() => _LegalFormDropdownState();
}

class _LegalFormDropdownState extends State<LegalFormDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      constraints:
          const BoxConstraints.expand(width: double.infinity, height: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Legal Form",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.withOpacity(0.3)),
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _selectedValue == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _selectedValue == option
                            ? widget.acentColor
                            : grey1,
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          color: _selectedValue == option
                              ? widget.acentColor
                              : Colors.black87,
                          fontWeight: _selectedValue == option
                              ? FontWeight.w200
                              : FontWeight.w100,
                              fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedValue = option;
                        });
                        Navigator.pop(context);
                        widget.onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: notifires.getboxcolor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.balance, color: widget.acentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedValue ?? "Select Legal Form",
                style: regular3(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
