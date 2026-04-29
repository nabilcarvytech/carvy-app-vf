import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
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

  bool _hasReadEverything = false;

  @override
  void initState() {
    super.initState();
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent) {
      if (!_hasReadEverything) {
        setState(() => _hasReadEverything = true);
        _fadeController.forward(from: 0);
      }
    }
  }

  void _onToggleTerms() {
    if (!_hasReadEverything) return;
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
    super.dispose();
  }

  bool get _isArabic => Get.locale?.languageCode.toLowerCase() == 'ar';

  List<Map<String, String>> _termsContent() {
    return [
      {
        'title': 'terms_general_service_title',
        'body': 'terms_general_service_body',
      },
      {
        'title': 'terms_general_eligibility_title',
        'body': 'terms_general_eligibility_body',
      },
      {
        'title': 'terms_general_deposit_title',
        'body': 'terms_general_deposit_body',
      },
      {
        'title': 'terms_general_inspection_title',
        'body': 'terms_general_inspection_body',
      },
      {
        'title': 'terms_general_fuel_clean_title',
        'body': 'terms_general_fuel_clean_body',
      },
      {
        'title': 'terms_general_insurance_title',
        'body': 'terms_general_insurance_body',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    final primary = getColorBasedOnActiveModuleid();
    final terms = _termsContent();
    final bodyColor = Colors.black87;

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
              Text(
                'Register step terms'.tr,
                style: heading1(context),
              ),
              const SizedBox(height: 8),
              Text(
                'terms_general_subtitle_read_all'.tr,
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
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  for (int i = 0; i < terms.length; i++) ...[
                    Text(
                      '${i + 1}. ${terms[i]['title']!.tr}',
                      textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                      style: heading3(context).copyWith(
                        color: notifires.getwhiteblackcolor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      terms[i]['body']!.tr,
                      textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                      style: regular2(context).copyWith(color: bodyColor),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 24),
                  if (!_hasReadEverything)
                    Text(
                      'terms_general_scroll_to_enable'.tr,
                      style: regular3(context).copyWith(
                        color: notifires.getGrey3Whitecolor,
                      ),
                    ),
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            children: [
              if (!_hasReadEverything)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'terms_general_read_required'.tr,
                    style: regular3(context).copyWith(
                      color: notifires.getGrey3Whitecolor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Obx(() => GestureDetector(
                      onTap: _hasReadEverything ? _onToggleTerms : null,
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
                                  color: _hasReadEverything
                                      ? primary
                                      : notifires.getGrey4Whitecolor,
                                  width: 2,
                                ),
                              ),
                              child: widget
                                      .controller.registerWizardTermsAccepted.value
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
                            child: Text(
                              'terms_general_accept_checkbox'.tr,
                              textAlign:
                                  _isArabic ? TextAlign.right : TextAlign.left,
                              style: regular2(context).copyWith(
                                color: _hasReadEverything
                                    ? notifires.getGrey3Whitecolor
                                    : notifires.getGrey4Whitecolor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              if (!_hasReadEverything) const SizedBox(height: 8),
              if (_hasReadEverything)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox.shrink(),
                ),
              const SizedBox(height: 16),
              Obx(() {
                final accepted =
                    widget.controller.registerWizardTermsAccepted.value;
                final loading =
                    widget.controller.registerWizardSubmitting.value;
                final canContinue = _hasReadEverything && accepted;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: !canContinue
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
                      elevation: canContinue && !loading ? 3 : 0,
                      shadowColor: canContinue && !loading
                          ? primary.withOpacity(0.38)
                          : Colors.transparent,
                      backgroundColor: canContinue
                          ? primary
                          : notifires.getGrey4Whitecolor.withOpacity(0.55),
                      foregroundColor:
                          canContinue ? Colors.white : notifires.getGrey3Whitecolor,
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
                              color: canContinue
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
