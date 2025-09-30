import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/controller/ticket_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/user_thread_model.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/ticket/ticket_create_screen.dart';
import 'package:carvy/view/myaccount/ticket/ticket_reply_screen.dart';

import '../../../utils/common_widget.dart';

class CloseTicketScreen extends StatefulWidget {
  const CloseTicketScreen({super.key});

  @override
  State<CloseTicketScreen> createState() => _CloseTicketState();
}

class _CloseTicketState extends State<CloseTicketScreen> {
  UserThreadModel? userThreadmodelClose;
  RefreshController refreshControllerClose = RefreshController();
  // GlobalScopeController globalScopeController = Get.find();
  TicketController ticketController = Get.find();
  @override
  void initState() {
    super.initState();

    getDataClose();
  }

  getDataClose() async {
    userThreadmodelClose = await ticketController.getUsercloseTicket();

    setState(() {
      refreshControllerClose.refreshCompleted();
    });
  }

  onLoading() {}
  onRefresh() {
    userThreadmodelClose = null;
    setState(() {});
    getDataClose();
  }

  stateSetter(fn) => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: SmartRefresher(
        controller: refreshControllerClose,
        onRefresh: onRefresh,
        onLoading: onLoading,
        enablePullUp: false,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: userThreadmodelClose == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : userThreadmodelClose?.data?.threads.isEmpty ?? true
                  ? Center(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("You don't have any Ticket !".tr,
                            style: heading2Grey1(context)),
                        const SizedBox(
                          height: 24,
                        ),
                        Text("Create a new Ticket".tr,
                            style: heading3Grey1(context).copyWith()),
                        const SizedBox(
                          height: 24,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TicketCreateScreen()))
                                  .then((value) {
                                if (value != null) {
                                  userThreadmodelClose = null;
                                  setState(() {});
                                  getDataClose();
                                }
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 90),
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: getColorBasedOnActiveModuleid(),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  "New Ticket".tr,
                                  style: heading2(context)
                                      .copyWith(color: whiteColor),
                                ),
                              ),
                            )),
                      ],
                    ))
                  : ListView.builder(
                      itemCount: userThreadmodelClose!.data!.threads.length,
                      itemBuilder: ((context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketReplyScreen(
                                    thread: userThreadmodelClose!
                                        .data!.threads[index],
                                  ),
                                )).then((value) {
                              userThreadmodelClose = null;
                              setState(() {});
                              getDataClose();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: notifires.getBoxColor,
                                  borderRadius: BorderRadius.circular(13)),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "${userThreadmodelClose!.data!.threads[index].title!.length > 20 ? userThreadmodelClose!.data!.threads[index].title!.substring(0, 19) : userThreadmodelClose!.data!.threads[index].title!} #${userThreadmodelClose!.data!.threads[index].threadId}",
                                          style: boldstyle(context).copyWith(
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Ticket Title".tr,
                                              style:
                                                  boldstyle(context).copyWith(
                                                color: notifires
                                                    .getGrey2Whitecolor,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${userThreadmodelClose!.data!.threads[index].description!.length > 30 ? "${userThreadmodelClose!.data!.threads[index].description!.substring(0, 29)}..." : userThreadmodelClose!.data!.threads[index].description}",
                                                  style:
                                                      regular(context).copyWith(
                                                    color: notifires
                                                        .getGrey3Whitecolor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          children: [
                                            Text(
                                                DateFormat('hh:mm a').format(
                                                    DateTime.parse(
                                                        userThreadmodelClose!
                                                            .data!
                                                            .threads[index]
                                                            .updatedAt!)),
                                                style:
                                                    regular(context).copyWith(
                                                  color: notifires
                                                      .getGrey3Whitecolor,
                                                  fontSize: 12,
                                                )),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              DateFormat('yy-MM-dd').format(
                                                  DateTime.parse(
                                                      userThreadmodelClose!
                                                          .data!
                                                          .threads[index]
                                                          .updatedAt!)),
                                              style: regular(context).copyWith(
                                                color: notifires
                                                    .getGrey3Whitecolor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
        ),
      ),
    );
  }
}
