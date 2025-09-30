import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_bank_account_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

class AddPaymentDetials extends StatefulWidget {
  final dynamic id;
  final dynamic addedit;
  final dynamic type;
  const AddPaymentDetials(
      {super.key, required this.id, this.addedit, required this.type});

  @override
  State<AddPaymentDetials> createState() => _AddPaymentDetialsState();
}

class _AddPaymentDetialsState extends State<AddPaymentDetials> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddBankAccount addbankAccountController = Get.find();

  @override
  void initState() {
    super.initState();
    print(widget.type);
    addbankAccountController.id = widget.id;
    addbankAccountController.type = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
        title: '${widget.addedit} ${"Payment Details".tr}',
        centerTitle: true,
        backgroundColor: notifires.getbgcolor,
        iconColor: notifires.getwhiteblackcolor,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 5),
              const SizedBox(height: 20),
              widget.type == "upi"
                  ? TextFieldRefs(
                      validator: (value) {
                        return requiredUpi(value!);
                      },
                      inputAlignment: TextAlign.start,
                      txt: 'UPI'.tr,
                      textEditingControllerCommon:
                          addbankAccountController.email,
                      inputType: TextInputType.multiline,
                      maxlines: null,
                      icons: Icon(
                        Icons.money,
                        color: notifires.getwhiteblackcolor,
                      ))
                  : TextFieldRefs(
                      validator: (value) {
                        return validateEmail(value!);
                      },
                      inputAlignment: TextAlign.start,
                      txt: 'Email'.tr,
                      textEditingControllerCommon:
                          addbankAccountController.email,
                      inputType: TextInputType.multiline,
                      maxlines: null,
                      icons: Icon(
                        Icons.email,
                        color: notifires.getwhiteblackcolor,
                      )),
              const SizedBox(height: 10),
              TextFieldRefs(
                validator: (value) {
                  return requiredvalidat(value!);
                },
                maxlength: 1000,
                inputAlignment: TextAlign.start,
                minlines: 10,
                txt: 'Note..'.tr,
                textEditingControllerCommon: addbankAccountController.note,
                inputType: TextInputType.multiline,
                maxlines: null,
                onChange: (value) {
                  if (value!.length > 5000) {
                    addbankAccountController.note.text =
                        value.substring(0, 1000);
                    addbankAccountController.note.selection =
                        TextSelection.fromPosition(
                      TextPosition(
                          offset: addbankAccountController.note.text.length),
                    );
                  }
                  setState(() {});
                  return value;
                },
              ),
              const SizedBox(height: 25),
              CustomsButtons(
                  text: "Submit".tr,
                  backgroundColor: getColorBasedOnActiveModuleid(),
                  onPressed: () {
                    addbankAccountController.submitpaymentDetails(
                        context, _formKey);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
