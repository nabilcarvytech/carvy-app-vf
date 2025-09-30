import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/general_controller.dart';
import 'package:carvy/controller/ticket_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

class TicketCreateScreen extends StatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  State<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends State<TicketCreateScreen> {
  TextEditingController ticketCreateControllertitle = TextEditingController();
  TextEditingController ticketCreateControllerdescr = TextEditingController();
  TicketController ticketController = Get.find();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 55,
              child: CustomsButtons(
                  text: 'Send ticket'.tr,
                  backgroundColor: getColorBasedOnActiveModuleid(),
                  onPressed: () async {
                    if (ticketCreateControllertitle.text.toString() == "") {
                      showErrorToastMessage('Please fill the title'.tr);
                      return;
                    }
                    if (ticketCreateControllerdescr.text.toString() == "") {
                      showErrorToastMessage('Please fill the description'.tr);
                      return;
                    }
                    await ticketController.createSupportTicket(
                        ticketCreateControllertitle.text,
                        ticketCreateControllerdescr.text);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, "pop");
                  }),
            ),
          ),
          backgroundColor: notifires.getbgcolor,
          appBar: CustomAppBars(
              title: 'Create Ticket'.tr,
              backgroundColor: notifires.getbgcolor,
              iconColor: notifires.getwhiteblackcolor,
              titleColor: notifires.getwhiteblackcolor,
              centerTitle: false),
          body: Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: ListView(
              children: [
                const SizedBox(height: 5),
                Text('Create Ticket'.tr,
                    style: heading2(context)
                        .copyWith(color: getColorBasedOnActiveModuleid())),
                const SizedBox(height: 10),
                Text(
                  generalDataModel?.data?.metaData?.ticketIntro ??
                      'Welcome! Here’s what you need to know about your tickets.',
                  softWrap: true,
                  textAlign: TextAlign.left,
                  style: regular(context),
                ),
                const SizedBox(height: 20),
                TextFieldRefs(
                    maxlength: 120,
                    inputAlignment: TextAlign.start,
                    txt: 'Title'.tr,
                    textEditingControllerCommon: ticketCreateControllertitle,
                    inputType: TextInputType.multiline,
                    maxlines: null,
                    icons: Icon(
                      Icons.title_outlined,
                      color: notifires.getwhiteblackcolor,
                    )),
                const SizedBox(height: 10),
                TextFieldRefs(
                  maxlength: 1000,
                  inputAlignment: TextAlign.start,
                  minlines: 10,
                  txt: 'Description..'.tr,
                  textEditingControllerCommon: ticketCreateControllerdescr,
                  inputType: TextInputType.multiline,
                  maxlines: null,
                  onChange: (value) {
                    if (value!.length > 5000) {
                      ticketCreateControllerdescr.text =
                          value.substring(0, 1000);
                      ticketCreateControllerdescr.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                            offset: ticketCreateControllerdescr.text.length),
                      );
                    }
                    setState(() {});
                    return value;
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
