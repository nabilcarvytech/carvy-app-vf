import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/static_page_screen.dart';
import 'package:carvy/work_space.dart';

/// Étape 3 du wizard : cartes récap CGU, scroll jusqu’en bas, acceptation, Continuer.
class TermsStep extends StatefulWidget {
  const TermsStep({super.key, required this.controller});

  final AuthController controller;

  @override
  State<TermsStep> createState() => _TermsStepState();
}

class _TermsStepState extends State<TermsStep>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _checkPopController;
  late Animation<double> _checkPopScale;

  late final TapGestureRecognizer _tapTerms;
  late final TapGestureRecognizer _tapPrivacy;

  bool _reachedBottom = false;

  @override
  void initState() {
    super.initState();
    _tapTerms = TapGestureRecognizer()..onTap = _openTermsSheet;
    _tapPrivacy = TapGestureRecognizer()..onTap = _openPrivacySheet;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _checkPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _checkPopScale = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(
        parent: _checkPopController,
        curve: Curves.elasticOut,
      ),
    );

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _openTermsSheet() {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      backgroundColor: notifires.getbgcolor,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (ctx) => StaticPage(data: 'Terms and Condition'.tr),
    );
  }

  void _openPrivacySheet() {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      backgroundColor: notifires.getbgcolor,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (ctx) => StaticPage(
        data: 'Terms of Service for Users & Privacy Policy'.tr,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;

    if (pos.maxScrollExtent <= 0) {
      _markReachedBottom();
      return;
    }

    final atBottom = pos.atEdge && pos.pixels != 0;
    if (atBottom) {
      _markReachedBottom();
    }
  }

  void _markReachedBottom() {
    if (_reachedBottom) return;
    setState(() => _reachedBottom = true);
    _fadeController.forward(from: 0);
  }

  void _onToggleTerms() {
    final wasAccepted = widget.controller.registerWizardTermsAccepted.value;
    widget.controller.toggleRegisterWizardTerms();
    if (!wasAccepted && widget.controller.registerWizardTermsAccepted.value) {
      _checkPopController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    _checkPopController.dispose();
    _tapTerms.dispose();
    _tapPrivacy.dispose();
    super.dispose();
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: notifires.getboxcolor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: notifires.getGrey4Whitecolor.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: themeColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: heading3(context)),
                  const SizedBox(height: 6),
                  Text(body, style: regular2(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    final primary = getColorBasedOnActiveModuleid();

    final baseStyle = regular2(context);
    final linkStyle = baseStyle.copyWith(
      color: primary,
      fontWeight: FontWeight.w700,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text('Register step terms'.tr, style: heading1(context)),
              const SizedBox(height: 8),
              Text(
                'Register step terms subtitle'.tr,
                style: regular2(context)
                    .copyWith(color: notifires.getGrey3Whitecolor),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: 12,
            ),
            child: Column(
              children: [
                _featureCard(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'terms_summary_payments_title'.tr,
                  body: 'terms_summary_payments_body'.tr,
                ),
                _featureCard(
                  context,
                  icon: Icons.cancel_outlined,
                  title: 'terms_summary_cancel_title'.tr,
                  body: 'terms_summary_cancel_body'.tr,
                ),
                _featureCard(
                  context,
                  icon: Icons.support_agent_outlined,
                  title: 'terms_summary_support_title'.tr,
                  body: 'terms_summary_support_body'.tr,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            children: [
              if (!_reachedBottom)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Scroll to bottom to continue'.tr,
                    style: regular3(context).copyWith(
                      color: notifires.getGrey3Whitecolor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_reachedBottom)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Obx(() => GestureDetector(
                        onTap: _onToggleTerms,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaleTransition(
                              scale: _checkPopScale,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: widget.controller
                                          .registerWizardTermsAccepted.value
                                      ? primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: primary,
                                    width: 2,
                                  ),
                                ),
                                child: widget.controller
                                        .registerWizardTermsAccepted.value
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: baseStyle.copyWith(
                                    color: notifires.getGrey3Whitecolor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'register_wizard_terms_rich_prefix'
                                          .tr,
                                    ),
                                    TextSpan(
                                      text:
                                          'register_wizard_terms_link_cgu'.tr,
                                      style: linkStyle,
                                      recognizer: _tapTerms,
                                    ),
                                    TextSpan(
                                      text: 'register_wizard_terms_rich_middle'
                                          .tr,
                                    ),
                                    TextSpan(
                                      text: 'register_wizard_terms_link_privacy'
                                          .tr,
                                      style: linkStyle,
                                      recognizer: _tapPrivacy,
                                    ),
                                    TextSpan(
                                      text: 'register_wizard_terms_rich_suffix'
                                          .tr,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              const SizedBox(height: 16),
              Obx(() {
                final accepted =
                    widget.controller.registerWizardTermsAccepted.value;
                final loading =
                    widget.controller.registerWizardSubmitting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: !accepted
                        ? null
                        : () {
                            if (widget
                                .controller.registerWizardSubmitting.value) {
                              return;
                            }
                            widget.controller
                                .registerWizardCompleteToHome(context);
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: accepted && !loading ? 3 : 0,
                      shadowColor: accepted && !loading
                          ? primary.withOpacity(0.38)
                          : Colors.transparent,
                      backgroundColor: accepted
                          ? primary
                          : notifires.getGrey4Whitecolor.withOpacity(0.55),
                      foregroundColor:
                          accepted ? Colors.white : notifires.getGrey3Whitecolor,
                      disabledBackgroundColor:
                          notifires.getGrey4Whitecolor.withOpacity(0.55),
                      disabledForegroundColor: notifires.getGrey3Whitecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Continue'.tr,
                            style: heading2(context).copyWith(
                              color: accepted
                                  ? Colors.white
                                  : notifires.getGrey3Whitecolor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
