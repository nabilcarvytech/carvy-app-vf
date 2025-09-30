import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

class LabelNames extends StatefulWidget {
  final String labelname;
  const LabelNames({super.key, required this.labelname});

  @override
  State<LabelNames> createState() => _LabelNamesState();
}

class _LabelNamesState extends State<LabelNames> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.labelname.tr,
      style: heading3(context),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class CustomsButtons extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color backgroundColor;
  final IconData? icon;
  final VoidCallback onPressed;

  const CustomsButtons(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.onPressed,
      this.icon,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints.expand(width: double.infinity, height: 50.0),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
              backgroundColor: backgroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the content in the row
            children: [
              // Display the text first
              Text(
                text,
                style: heading2(context).copyWith(color: textColor ?? bgColor),
                overflow:
                    TextOverflow.ellipsis, // Handle text overflow with ellipsis
                maxLines: 1, // Ensure text is on a single line
              ),
              if (icon != null) const SizedBox(width: 10),
              if (icon != null) Icon(icon, color: bgColor),
            ],
          )),
    );
  }
}
//password fields//

class CustomTextFields extends StatefulWidget {
  final String txt;
  final String? validateMsg;
  final TextEditingController textEditingControllerCommon;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChnage;
  const CustomTextFields(
      {super.key,
      required this.txt,
      required this.textEditingControllerCommon,
      this.validateMsg,
      this.validator,
      this.onChnage});
  @override
  State<CustomTextFields> createState() => _CustomTextFieldsState();
}

class _CustomTextFieldsState extends State<CustomTextFields> {
  final FocusNode _focusNode = FocusNode();
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    return TextFormField(
      onChanged: widget.onChnage,
      validator: widget.validator,
      focusNode: _focusNode,
      autofocus: false,
      enabled: true,
      textCapitalization: TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.textEditingControllerCommon,
      cursorWidth: 1.0,
      cursorColor: notifires.getwhiteblackcolor,
      style: regular2(context),
      obscureText: showPassword,
      decoration: InputDecoration(
        errorStyle: regular(context).copyWith(color: pc1),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
              color: notifires.getBoxColor), // Error color set to green
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
              color: notifires.getBoxColor), // Focused error color set to green
        ),
        hintText: widget.txt.tr,
        fillColor: notifires.getBoxColor,
        filled: true,
        prefixIcon: Icon(Icons.lock_outline,
            color: getColorBasedOnActiveModuleid(), size: 25),
        suffixIcon: InkWell(
          onTap: () {
            if (showPassword) {
              showPassword = false;
            } else {
              showPassword = true;
            }
            setState(() {});
          },
          child: !showPassword
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/showpassowrd.png",
                    height: 8,
                    width: 8,
                    color: notifires.getGrey3Whitecolor,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/HidePassword.png",
                    height: 8,
                    width: 8,
                    color: notifires.getGrey3Whitecolor,
                  ),
                ),
        ),
        hintStyle: regular3(context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
      ),
    );
  }
}

class TextFieldRefs extends StatefulWidget {
  final String txt;
  final Icon? icons;
  final TextInputType inputType;
  final TextEditingController textEditingControllerCommon;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxlines;
  final int? minlines;
  final int? maxlength;
  final String? counterText;
  final TextAlign inputAlignment;
  final TextInputAction? textInputAction;
  final String? Function(String?)? onChange;
  final VoidCallback? onEditingComplete; // Add this line
  final FocusNode? focusNode;
  final bool readOnly;
  final String? suffixtext;

  const TextFieldRefs({
    super.key,
    required this.txt,
    this.icons,
    required this.textEditingControllerCommon,
    required this.inputType,
    this.validator,
    this.textInputAction,
    this.onTap,
    this.focusNode,
    this.maxlines,
    this.onEditingComplete,
    this.inputFormatters,
    this.maxlength,
    this.onChange,
    this.minlines,
    this.counterText,
    required this.inputAlignment,
    this.readOnly = false,
    this.suffixtext,
  });

  @override
  State<TextFieldRefs> createState() => _TextFieldRefState();
}

class _TextFieldRefState extends State<TextFieldRefs> {
  final bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      maxLength: widget.maxlength,
      textInputAction: widget.textInputAction,
      textAlign: widget.inputAlignment,
      maxLines: widget.maxlines,
      minLines: widget.minlines,
      controller: widget.textEditingControllerCommon,
      keyboardType: widget.inputType,
      focusNode: widget.focusNode,
      autofocus: false,
      enabled: true,
      textCapitalization: widget.inputType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      cursorWidth: 1.0,
      cursorColor: notifires.getwhiteblackcolor,
      style: regular2(context),
      onTap: widget.onTap,
      decoration: InputDecoration(
        suffixText: widget.suffixtext,
        filled: true,
        counterText: widget.counterText,
        counterStyle:
            gilroyRegular.copyWith(color: notifires.getGrey2Whitecolor),
        suffixIcon: _isValid
            ? const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 20)
            : null,
        errorStyle: regular(context).copyWith(color: pc1),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
        hintText: widget.txt.tr,
        hintStyle: regular3(context),
        prefixIcon: widget.icons,
        fillColor: notifires.getBoxColor,
        enabled: true,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: notifires.getBoxColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: notifires.getBoxColor)),
      ),
      onChanged: widget.onChange,
    );
  }
}

class TextFieldRefsForDiscount extends StatefulWidget {
  final String txt;
  final Icon? icons;
  final TextInputType inputType;
  final TextEditingController textEditingControllerCommon;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxlines;
  final int? minlines;
  final int? maxlength;
  final String? counterText;
  final TextAlign inputAlignment;
  final TextInputAction? textInputAction;
  final String? Function(String?)? onChange;
  final VoidCallback? onEditingComplete; // Add this line
  final FocusNode? focusNode;
  final bool readOnly;
  final String? suffixtext;

  const TextFieldRefsForDiscount({
    super.key,
    required this.txt,
    this.icons,
    required this.textEditingControllerCommon,
    required this.inputType,
    this.validator,
    this.textInputAction,
    this.onTap,
    this.focusNode,
    this.maxlines,
    this.onEditingComplete,
    this.inputFormatters,
    this.maxlength,
    this.onChange,
    this.minlines,
    this.counterText,
    required this.inputAlignment,
    this.readOnly = false,
    this.suffixtext,
  });

  @override
  State<TextFieldRefsForDiscount> createState() =>
      _TextFieldRefForDiscountState();
}

class _TextFieldRefForDiscountState extends State<TextFieldRefsForDiscount> {
  final bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      maxLength: widget.maxlength,
      textInputAction: widget.textInputAction,
      textAlign: widget.inputAlignment,
      maxLines: widget.maxlines,
      minLines: widget.minlines,
      controller: widget.textEditingControllerCommon,
      keyboardType: widget.inputType,
      focusNode: widget.focusNode,
      autofocus: false,
      enabled: true,
      textCapitalization: widget.inputType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      cursorWidth: 1.0,
      cursorColor: notifires.getwhiteblackcolor,
      style: heading3(context).copyWith(color: getColorBasedOnActiveModuleid()),
      onTap: widget.onTap,
      // Added onTap callback
      decoration: InputDecoration(
        suffixText: widget.suffixtext,
        filled: true,
        counterText: widget.counterText,
        counterStyle:
            gilroyRegular.copyWith(color: notifires.getGrey2Whitecolor),
        suffixIcon: _isValid
            ? const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 20)
            : null,
        errorStyle: regular(context).copyWith(color: pc1),
        // border: InputBorder.none,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifires.getboxcolor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifires.getboxcolor),
        ),
        hintText: widget.txt.tr,
        hintStyle: heading3(context),
        prefixIcon: widget.icons,
        fillColor: notifires.getBoxColor,
        enabled: true,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: notifires.getboxcolor, width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: notifires.getboxcolor, width: 2)),
      ),
      onChanged: widget.onChange,
    );
  }
}

//IntelPhoneFields //

class IntelPhoneFieldRefs extends StatefulWidget {
  final TextEditingController textEditingControllerCommons;
  final String? Function(PhoneNumber?)? validator;
  final String? Function(PhoneNumber?)? onChanged;
  final void Function(Country)? oncountryChanged;
  final String? selectedcountry;
  final String? defultcountry;
  final bool readOnly;
  final bool isenable;
  final Widget? suffixIcon;

  const IntelPhoneFieldRefs({
    super.key,
    required this.textEditingControllerCommons,
    this.validator,
    this.onChanged,
    this.oncountryChanged,
    this.selectedcountry,
    this.defultcountry = "TH",
    this.readOnly = false,
    this.suffixIcon,
    this.isenable = true,
  });

  @override
  State<IntelPhoneFieldRefs> createState() => _IntelPhoneFieldRefState();
}

class _IntelPhoneFieldRefState extends State<IntelPhoneFieldRefs> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    return IntlPhoneField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      flagsButtonPadding: const EdgeInsets.only(left: 10),
      dropdownIconPosition: IconPosition.trailing,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      enabled: widget.isenable,
      readOnly: widget.readOnly,
      dropdownTextStyle: regular2(context),
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: notifires.getBoxColor,
        width: 330,
        listTileDivider: Container(
          height: 1,
          width: 330,
          color: notifires.getGrey4Whitecolor,
        ),
        listTilePadding: const EdgeInsets.symmetric(horizontal: 10),
        countryNameStyle:
            regular2(context).copyWith(color: notifires.getGrey3Whitecolor),
        countryCodeStyle:
            regular2(context).copyWith(color: notifires.getGrey3Whitecolor),
        searchFieldPadding: const EdgeInsets.all(10),
        searchFieldInputDecoration: InputDecoration(
          hintText: "Search Country",
          hintStyle: regular3(context).copyWith(color: grey2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          fillColor: whiteColor,
          filled: true,
          suffixIcon: widget.suffixIcon ?? const SizedBox(),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: grey2,
          ),
        ),
      ),
      controller: widget.textEditingControllerCommons,
      dropdownIcon: Icon(
        Icons.arrow_drop_down,
        color: notifires.getGrey3Whitecolor,
      ),
      onChanged: widget.onChanged,
      validator: widget.validator,
      onCountryChanged: widget.oncountryChanged,
      initialValue: widget.selectedcountry,
      cursorColor: notifires.getwhiteblackcolor,
      style: regular2(context),
      textAlign: TextAlign.start,
      focusNode: _focusNode,
      autofocus: false,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.call,
          color: acentColor,
        ),
        filled: true,
        fillColor: notifires.getBoxColor,
        hintText: 'Enter Your Number'.tr,
        hintStyle: regular3(context),
        border: const OutlineInputBorder(),
        counterText: "",
        enabled: true,
        errorStyle: regular(context).copyWith(color: pc1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: notifires.getBoxColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: notifires.getBoxColor, width: 1.0),
        ),
      ),
      initialCountryCode: widget.defultcountry,
    );
  }
}

final Map<String, int> phoneLengths = {
  'AF': 9, // Afghanistan
  'AL': 9, // Albania
  'DZ': 9, // Algeria
  'AS': 10, // American Samoa
  'AD': 6, // Andorra
  'AO': 9, // Angola
  'AI': 7, // Anguilla
  'AG': 7, // Antigua and Barbuda
  'AR': 10, // Argentina
  'AM': 8, // Armenia
  'AW': 7, // Aruba
  'AU': 9, // Australia
  'AT': 10, // Austria
  'AZ': 9, // Azerbaijan
  'BS': 7, // Bahamas
  'BH': 8, // Bahrain
  'BD': 10, // Bangladesh
  'BB': 7, // Barbados
  'BY': 9, // Belarus
  'BE': 9, // Belgium
  'BZ': 7, // Belize
  'BJ': 8, // Benin
  'BM': 7, // Bermuda
  'BT': 8, // Bhutan
  'BO': 8, // Bolivia
  'BA': 8, // Bosnia and Herzegovina
  'BW': 8, // Botswana
  'BR': 11, // Brazil
  'IO': 7, // British Indian Ocean Territory
  'VG': 7, // British Virgin Islands
  'BN': 7, // Brunei
  'BG': 9, // Bulgaria
  'BF': 8, // Burkina Faso
  'BI': 8, // Burundi
  'KH': 9, // Cambodia
  'CM': 9, // Cameroon
  'CA': 10, // Canada
  'CV': 7, // Cape Verde
  'KY': 7, // Cayman Islands
  'CF': 8, // Central African Republic
  'TD': 8, // Chad
  'CL': 9, // Chile
  'CN': 11, // China
  'CX': 9, // Christmas Island
  'CC': 6, // Cocos Islands
  'CO': 10, // Colombia
  'KM': 7, // Comoros
  'CK': 5, // Cook Islands
  'CR': 8, // Costa Rica
  'HR': 9, // Croatia
  'CU': 8, // Cuba
  'CY': 8, // Cyprus
  'CZ': 9, // Czech Republic
  'CD': 9, // Democratic Republic of the Congo
  'DK': 8, // Denmark
  'DJ': 6, // Djibouti
  'DM': 7, // Dominica
  'DO': 10, // Dominican Republic
  'TL': 7, // East Timor
  'EC': 9, // Ecuador
  'EG': 10, // Egypt
  'SV': 8, // El Salvador
  'GQ': 9, // Equatorial Guinea
  'ER': 7, // Eritrea
  'EE': 8, // Estonia
  'ET': 9, // Ethiopia
  'FJ': 7, // Fiji
  'FI': 10, // Finland
  'FR': 9, // France
  'GA': 7, // Gabon
  'GM': 7, // Gambia
  'GE': 9, // Georgia
  'DE': 11, // Germany
  'GH': 9, // Ghana
  'GI': 8, // Gibraltar
  'GR': 10, // Greece
  'GL': 6, // Greenland
  'GD': 7, // Grenada
  'GU': 10, // Guam
  'GT': 8, // Guatemala
  'GN': 9, // Guinea
  'GW': 7, // Guinea-Bissau
  'GY': 7, // Guyana
  'HT': 8, // Haiti
  'HN': 8, // Honduras
  'HK': 8, // Hong Kong
  'HU': 9, // Hungary
  'IS': 7, // Iceland
  'IN': 10, // India
  'ID': 10, // Indonesia
  'IR': 10, // Iran
  'IQ': 10, // Iraq
  'IE': 9, // Ireland
  'IL': 9, // Israel
  'IT': 10, // Italy
  'JM': 7, // Jamaica
  'JP': 10, // Japan
  'JO': 9, // Jordan
  'KZ': 10, // Kazakhstan
  'KE': 9, // Kenya
  'KI': 8, // Kiribati
  'KW': 8, // Kuwait
  'KG': 9, // Kyrgyzstan
  'LA': 10, // Laos
  'LV': 8, // Latvia
  'LB': 8, // Lebanon
  'LS': 8, // Lesotho
  'LR': 7, // Liberia
  'LY': 9, // Libya
  'LI': 7, // Liechtenstein
  'LT': 8, // Lithuania
  'LU': 9, // Luxembourg
  'MO': 8, // Macau
  'MK': 8, // Macedonia
  'MG': 9, // Madagascar
  'MW': 9, // Malawi
  'MY': 9, // Malaysia
  'MV': 7, // Maldives
  'ML': 8, // Mali
  'MT': 8, // Malta
  'MH': 7, // Marshall Islands
  'MR': 8, // Mauritania
  'MU': 7, // Mauritius
  'YT': 9, // Mayotte
  'MX': 10, // Mexico
  'FM': 7, // Micronesia
  'MD': 8, // Moldova
  'MC': 9, // Monaco
  'MN': 8, // Mongolia
  'ME': 8, // Montenegro
  'MS': 7, // Montserrat
  'MA': 9, // Morocco
  'MZ': 9, // Mozambique
  'MM': 9, // Myanmar
  'NA': 9, // Namibia
  'NR': 7, // Nauru
  'NP': 10, // Nepal
  'NL': 9, // Netherlands
  'AN': 9, // Netherlands Antilles
  'NC': 6, // New Caledonia
  'NZ': 9, // New Zealand
  'NI': 8, // Nicaragua
  'NE': 8, // Niger
  'NG': 10, // Nigeria
  'NU': 4, // Niue
  'NF': 6, // Norfolk Island
  'KP': 10, // North Korea
  'MP': 10, // Northern Mariana Islands
  'NO': 8, // Norway
  'OM': 8, // Oman
  'PK': 10, // Pakistan
  'PW': 7, // Palau
  'PA': 8, // Panama
  'PG': 8, // Papua New Guinea
  'PY': 9, // Paraguay
  'PE': 9, // Peru
  'PH': 10, // Philippines
  'PL': 9, // Poland
  'PT': 9, // Portugal
  'PR': 10, // Puerto Rico
  'QA': 8, // Qatar
  'CG': 9, // Republic of the Congo
  'RE': 9, // Réunion
  'RO': 10, // Romania
  'RU': 10, // Russia
  'RW': 9, // Rwanda
  'BL': 9, // Saint Barthélemy
  'SH': 5, // Saint Helena
  'KN': 7, // Saint Kitts and Nevis
  'LC': 7, // Saint Lucia
  'MF': 9, // Saint Martin
  'PM': 6, // Saint Pierre and Miquelon
  'VC': 7, // Saint Vincent and the Grenadines
  'WS': 7, // Samoa
  'SM': 9, // San Marino
  'ST': 7, // São Tomé and Príncipe
  'SA': 9, // Saudi Arabia
  'SN': 9, // Senegal
  'RS': 9, // Serbia
  'SC': 7, // Seychelles
  'SL': 8, // Sierra Leone
  'SG': 8, // Singapore
  'SX': 10, // Sint Maarten
  'SK': 9, // Slovakia
  'SI': 9, // Slovenia
  'SB': 7, // Solomon Islands
  'SO': 7, // Somalia
  'ZA': 9, // South Africa
  'KR': 10, // South Korea
  'SS': 9, // South Sudan
  'ES': 9, // Spain
  'LK': 10, // Sri Lanka
  'SD': 9, // Sudan
  'SR': 7, // Suriname
  'SJ': 8, // Svalbard and Jan Mayen
  'SZ': 8, // Swaziland
  'SE': 7, // Sweden
  'CH': 9, // Switzerland
  'SY': 9, // Syria
  'TW': 10, // Taiwan
  'TJ': 9, // Tajikistan
  'TZ': 9, // Tanzania
  'TH': 9,
  'TG': 8, // Togo
  'TK': 4, // Tokelau
  'TO': 5, // Tonga
  'TT': 7, // Trinidad and Tobago
  'TN': 8, // Tunisia
  'TR': 10, // Turkey
  'TM': 8, // Turkmenistan
  'TC': 7, // Turks and Caicos Islands
  'TV': 5, // Tuvalu
  'UG': 9, // Uganda
  'UA': 10, // Ukraine
  'AE': 9, // United Arab Emirates
  'GB': 10, // United Kingdom
  'US': 10, // United States
  'UY': 9, // Uruguay
  'UZ': 9, // Uzbekistan
  'VU': 7, // Vanuatu
  'VA': 9, // Vatican
  'VE': 10, // Venezuela
  'VN': 10, // Vietnam
  'WF': 6, // Wallis and Futuna
  'YE': 9, // Yemen
  'ZM': 9, // Zambia
  'ZW': 9, // Zimbabwe
};
