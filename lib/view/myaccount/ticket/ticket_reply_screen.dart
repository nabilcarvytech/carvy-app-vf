import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/reply_thred_model.dart';
import 'package:carvy/model/user_thread_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/ticket/ticket_first_screen.dart';

class TicketReplyScreen extends StatefulWidget {
  final Threads thread;
  const TicketReplyScreen({super.key, required this.thread});

  @override
  State<TicketReplyScreen> createState() => _TicketReplyScreenState();
}

class _TicketReplyScreenState extends State<TicketReplyScreen> {
  TextEditingController textEditingControllerreply = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ReplyThreadsModel? replyThreads;

  List<ReplyThreadsData> list = [];
  bool newMesage = true;
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    Map<String, String> postData = {
      "thread_id": widget.thread.threadId.toString()
    };
    var response = await httpGet(Config.getReplyThreads, postData);
    replyThreads = ReplyThreadsModel.fromJson(response);
    list = replyThreads!.data!.replyThreadsData!;

    setState(() {});
  }

  replySupportTicket(threadId, message) async {
    Map<String, String> postData = {
      "thread_id": widget.thread.threadId.toString(),
      "message": textEditingControllerreply.text
    };
    showLoading();
    var response = await httpPost(Config.replyToSupportTicket, postData);
    closeLoading();

    ReplyThreadsData replyThreadsData =
        ReplyThreadsData.fromJson(response['data']['reply']);
    list.insert(0, replyThreadsData);
    setState(() {});

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(microseconds: 1),
          curve: Curves.fastOutSlowIn);
      textEditingControllerreply.clear();
    });
  }

  onLoading() {}

  onRefresh() {
    replyThreads = null;
    setState(() {
      refreshController.refreshCompleted();
    });
    getdata();
  }

  stateSetter(fn) => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: notifires.getbgcolor,
        elevation: 0,
        leadingWidth: 80,
        leading: backButton(),
        title: Text(
          "${"Reply on ".tr}#${widget.thread.threadId.toString()}",
          style: heading2Grey1(context).copyWith(),
        ),
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        enablePullUp: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.thread.threadStatus == '0'
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            showGeneralDialog(
                              context: context,
                              pageBuilder: (context, anim1, anim2) {
                                return FadeTransition(
                                  opacity: anim1,
                                  child: AlertDialog(
                                    backgroundColor: notifires.getBoxColor,
                                    content: SizedBox(
                                      width: Get.size.width * 0.8,
                                      height: Get.size.height *
                                          0.5, // 80% of screen width
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Reply".tr,
                                              style: heading3Grey1(context)
                                                  .copyWith(),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Form(
                                                key: _formKey,
                                                child: TextFormField(
                                                  maxLength: 300,
                                                  textAlign: TextAlign.start,
                                                  controller:
                                                      textEditingControllerreply,
                                                  onChanged: (value) {
                                                    if (value.length > 5000) {
                                                      textEditingControllerreply
                                                              .text =
                                                          value.substring(
                                                              0, 1000);
                                                      textEditingControllerreply
                                                              .selection =
                                                          TextSelection
                                                              .fromPosition(
                                                        TextPosition(
                                                            offset:
                                                                textEditingControllerreply
                                                                    .text
                                                                    .length),
                                                      );
                                                    }
                                                    setState(() {});
                                                  },
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  minLines: 8,
                                                  maxLines: null,
                                                  style: regular2(context),
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        notifires.getboxcolor,
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusDefault),
                                                        borderSide: BorderSide(
                                                            color: notifires
                                                                .getGrey1Whitecolor)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusDefault),
                                                        borderSide: BorderSide(
                                                            color: notifires
                                                                .getGrey1Whitecolor)),
                                                  ),
                                                )),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            CustomsButtons(
                                                text: 'Reply Ticket'.tr,
                                                backgroundColor:
                                                    getColorBasedOnActiveModuleid(),
                                                onPressed: () async {
                                                  if (textEditingControllerreply
                                                          .text
                                                          .toString() ==
                                                      "") {
                                                    showErrorToastMessage(
                                                        "Please Enter the message");
                                                    return;
                                                  }

                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    replySupportTicket(
                                                        widget.thread.id,
                                                        textEditingControllerreply
                                                            .text);
                                                    Navigator.of(context).pop();
                                                  }
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              barrierDismissible: true,
                              barrierLabel: "Dismiss".tr,
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              barrierColor: Colors.black.withOpacity(0.7),
                              transitionBuilder:
                                  (context, anim1, anim2, child) {
                                return Transform.scale(
                                  scale: anim1.value,
                                  child: Opacity(
                                      opacity: anim1.value, child: child),
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 9, right: 8, top: 4, bottom: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: getColorBasedOnActiveModuleid(),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                    color: getColorBasedOnActiveModuleid()),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Reply'.tr,
                                        style: boldstyle(context).copyWith(
                                          color: whiteColor,
                                        )),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Icon(
                                      Icons.reply_outlined,
                                      color: whiteColor,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 180,
                              ),
                              widget.thread.threadStatus == '0'
                                  ? const SizedBox()
                                  : Transform.scale(
                                      scale: .8,
                                      child: Switch(
                                        value: newMesage,
                                        inactiveTrackColor: grey4,
                                        activeTrackColor:
                                            getColorBasedOnActiveModuleid(),
                                        inactiveThumbColor: Colors.white,
                                        trackOutlineColor: WidgetStateProperty
                                            .resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
                                            return notifires
                                                .getBoxColor; // When the switch is ON
                                          }
                                          return notifires
                                              .getBoxColor; // When the switch is OFF
                                        }),
                                        onChanged: (bool value) async {
                                          Map<String, String> postData = {
                                            "thread_id": widget.thread.threadId
                                                .toString(),
                                          };
                                          showLoading();
                                          await httpPost(
                                              Config.closeSupportTicket,
                                              postData);

                                          closeLoading();
                                          //
                                          // Get.back();

                                          // This is called when the user toggles the switch.
                                          setState(() {
                                            newMesage = value;
                                          });

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      const TicketFirstScreen()));
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: kElevationToShadow[4],
                  color: notifires.getblackwhitecolor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  border: Border.all(
                    width: 1,
                    color: notifires.getGrey2Whitecolor,
                    style: BorderStyle.solid,
                  ),
                ),
                width: Get.size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " #${widget.thread.threadId.toString()}",
                            style: heading3Grey1(context),
                          ),
                          widget.thread.threadStatus == '0'
                              ? Text(
                                  'Close'.tr,
                                  style: regular2(context)
                                      .copyWith(color: redColor),
                                )
                              : Text('Active'.tr,
                                  style: regular2(context)
                                      .copyWith(color: appgreen))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(" ${widget.thread.title.toString()}",
                          style: heading2Grey1(context)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        " ${widget.thread.description.toString()}",
                        style: regular2(context).copyWith(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: replyThreads == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : list.isEmpty
                        ? Center(
                            child: buildNoDataWidget(
                                context, "No Reply Available.".tr),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: ((context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: kElevationToShadow[4],
                                      color: list[index].isAdminReply != "0"
                                          ? notifires.getBoxColor
                                          : getColorBasedOnActiveModuleid(), // changed this line to modify the background color
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.transparent,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            list[index].message.toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: list[index]
                                                            .isAdminReply !=
                                                        "0"
                                                    ? getColorBasedOnActiveModuleid()
                                                    : whiteColor,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              list[index].isAdminReply != "0"
                                                  ? Text(
                                                      "Admin".tr,
                                                      style: regular2(context),
                                                    )
                                                  : Text(
                                                      "You".tr,
                                                      style: regular(context),
                                                    ),
                                              Column(
                                                children: [
                                                  Text(
                                                    list[index].createdAt !=
                                                                null &&
                                                            list[index]
                                                                .createdAt!
                                                                .isNotEmpty
                                                        ? DateFormat('hh:mm a')
                                                            .format(DateTime
                                                                .parse(list[
                                                                        index]
                                                                    .createdAt!))
                                                        : 'Invalid Date',
                                                    style: regular(context),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          //
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  )
                                ],
                              );
                            })),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
