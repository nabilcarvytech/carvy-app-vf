import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/controller/ticket_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/user_thread_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/ticket/ticket_create_screen.dart';
import 'package:carvy/view/myaccount/ticket/ticket_reply_screen.dart';

class OpenTicketScreen extends StatefulWidget {
  const OpenTicketScreen({super.key});

  @override
  State<OpenTicketScreen> createState() => _OpenTicketState();
}

class _OpenTicketState extends State<OpenTicketScreen> {
  UserThreadModel? userThreadmodelOpen;
  RefreshController refreshControllerOpen = RefreshController();
  TicketController ticketController = Get.find();

  @override
  void initState() {
    super.initState();

    getDataOpen();
  }

  getDataOpen() async {
    userThreadmodelOpen = await ticketController.getUserOpenTicket();
    setState(() {
      refreshControllerOpen.refreshCompleted();
    });
  }

  onLoading() {}
  onRefresh() {
    userThreadmodelOpen = null;
    setState(() {});
    getDataOpen();
  }

  stateSetter(fn) => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: SmartRefresher(
          controller: refreshControllerOpen,
          onLoading: onLoading,
          onRefresh: onRefresh,
          enablePullUp: false,
          child: Obx(
            () => ticketController.ticketLoading.value == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : userThreadmodelOpen == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : (userThreadmodelOpen?.data?.threads.isEmpty ?? true)
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("You don't have any Ticket !".tr,
                                    style: heading2Grey1(context).copyWith()),
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
                                      Get.toNamed(WebRoutes.ticketCreateScreen)
                                          ?.then((value) async {
                                        if (value != null) {
                                          userThreadmodelOpen = null;
                                          setState(() {});
                                          getDataOpen();
                                          ticketController.ticketLoading.value =
                                              true;
                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          ticketController.ticketLoading.value =
                                              false;
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 90, right: 90),
                                      child: Container(
                                        // padding: EdgeInsets.all(16),
                                        height: 40,
                                        // width: 130,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          "New Ticket".tr,
                                          style: heading2(context)
                                              .copyWith(color: whiteColor),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount:
                                userThreadmodelOpen!.data!.threads.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TicketReplyScreen(
                                                thread: userThreadmodelOpen!
                                                    .data!.threads[index],
                                              ))).then((value) async {
                                    if (value != null) {
                                      userThreadmodelOpen = null;
                                      setState(() {});
                                      getDataOpen();
                                      ticketController.ticketLoading.value =
                                          true;
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      ticketController.ticketLoading.value =
                                          false;
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: notifires.getBoxColor,
                                        borderRadius:
                                            BorderRadius.circular(13)),
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                "${userThreadmodelOpen!.data!.threads[index].title!.tr.length > 15 ? userThreadmodelOpen!.data!.threads[index].title!.tr.substring(0, 14) : userThreadmodelOpen!.data!.threads[index].title!.tr} #${userThreadmodelOpen!.data!.threads[index].threadId}",
                                                style:
                                                    boldstyle(context).copyWith(
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
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Ticket Title",
                                                        style:
                                                            boldstyle(context)
                                                                .copyWith(
                                                          color: notifires
                                                              .getGrey2Whitecolor,
                                                          fontSize: 14,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        userThreadmodelOpen!
                                                                    .data!
                                                                    .threads[
                                                                        index]
                                                                    .description!
                                                                    .tr
                                                                    .length >
                                                                25
                                                            ? "${userThreadmodelOpen!.data!.threads[index].description!.tr.substring(0, 24)}..."
                                                            : userThreadmodelOpen!
                                                                .data!
                                                                .threads[index]
                                                                .description!
                                                                .tr,
                                                        style: regular(context)
                                                            .copyWith(
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
                                                    DateFormat('hh:mm a')
                                                        .format(DateTime.parse(
                                                            userThreadmodelOpen!
                                                                .data!
                                                                .threads[index]
                                                                .updatedAt!)),
                                                    style: regular(context)
                                                        .copyWith(
                                                      color: notifires
                                                          .getGrey3Whitecolor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Text(
                                                    DateFormat('yy-MM-dd')
                                                        .format(DateTime.parse(
                                                            userThreadmodelOpen!
                                                                .data!
                                                                .threads[index]
                                                                .updatedAt!)),
                                                    style: regular(context)
                                                        .copyWith(
                                                      color: notifires
                                                          .getGrey3Whitecolor,
                                                      fontSize: 12,
                                                    ),
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
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox();
                            },
                          ),
          )),
      bottomNavigationBar: userThreadmodelOpen == null ||
              userThreadmodelOpen!.data == null ||
              userThreadmodelOpen!.data!.threads.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(25.0),
              child: CustomsButtons(
                text: 'New Ticket'.tr,
                backgroundColor: getColorBasedOnActiveModuleid(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TicketCreateScreen(),
                    ),
                  ).then((value) {
                    if (value != null) {
                      userThreadmodelOpen = null;
                      setState(() {});
                      getDataOpen();
                    }
                  });
                },
              ),
            ),
    );
  }
}
