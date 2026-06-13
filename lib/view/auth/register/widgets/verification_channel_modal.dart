import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _whatsappGreen = Color(0xFF25D366);

/// Affiche un bottom sheet pour choisir le canal d'envoi OTP (SMS ou WhatsApp).
Future<void> showVerificationChannelModal(
  void Function(String channel) onChannelSelected, {
  BuildContext? context,
}) async {
  final ctx = context ?? Get.context;
  if (ctx == null) return;

  await showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final primary = getColorBasedOnActiveModuleid();
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'otp_channel_modal_title'.tr,
                style: heading3(sheetContext),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'otp_channel_modal_subtitle'.tr,
                style: regular3(sheetContext).copyWith(
                  color: notifires.getGrey2Whitecolor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _VerificationChannelTile(
                icon: Icon(Icons.sms_outlined, color: primary, size: 28),
                label: 'SMS',
                onTap: () {
                  onChannelSelected('sms');
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 12),
              _VerificationChannelTile(
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _whatsappGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                label: 'WhatsApp',
                onTap: () {
                  onChannelSelected('whatsapp');
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _VerificationChannelTile extends StatelessWidget {
  const _VerificationChannelTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notifires.getBoxColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 44, height: 44, child: Center(child: icon)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label, style: regular2(context)),
              ),
              Icon(
                Icons.chevron_right,
                color: notifires.getGrey2Whitecolor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
