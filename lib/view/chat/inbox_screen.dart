import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../customwidget/data_not_found.dart';
import '../../model/get_message_model.dart';
import '../../utils/common_widget.dart';
import '../../work_space.dart';
import 'conversation_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'conversation_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  GetMessageModel? getMessageModel;
  List<Conversations> list = [];
  RefreshController refreshController = RefreshController();
  HomeController homeController = Get.find();
  num offset = 0;
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("chatList").child('$userId');

  static String getFormattedTime({
    required BuildContext context,
    required String? time,
  }) {
    if (time == null || time.isEmpty) {
      return 'Invalid time';
    }

    try {
      final microseconds = int.parse(time);
      final date = DateTime.fromMillisecondsSinceEpoch(microseconds);
      final formattedTime =
          TimeOfDay.fromDateTime(date).format(context).toLowerCase();
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final DateFormat dateFormatter = DateFormat("d MMM");
      final formattedDate = dateFormatter.format(date);
      if (isToday) {
        return formattedTime;
      } else {
        return formattedDate;
      }
    } catch (e) {
      return 'Invalid time';
    }
  }

  @override
  void initState() {
    super.initState();
    isInboxOpen = true;
    // Set user defaults only if node doesn't exist
    dbRef.once().then((event) {
      if (!event.snapshot.exists) {
        database.child(userId.toString()).set({
          "userId": userId.toString(),
          "playerId": oneSiginalplayerid ?? "null",
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        generalController.tabController.index = 0;
        generalController.currentIndex.value = 0;
      },
      child: showerrorWhenloginwithOtherDevice == "token not match"
          ? Center(child: showTokenExpirePlease())
          : Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                backgroundColor: notifires.getbgcolor,
                elevation: 0,
                leadingWidth: 80,
                title: Text("Messages".tr, style: heading2Grey1(context)),
              ),
              body: token.isEmpty
                  ? Center(child: notloginwidget())
                  : loginModel!.data!.firebaseAuth == "0"
                      ? Center(child: notloginwidget())
                      : StreamBuilder(
                          stream: dbRef.onValue,
                          builder:
                              (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return chatInboxScreenShimmer();
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.snapshot.children.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: notifires.getGrey3Whitecolor,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "No messages yet".tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: notifires.getGrey3Whitecolor,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Your conversations will appear here".tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notifires.getGrey3Whitecolor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            List<DataSnapshot> items =
                                snapshot.data!.snapshot.children.toList();
                            items.sort((a, b) => b
                                .child('timestamp')
                                .value
                                .toString()
                                .compareTo(
                                    a.child('timestamp').value.toString()));
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                                DataSnapshot snapshot = items[index];
                                var value = snapshot.value;
                                if (value is! Map<dynamic, dynamic>) {
                                  return Container();
                                }
                                Map userData = value;
                                userData['key'] = snapshot.key;
                                log("chat list is $userData");

                                // Extract fields from metadata
                                String itemName =
                                    userData['itemName']?.toString() ??
                                        'Unknown';
                                String lastMessage =
                                    userData['message']?.toString() ?? '';
                                String fromName =
                                    userData['from']?.toString() ?? 'Unknown';
                                String imageUrl =
                                    userData['image']?.toString() ?? '';
                                String bookingStatus =
                                    userData['bookingStatus']?.toString() ?? '';
                                String timestampStr =
                                    userData['timestamp']?.toString() ?? '';
                                String reciverId;
                                if (userData["receiverId"].toString() ==
                                    userId.toString()) {
                                  reciverId = userData["senderId"].toString();
                                } else {
                                  reciverId = userData["receiverId"].toString();
                                }

                                bool isUnread =
                                    userData['senderId'] != userId.toString() &&
                                        !(userData['seen'] ?? false);

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Material(
                                    color: notifires.getBoxColor,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        if (isUnread) {
                                          dbRef
                                              .child(snapshot.key!)
                                              .update({'seen': true});
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConversationScreen(
                                              bookingId: userData["bookingId"]
                                                      ?.toString() ??
                                                  '',
                                              bookingStatus:
                                                  userData["bookingStatus"]
                                                          ?.toString() ??
                                                      '',
                                              from: fromName,
                                              title: itemName,
                                              image: imageUrl.isNotEmpty
                                                  ? imageUrl
                                                  : null,
                                              conversationId: userData["roomId"]
                                                      ?.toString() ??
                                                  '',
                                              senderId: userId.toString(),
                                              reciverId: reciverId,
                                              playerId:
                                                  userData["playeridUser2"]
                                                          ?.toString() ??
                                                      '',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Avatar
                                            Stack(
                                              children: [
                                                Container(
                                                  width: 56,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: notifires.getbgcolor,
                                                  ),
                                                  child: imageUrl.isEmpty
                                                      ? Icon(Icons.person,
                                                          size: 32,
                                                          color: notifires
                                                              .getGrey3Whitecolor)
                                                      : ClipOval(
                                                          child: Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Icon(
                                                                  Icons.person,
                                                                  size: 32,
                                                                  color: notifires
                                                                      .getGrey3Whitecolor);
                                                            },
                                                          ),
                                                        ),
                                                ),
                                                if (isUnread)
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        color: appgreen,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: notifires
                                                              .getBoxColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(width: 16),

                                            // Message content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          itemName,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: notifires
                                                                .getwhiteblackcolor,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        getFormattedTime(
                                                            context: context,
                                                            time: timestampStr),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: notifires
                                                              .getGrey3Whitecolor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    lastMessage,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: notifires
                                                          .getGrey3Whitecolor,
                                                      fontWeight: isUnread
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${"From".tr}: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: notifires
                                                              .getGrey3Whitecolor,
                                                        ),
                                                      ),
                                                      Text(
                                                        fromName,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: notifires
                                                              .getGrey3Whitecolor,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      if (bookingStatus
                                                          .isNotEmpty)
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: bookingStatus ==
                                                                        "Confirmed" ||
                                                                    bookingStatus ==
                                                                        "Completed"
                                                                ? Colors.green
                                                                    .withOpacity(
                                                                        0.2)
                                                                : bookingStatus ==
                                                                        "Pending"
                                                                    ? Colors
                                                                        .orange
                                                                        .withOpacity(
                                                                            0.2)
                                                                    : bookingStatus ==
                                                                                "Declined" ||
                                                                            bookingStatus ==
                                                                                "Cancelled"
                                                                        ? Colors
                                                                            .red
                                                                            .withOpacity(
                                                                                0.2)
                                                                        : Colors
                                                                            .grey
                                                                            .withOpacity(0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Text(
                                                            bookingStatus,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: bookingStatus ==
                                                                          "Confirmed" ||
                                                                      bookingStatus ==
                                                                          "Completed"
                                                                  ? Colors.green
                                                                  : bookingStatus ==
                                                                          "Pending"
                                                                      ? Colors
                                                                          .orange
                                                                      : bookingStatus == "Declined" ||
                                                                              bookingStatus ==
                                                                                  "Cancelled"
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .grey,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
    );
  }
// }

// class InboxScreen extends StatefulWidget {
//   const InboxScreen({super.key});

//   @override
//   State<InboxScreen> createState() => _InboxScreenState();
// }

// class _InboxScreenState extends State<InboxScreen> {
//   GetMessageModel? getMessageModel;
//   List<Conversations> list = [];
//   RefreshController refreshController = RefreshController();
//   HomeController homeController = Get.find();
//   num offset = 0;
//   final DatabaseReference dbRef =
//       FirebaseDatabase.instance.ref("chatList").child('$userId');

//   // Search functionality variables
//   TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   List<DataSnapshot> _allItems = [];
//   List<DataSnapshot> _filteredItems = [];

//   static String getFormattedTime({
//     required BuildContext context,
//     required String? time,
//   }) {
//     if (time == null || time.isEmpty) {
//       return 'Invalid time';
//     }

//     try {
//       final microseconds = int.parse(time);
//       final date = DateTime.fromMillisecondsSinceEpoch(microseconds);
//       final formattedTime =
//           TimeOfDay.fromDateTime(date).format(context).toLowerCase();
//       final now = DateTime.now();
//       final isToday = date.year == now.year &&
//           date.month == now.month &&
//           date.day == now.day;
//       final DateFormat dateFormatter = DateFormat("d MMM");
//       final formattedDate = dateFormatter.format(date);
//       if (isToday) {
//         return formattedTime;
//       } else {
//         return formattedDate;
//       }
//     } catch (e) {
//       return 'Invalid time';
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     isInboxOpen = true;
//     // Set user defaults only if node doesn't exist
//     dbRef.once().then((event) {
//       if (!event.snapshot.exists) {
//         database.child(userId.toString()).set({
//           "userId": userId.toString(),
//           "playerId": oneSiginalplayerid ?? "null",
//         });
//       }
//     });
//   }

//   // Method to filter items based on search query
//   void _filterItems(String query) {
//     setState(() {
//       _searchQuery = query.toLowerCase();

//       if (_searchQuery.isEmpty) {
//         _filteredItems = List.from(_allItems);
//       } else {
//         _filteredItems = _allItems.where((item) {
//           final itemName = item.child('itemName').value?.toString()?.toLowerCase() ?? '';
//           final fromName = item.child('from').value?.toString()?.toLowerCase() ?? '';
//           final bookingId = item.child('bookingId').value?.toString()?.toLowerCase() ?? '';
//           final message = item.child('message').value?.toString()?.toLowerCase() ?? '';

//           return itemName.contains(_searchQuery) ||
//                  fromName.contains(_searchQuery) ||
//                  bookingId.contains(_searchQuery) ||
//                  message.contains(_searchQuery);
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (v) {
//         generalController.tabController.index = 0;
//         generalController.currentIndex.value = 0;
//       },
//       child: showerrorWhenloginwithOtherDevice == "token not match"
//           ? Center(child: showTokenExpirePlease())
//           : Scaffold(
//               backgroundColor: notifires.getbgcolor,
//               appBar: AppBar(
//                 automaticallyImplyLeading: false,
//                 centerTitle: true,
//                 backgroundColor: notifires.getbgcolor,
//                 elevation: 0,
//                 leadingWidth: 80,
//                 title: Text(
//                   "Messages".tr,
//                   style: heading2Grey1(context)
//                 ),
//                 actions: [
//                   IconButton(
//                     icon: Icon(Icons.search, color: notifires.getwhiteblackcolor),
//                     onPressed: () {
//                       showSearch(
//                         context: context,
//                         delegate: InboxSearchDelegate(_allItems, _filterItems,),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               body: token.isEmpty
//                   ? Center(child: notloginwidget())
//                   : loginModel!.data!.firebaseAuth == "0"
//                       ? Center(child: notloginwidget())
//                       : StreamBuilder(
//                           stream: dbRef.onValue,
//                           builder:
//                               (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return chatInboxScreenShimmer();
//                             }
//                             if (!snapshot.hasData ||
//                                 snapshot.data!.snapshot.children.isEmpty) {
//                               return Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.chat_bubble_outline,
//                                       size: 64,
//                                       color: notifires.getGrey3Whitecolor,
//                                     ),
//                                     SizedBox(height: 16),
//                                     Text(
//                                       "No messages yet".tr,
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: notifires.getGrey3Whitecolor,
//                                       ),
//                                     ),
//                                     SizedBox(height: 8),
//                                     Text(
//                                       "Your conversations will appear here".tr,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: notifires.getGrey3Whitecolor,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }

//                             // Store all items and filter based on search query
//                             _allItems = snapshot.data!.snapshot.children.toList();

//                             if (_searchQuery.isNotEmpty) {
//                               _filterItems(_searchQuery);
//                             } else {
//                               _filteredItems = List.from(_allItems);
//                             }

//                             _filteredItems.sort((a, b) => b
//                                 .child('timestamp')
//                                 .value
//                                 .toString()
//                                 .compareTo(
//                                     a.child('timestamp').value.toString()));

//                             return Column(
//                               children: [
//                                 // Search Bar
//                                 Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                   child: TextField(
//                                     controller: _searchController,
//                                     decoration: InputDecoration(
//                                       hintText: 'Search by name, booking ID or message...',
//                                       prefixIcon: Icon(Icons.search),
//                                       suffixIcon: _searchQuery.isNotEmpty
//                                           ? IconButton(
//                                               icon: Icon(Icons.clear),
//                                               onPressed: () {
//                                                 _searchController.clear();
//                                                 _filterItems('');
//                                               },
//                                             )
//                                           : null,
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                     ),
//                                     onChanged: _filterItems,
//                                   ),
//                                 ),

//                                 // Results count
//                                 if (_searchQuery.isNotEmpty)
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 16),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           '${_filteredItems.length} results found',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: notifires.getGrey3Whitecolor,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                 // Messages List
//                                 Expanded(
//                                   child: ListView.builder(
//                                     padding: EdgeInsets.symmetric(vertical: 8),
//                                     itemCount: _filteredItems.length,
//                                     itemBuilder: (BuildContext context, int index) {
//                                       DataSnapshot snapshot = _filteredItems[index];
//                                       var value = snapshot.value;
//                                       if (value is! Map<dynamic, dynamic>) {
//                                         return Container();
//                                       }
//                                       Map userData = value;
//                                       userData['key'] = snapshot.key;
//                                       log("chat list is $userData");

//                                       // Extract fields from metadata
//                                       String itemName =
//                                           userData['itemName']?.toString() ??
//                                               'Unknown';
//                                       String lastMessage =
//                                           userData['message']?.toString() ?? '';
//                                       String fromName =
//                                           userData['from']?.toString() ?? 'Unknown';
//                                       String imageUrl =
//                                           userData['image']?.toString() ?? '';
//                                       String bookingStatus =
//                                           userData['bookingStatus']?.toString() ?? '';
//                                       String timestampStr =
//                                           userData['timestamp']?.toString() ?? '';
//                                       String reciverId;
//                                       if (userData["receiverId"].toString() ==
//                                           userId.toString()) {
//                                         reciverId = userData["senderId"].toString();
//                                       } else {
//                                         reciverId = userData["receiverId"].toString();
//                                       }

//                                       bool isUnread =
//                                           userData['senderId'] != userId.toString() &&
//                                               !(userData['seen'] ?? false);

//                                       return Container(
//                                         margin: EdgeInsets.symmetric(
//                                             horizontal: 16, vertical: 4),
//                                         child: Material(
//                                           color: notifires.getBoxColor,
//                                           borderRadius: BorderRadius.circular(16),
//                                           child: InkWell(
//                                             borderRadius: BorderRadius.circular(16),
//                                             onTap: () {
//                                               if (isUnread) {
//                                                 dbRef
//                                                     .child(snapshot.key!)
//                                                     .update({'seen': true});
//                                               }

//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ConversationScreen(
//                                                     bookingId: userData["bookingId"]
//                                                             ?.toString() ??
//                                                         '',
//                                                     bookingStatus:
//                                                         userData["bookingStatus"]
//                                                                 ?.toString() ??
//                                                             '',
//                                                     from: fromName,
//                                                     title: itemName,
//                                                     image: imageUrl.isNotEmpty
//                                                         ? imageUrl
//                                                         : null,
//                                                     conversationId: userData["roomId"]
//                                                             ?.toString() ??
//                                                         '',
//                                                     senderId: userId.toString(),
//                                                     reciverId: reciverId,
//                                                     playerId:
//                                                         userData["playeridUser2"]
//                                                                 ?.toString() ??
//                                                             '',
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                             child: Padding(
//                                               padding: EdgeInsets.all(16),
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   // Avatar
//                                                   Stack(
//                                                     children: [
//                                                       Container(
//                                                         width: 56,
//                                                         height: 56,
//                                                         decoration: BoxDecoration(
//                                                           shape: BoxShape.circle,
//                                                           color: notifires.getbgcolor,
//                                                         ),
//                                                         child: imageUrl.isEmpty
//                                                             ? Icon(Icons.person,
//                                                                 size: 32,
//                                                                 color: notifires
//                                                                     .getGrey3Whitecolor)
//                                                             : ClipOval(
//                                                                 child: Image.network(
//                                                                   imageUrl,
//                                                                   fit: BoxFit.cover,
//                                                                   errorBuilder:
//                                                                       (context, error,
//                                                                           stackTrace) {
//                                                                     return Icon(
//                                                                         Icons.person,
//                                                                         size: 32,
//                                                                         color: notifires
//                                                                             .getGrey3Whitecolor);
//                                                                   },
//                                                                 ),
//                                                               ),
//                                                       ),
//                                                       if (isUnread)
//                                                         Positioned(
//                                                           right: 0,
//                                                           bottom: 0,
//                                                           child: Container(
//                                                             width: 16,
//                                                             height: 16,
//                                                             decoration: BoxDecoration(
//                                                               color: appgreen,
//                                                               shape: BoxShape.circle,
//                                                               border: Border.all(
//                                                                 color: notifires
//                                                                     .getBoxColor,
//                                                                 width: 2,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                   SizedBox(width: 16),

//                                                   // Message content
//                                                   Expanded(
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment.start,
//                                                       children: [
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Expanded(
//                                                               child: Text(
//                                                                 itemName,
//                                                                 style: TextStyle(
//                                                                   fontSize: 16,
//                                                                   fontWeight:
//                                                                       FontWeight.w600,
//                                                                   color: notifires
//                                                                       .getwhiteblackcolor,
//                                                                 ),
//                                                                 overflow: TextOverflow
//                                                                     .ellipsis,
//                                                               ),
//                                                             ),
//                                                             Text(
//                                                               getFormattedTime(
//                                                                   context: context,
//                                                                   time: timestampStr),
//                                                               style: TextStyle(
//                                                                 fontSize: 12,
//                                                                 color: notifires
//                                                                     .getGrey3Whitecolor,
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         SizedBox(height: 4),
//                                                         Text(
//                                                           lastMessage,
//                                                           style: TextStyle(
//                                                             fontSize: 14,
//                                                             color: notifires
//                                                                 .getGrey3Whitecolor,
//                                                             fontWeight: isUnread
//                                                                 ? FontWeight.w600
//                                                                 : FontWeight.normal,
//                                                           ),
//                                                           overflow:
//                                                               TextOverflow.ellipsis,
//                                                           maxLines: 1,
//                                                         ),
//                                                         SizedBox(height: 4),
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               "${"From".tr}: ",
//                                                               style: TextStyle(
//                                                                 fontSize: 12,
//                                                                 color: notifires
//                                                                     .getGrey3Whitecolor,
//                                                               ),
//                                                             ),
//                                                             Text(
//                                                               fromName,
//                                                               style: TextStyle(
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight.w600,
//                                                                 color: notifires
//                                                                     .getGrey3Whitecolor,
//                                                               ),
//                                                             ),
//                                                             Spacer(),
//                                                             if (bookingStatus
//                                                                 .isNotEmpty)
//                                                               Container(
//                                                                 padding: EdgeInsets
//                                                                     .symmetric(
//                                                                         horizontal: 8,
//                                                                         vertical: 4),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: bookingStatus ==
//                                                                             "Confirmed" ||
//                                                                         bookingStatus ==
//                                                                             "Completed"
//                                                                     ? Colors.green
//                                                                         .withOpacity(
//                                                                             0.2)
//                                                                     : bookingStatus ==
//                                                                             "Pending"
//                                                                         ? Colors
//                                                                             .orange
//                                                                             .withOpacity(
//                                                                                 0.2)
//                                                                         : bookingStatus ==
//                                                                                     "Declined" ||
//                                                                                 bookingStatus ==
//                                                                                     "Cancelled"
//                                                                             ? Colors
//                                                                                 .red
//                                                                                 .withOpacity(
//                                                                                     0.2)
//                                                                             : Colors
//                                                                                 .grey
//                                                                                 .withOpacity(0.2),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               12),
//                                                                 ),
//                                                                 child: Text(
//                                                                   bookingStatus,
//                                                                   style: TextStyle(
//                                                                     fontSize: 10,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600,
//                                                                     color: bookingStatus ==
//                                                                               "Confirmed" ||
//                                                                           bookingStatus ==
//                                                                               "Completed"
//                                                                       ? Colors.green
//                                                                       : bookingStatus ==
//                                                                               "Pending"
//                                                                           ? Colors
//                                                                               .orange
//                                                                           : bookingStatus == "Declined" ||
//                                                                                   bookingStatus ==
//                                                                                       "Cancelled"
//                                                                               ? Colors
//                                                                                   .red
//                                                                               : Colors
//                                                                                   .grey,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//             ),
//     );
//   }
// }
// class InboxSearchDelegate extends SearchDelegate {
//   final List<DataSnapshot> allItems;
//   final Function(String) filterItems;

//   InboxSearchDelegate(this.allItems, this.filterItems, );

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return _buildSearchResults();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return _buildSearchResults();
//   }

//   Widget _buildSearchResults() {
//     final results = allItems.where((item) {
//       final itemName = item.child('itemName').value?.toString()?.toLowerCase() ?? '';
//       final fromName = item.child('from').value?.toString()?.toLowerCase() ?? '';
//       final bookingId = item.child('bookingId').value?.toString()?.toLowerCase() ?? '';
//       final message = item.child('message').value?.toString()?.toLowerCase() ?? '';

//       return itemName.contains(query.toLowerCase()) ||
//              fromName.contains(query.toLowerCase()) ||
//              bookingId.contains(query.toLowerCase()) ||
//              message.contains(query.toLowerCase());
//     }).toList();

//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final item = results[index];
//         final userData = item.value as Map<dynamic, dynamic>;

//         String itemName = userData['itemName']?.toString() ?? 'Unknown';
//         String lastMessage = userData['message']?.toString() ?? '';
//         String fromName = userData['from']?.toString() ?? 'Unknown';
//         String imageUrl = userData['image']?.toString() ?? '';
//         String timestampStr = userData['timestamp']?.toString() ?? '';

//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
//             child: imageUrl.isEmpty ? Icon(Icons.person) : null,
//           ),
//           title: Text(itemName),
//           subtitle: Text(lastMessage),
//           trailing: Text(_getFormattedTime(timestampStr,context)),
//           onTap: () {
//             // Handle item tap
//           },
//         );
//       },
//     );
//   }

//   String _getFormattedTime(String timestampStr,context) {
//     try {
//       final microseconds = int.parse(timestampStr);
//       final date = DateTime.fromMillisecondsSinceEpoch(microseconds);
//       final now = DateTime.now();
//       final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
//       final DateFormat dateFormatter = DateFormat("d MMM");
//       final formattedDate = dateFormatter.format(date);
//       return isToday ? TimeOfDay.fromDateTime(date).format(context).toLowerCase() : formattedDate;
//     } catch (e) {
//       return 'Invalid time';
//     }
//   }
}
