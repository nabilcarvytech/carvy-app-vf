import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/utils/common_widget.dart';
import '../../controller/global_scope_controller.dart';
import '../../model/chat_inbox_model.dart';
import '../../utils/theme_style.dart';
import '../../work_space.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class ConversationScreen extends StatefulWidget {
  final String? bookingId;
  final String? title;
  final String? conversationId;
  final String? senderId;
  final String? reciverId;
  final dynamic image;
  final String? from;
  final String? playerId;
  final String? bookingStatus;
  const ConversationScreen({
    super.key,
    this.bookingId,
    this.title,
    this.image,
    this.conversationId,
    this.senderId,
    this.reciverId,
    this.from,
    this.playerId,
    this.bookingStatus,
  });
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  GlobalScopeController globalScopeController = Get.find();
  TextEditingController textEditingControllermessage = TextEditingController();
  String roomId = "";
  ScrollController scrollController = ScrollController();
  DatabaseReference? dbRef;
  final database = FirebaseDatabase.instance.ref().child("chatList");
  final userDb = FirebaseDatabase.instance.ref().child("users");
  bool isUploading = false;
  bool showGoToBottomButton = false;
  DateTime? lastNotificationTime;
  bool isOff = false;
  bool isCompleted = false;
  String bookingStatus = "";
  List<dynamic> catList = [];
  String? playerId;
  void fetchData() async {
    try {
      DatabaseEvent event = await userDb.child('${widget.reciverId}').once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          playerId = data['playerId'] as String;
        });
      } else {}
    } catch (error) {}
  }

  void _submitMessage() async {
    final String messageText = textEditingControllermessage.text;
    final RegExp phoneRegex = RegExp(r'\b\d{10,}\b');
    final RegExp emailRegex =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b');
    if (phoneRegex.hasMatch(messageText) || emailRegex.hasMatch(messageText)) {
      return;
    }
    if (messageText.isEmpty) {
      return;
    }

    ChatMessages chatMassege = ChatMessages(
        timeZone: "",
        roomId: widget.conversationId.toString(),
        from: widget.from.toString(),
        itemName: widget.title!,
        message: messageText,
        receiverId: widget.reciverId.toString(),
        seen: false,
        senderId: userId.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        attachment: {"image": ""},
        image: widget.image,
        playeridUser1: '$oneSiginalplayerid',
        playeridUser2: '${playerId}',
        bookingIO: "${widget.bookingId}",
        bookingStatus: "${widget.bookingStatus}",
        userImage: "");
    ChatMessages chatMassege2 = ChatMessages(
      timeZone: "",
      roomId: widget.conversationId.toString(),
      from: "${loginModel!.data!.firstName}",
      itemName: widget.title!,
      message: messageText,
      receiverId: widget.reciverId.toString(),
      seen: false,
      senderId: userId.toString(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      attachment: {"image": ""},
      image: widget.image,
      playeridUser1: '${playerId}',
      playeridUser2: '$oneSiginalplayerid',
      bookingIO: "${widget.bookingId}",
      bookingStatus: "${widget.bookingStatus}",
      userImage: "",
    );
    String bookingIdForKey = "${widget.bookingId}";
    database
        .child("$userId")
        .child("${bookingIdForKey}_${widget.reciverId}")
        .set(chatMassege.toMap());
    database
        .child("${widget.reciverId}")
        .child("${bookingIdForKey}_$userId")
        .set(chatMassege2.toMap());
    final message = ChatMessages(
        bookingStatus: "${widget.bookingStatus}",
        timeZone: "",
        roomId: widget.conversationId.toString(),
        image: widget.image,
        from: widget.from.toString(),
        message: messageText,
        itemName: widget.title!,
        receiverId: widget.reciverId.toString(),
        seen: false,
        senderId: userId.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        attachment: {
          'image': "",
        },
        playeridUser1: '$oneSiginalplayerid',
        playeridUser2: '${playerId}',
        bookingIO: bookingIdForKey,
        userImage: "");
    dbRef?.push().set(message.toMap());
    String bookingIdForSeen = widget.bookingId ?? "";
    bool isSeen = await _isMessageSeen(
        "${widget.reciverId}", "O${bookingIdForSeen}_$userId");
    String notificationMessage =
        "New message from ${loginModel!.data!.firstName}: $messageText";
    sendNotification(
         notificationMessage, widget.conversationId);
    print("jhjhbvdhs");
    print(widget.playerId);
    print(playerId);
    DateTime currentTime = DateTime.now();
    textEditingControllermessage.clear();
  }

  Future<void> sendNotification( message, conversationId) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${Config.oneSiginalApiKey}'
    };

    var bodyData = {
      "app_id": Config.oneSiginalAppid,
      "include_player_ids": [playerId],
      "headings": {"en": "New Chat Message"},
      "contents": {"en": message},
      "data": {
        "conversationId": conversationId,
        "bookingId": widget.bookingId,
        "image": widget.image,
        "senderId": userId.toString(),
        "receiverId": widget.reciverId.toString(),
        "from": loginModel!.data!.firstName,
        "playerId1": oneSiginalplayerid,
        "playerId2": playerId,
        "title": widget.title,
        "route": "inbox"
      }
    };
    var request = http.Request(
        'POST', Uri.parse('https://onesignal.com/api/v1/notifications'));
    request.headers.addAll(headers);
    request.body = json.encode(bodyData);

    try {
      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance
        .ref()
        .child("chats")
        .child("${widget.conversationId}");
    isChatOpen = true;
    fetchData();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset > 800) {
      setState(() {
        showGoToBottomButton = true;
      });
    } else {
      setState(() {
        showGoToBottomButton = false;
      });
    }
  }

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    FirebaseMessaging.onMessage.listen(null);
    isChatOpen = false;
    super.dispose();
    scrollController.dispose();
  }

  Future<bool> _isMessageSeen(String recipientId, String roomId) async {
    DatabaseReference messageRef =
        database.child(recipientId).child(roomId).child('seen');
    final DataSnapshot snapshot = await messageRef.get();
    bool isSeen = snapshot.value != null ? snapshot.value as bool : false;
    return isSeen;
  }

  bool clickOption = false;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          SizedBox(
            width: Dimensions.containerWidth,
            child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: CustomAppBars(
                title: 'Chat'.tr,
                backgroundColor: notifires.getbgcolor,
                iconColor: notifires.getwhiteblackcolor,
                titleColor: notifires.getwhiteblackcolor,
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (files != null) {
                        setState(() {
                          files = null;
                        });
                      }
                    },
                    child: Column(children: <Widget>[
                      Row(
                        children: [
                          const SizedBox(width: 18),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullScreenImage(
                                          imageUrl: widget.image)));
                            },
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                child: widget.image != null &&
                                        widget.image!.isNotEmpty
                                    ? Image.network(widget.image!,
                                        fit: BoxFit.cover)
                                    : getErrorImage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.title!,
                                    style: heading3Grey1(context)),
                                widget.from == null
                                    ? const SizedBox()
                                    : Text("${"From".tr} ${widget.from}",
                                        style: regular(context)),
                                widget.bookingId == ""
                                    ? const SizedBox()
                                    : Text(
                                        "${"booking id".tr}: ${widget.bookingId}",
                                        style: TextStyle(
                                            color: blackColor, fontSize: 12),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: themeColor.withOpacity(0.9),
                        endIndent: 10,
                        indent: 10,
                      ),
                      Expanded(
                        child: FirebaseAnimatedList(
                            sort: (DataSnapshot a, DataSnapshot b) =>
                                b.key!.compareTo(a.key!),
                            reverse: true,
                            shrinkWrap: true,
                            controller: scrollController,
                            query: dbRef!,
                            itemBuilder: (BuildContext context,
                                DataSnapshot snapshot,
                                Animation<double> animation,
                                int index) {
                              var value = snapshot.value;
                              if (value is Map<dynamic, dynamic>) {
                                Map messageList = value;
                                messageList['key'] = snapshot.key;
                                if (messageList['senderId'] !=
                                        userId.toString() &&
                                    !messageList['seen']) {
                                  dbRef!
                                      .child(snapshot.key!)
                                      .update({'seen': true});
                                  database
                                      .child("$userId")
                                      .child(
                                          "${widget.bookingId}_${widget.reciverId}")
                                      .update({'seen': true});
                                  database
                                      .child("${widget.reciverId}")
                                      .child("${widget.bookingId}_$userId")
                                      .update({'seen': true});
                                }

                                if (messageList['senderId'] ==
                                    userId.toString()) {
                                  return _buildSenderMessage(
                                      context, messageList);
                                } else {
                                  return _buildReceiverMessage(
                                      context, messageList);
                                }
                              } else {
                                log("Unexpected data format: ${value.runtimeType}");
                                return Container();
                              }
                            }),
                      ),
                      if (isUploading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: grey5.withOpacity(.5),
                                ),
                                height: 200,
                                width: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/spinner.gif",
                                      width: 40,
                                      height: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "uploading....",
                                      style: regular(context),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                      widget.bookingStatus == "Declined" ||
                              widget.bookingStatus == "Completed" ||
                              widget.bookingStatus == "Cancelled"
                          ? _buildChatDisabledUI(
                              widget.bookingStatus.toString())
                          : Align(
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 5, bottom: 10, top: 10, right: 10),
                                color: notifires.getbgcolor,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 0),
                                        child: SingleChildScrollView(
                                          child: TextField(
                                            textInputAction:
                                                TextInputAction.send,
                                            controller:
                                                textEditingControllermessage,
                                            onSubmitted: (v) {
                                              _submitMessage();
                                            },
                                            minLines: 1,
                                            maxLines: 5,
                                            cursorWidth: 1.2,
                                            style: TextStyle(
                                                height: 1,
                                                color: notifires
                                                    .getwhiteblackcolor),
                                            decoration: InputDecoration(
                                              hintText: "Message...".tr,
                                              suffixIcon: SizedBox(
                                                width: 65,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          uploadImageFromGallery(
                                                              ImageSource
                                                                  .gallery);
                                                        },
                                                        child: Icon(
                                                          Icons.image,
                                                          color: notifires
                                                              .getGrey3Whitecolor,
                                                        )),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          uploadImageFromGallery(
                                                              ImageSource
                                                                  .camera);
                                                        },
                                                        child: Icon(
                                                          Icons.camera_alt,
                                                          color: notifires
                                                              .getGrey3Whitecolor,
                                                        )),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              hintStyle: regular2(context),
                                              border: InputBorder.none,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1.4,
                                                      color: notifires
                                                          .getthemewhitecolor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1.4,
                                                      color: notifires
                                                          .getthemewhitecolor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (files != null) {
                                          sendImage(files!);
                                          return;
                                        }
                                        _submitMessage();
                                      },
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: themeColor,
                                          ),
                                          child: const Icon(
                                            Icons.send,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 10),
                    ]),
                  ),
                  if (showGoToBottomButton)
                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 90,
                        child: Center(
                          child: GestureDetector(
                            onTap: _scrollToBottom,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: getColorBasedOnActiveModuleid(),
                              ),
                              height: 40,
                              width: 40,
                              child: const Icon(
                                Icons.arrow_downward,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                  if (files != null)
                    Positioned(
                        left: 10,
                        right: 10,
                        bottom: 15,
                        child: Container(
                          decoration: BoxDecoration(
                              color: notifires.getBoxColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: getColorBasedOnActiveModuleid())),
                          height: 250,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 20,
                                right: 20,
                                top: 0,
                                bottom: 0,
                                child: Image.file(
                                  files!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: grey1.withOpacity(.7),
                                          borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          )),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                              child: Text(
                                            fileName,
                                            style: regular2(context).copyWith(
                                                color: Colors.white,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          )),
                                          const SizedBox(
                                            width: 18,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              // sendMsgFunction();
                                              if (files != null) {
                                                sendImage(files!);
                                                return;
                                              }
                                            },
                                            child: Container(
                                              height: 45,
                                              width: 45,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color:
                                                      getColorBasedOnActiveModuleid()),
                                              child: const Icon(
                                                Icons.send,
                                                color: Colors.white,
                                                size: 23,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ))),
                              Positioned(
                                  left: 10,
                                  top: 10,
                                  child: GestureDetector(
                                      onTap: () {
                                        files = null;
                                        setState(() {});
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        size: 30,
                                        color: notifires.getGrey1Whitecolor,
                                      )))
                            ],
                          ),
                        ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatDisabledUI(String status) {
    // Get status-specific details
    final Map<String, Map<String, dynamic>> statusDetails = {
      "Declined": {
        "title": "Booking Declined",
        "message": "This booking request was declined",
        "icon": Icons.cancel,
        "color": Colors.orange,
        "details":
            "The host has declined this booking request. You can no longer chat about this booking."
      },
      "Completed": {
        "title": "Booking Completed",
        "message": "This booking has been successfully completed",
        "icon": Icons.check_circle,
        "color": Colors.green,
        "details":
            "This booking is now complete. Thank you for using our service!"
      },
      "Cancelled": {
        "title": "Booking Cancelled",
        "message": "This booking was cancelled",
        "icon": Icons.cancel,
        "color": Colors.red,
        "details":
            "This booking has been cancelled. You can no longer chat about this booking."
      },
    };

    final details = statusDetails[status]!;

    return Container(
      height: 350,
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: details['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              details['icon'],
              size: 40,
              color: details['color'],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                details['title'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: notifires.getwhiteblackcolor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            textAlign: TextAlign.center,
            details['message'],
            style: TextStyle(
              fontSize: 16,
              color: notifires.getGrey3Whitecolor,
            ),
          ),
          SizedBox(height: 16),
          Divider(
            color: notifires.getGrey3Whitecolor.withOpacity(0.3),
            height: 1,
          ),
          SizedBox(height: 16),
          Text(
            details['details'],
            style: TextStyle(
              fontSize: 14,
              color: notifires.getGrey3Whitecolor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          if (status == "Completed")
            Text(
              "We hope you had a great experience!",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: details['color'],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Future<File> compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
          tempDir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 50,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null) {
        return File(result.path);
      } else {
        throw Exception('Compression failed');
      }
    } catch (e) {
      log('Compression error: $e');
      return file;
    }
  }

  String sourec = "";
  File? files;
  String fileName = "";
  Future<void> uploadImageFromGallery(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        sourec = "Camera";
      } else {
        sourec = "Gallery";
      }
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          files = File(pickedFile.path);
          String filepath = pickedFile.path;
          fileName = path.basename(filepath);
        });
      }
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "$sourec permission denied. Please go to settings and allow the $sourec.");
      }
    }
  }

  static String getFormattedTime({
    required BuildContext context,
    required String? time, // Allow time to be nullable
  }) {
    if (time == null || time.isEmpty) {
      // Handle null or empty time string
      return 'Invalid time';
    }

    try {
      // Attempt to parse the time string to an integer
      final microseconds = int.parse(time);
      final date = DateTime.fromMillisecondsSinceEpoch(microseconds);

      // Formatting time using TimeOfDay
      final formattedTime =
          TimeOfDay.fromDateTime(date).format(context).toLowerCase();

      // Getting current date for comparison
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      // Format date as "7 Jul"
      final DateFormat dateFormatter = DateFormat("d MMM");
      final formattedDate = dateFormatter.format(date);

      // If the date is today, only show the time
      if (isToday) {
        return "today $formattedTime";
      } else {
        return "$formattedDate, $formattedTime";
      }
    } catch (e) {
      // Handle parsing error

      return 'Invalid time';
    }
  }

  Future<void> sendImage(var pickedFile) async {
    if (pickedFile != null) {
      setState(() {
        isUploading = true;
        files = null;
      });
      File compressedFile = await compressImage(pickedFile);
      try {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        UploadTask uploadTask = storageRef.putFile(compressedFile);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {});
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        final message = ChatMessages(
          bookingIO: "${widget.bookingId}",
          bookingStatus: "${widget.bookingStatus}",
          userImage: "",
          timeZone: "",
          roomId: widget.conversationId.toString(),
          image: widget.image,
          from: widget.from.toString(),
          message: '',
          itemName: widget.title!,
          receiverId: widget.reciverId.toString(),
          seen: false,
          senderId: userId.toString(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          attachment: {
            'image': downloadUrl,
          },
          playeridUser1: '$oneSiginalplayerid',
          playeridUser2: '$playerId',
        );
        dbRef!.push().set(message.toMap());
        ChatMessages chatMassege = ChatMessages(
            timeZone: "",
            roomId: widget.conversationId.toString(),
            from: widget.from.toString(),
            itemName: widget.title!,
            message: "image",
            receiverId: widget.reciverId.toString(),
            seen: false,
            senderId: "$userId",
            timestamp: DateTime.now().millisecondsSinceEpoch,
            attachment: {"image": ""},
            image: widget.image,
            playeridUser1: '$oneSiginalplayerid',
            playeridUser2: '$playerId',
            bookingIO: "${widget.bookingId}",
            bookingStatus: "${widget.bookingStatus}",
            userImage: "");
        ChatMessages chatMassege2 = ChatMessages(
            timeZone: "",
            roomId: widget.conversationId.toString(),
            from: "${loginModel!.data!.firstName}",
            itemName: widget.title!,
            message: "image",
            receiverId: widget.reciverId.toString(),
            seen: false,
            senderId: "$userId",
            timestamp: DateTime.now().millisecondsSinceEpoch,
            attachment: {"image": ""},
            image: widget.image,
            playeridUser1: '$playerId',
            playeridUser2: '$oneSiginalplayerid',
            bookingIO: "${widget.bookingId}",
            bookingStatus: "${widget.bookingStatus}",
            userImage: "");
        database
            .child("$userId")
            .child("${widget.bookingId}_${widget.reciverId}")
            .set(chatMassege.toMap());

        database
            .child("${widget.reciverId}")
            .child("${widget.bookingId}_$userId")
            .set(chatMassege2.toMap());

        log('Upload successful, URL: $downloadUrl');
        setState(() {
          isUploading = false;
        });
      } catch (e) {
        log('Upload failed: $e');
        setState(() {
          isUploading = false;
        });
      }
    } else {
      log('No image selected.');
    }
  }

  Widget _buildSenderMessage(BuildContext context, Map messageList) {
    return Align(
        alignment: Alignment.topRight,
        child: messageList['attachment'] == null ||
                messageList['attachment']['image'] == null ||
                messageList['attachment']['image'].isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 1.8),
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: notifires.getBoxColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12)),
                          border: Border.all(
                              width: 1, color: notifires.getBoxColor)),
                      child: Text(
                        messageList['message'] ?? "",
                        style: regular2(context),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          getFormattedTime(
                              context: context,
                              time: messageList["timestamp"].toString()),
                          style: regular(context).copyWith(fontSize: 11),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.done_all_outlined,
                          size: 15,
                          color: messageList['seen'] == true
                              ? Colors.green
                              : grey3,
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(right: 10, top: 10),
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                imageUrl: messageList['attachment']['image'],
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            // child:
                            child: Image.network(
                              messageList['attachment']['image'],
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // Image is fully loaded
                                } else {
                                  return SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: shimmerContainer());
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              getFormattedTime(
                                context: context,
                                time: "${messageList['timestamp']}",
                              ),
                              style: regular(context).copyWith(fontSize: 11),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.done_all_outlined,
                              size: 15,
                              color: messageList['seen'] == true
                                  ? appgreen
                                  : grey3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildReceiverMessage(BuildContext context, Map messageList) {
    return Align(
        alignment: Alignment.topLeft,
        child: messageList['attachment'] == null ||
                messageList['attachment']['image'] == null ||
                messageList['attachment']['image'].isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 1.8),
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          border: Border.all(
                            width: 1,
                            color: getColorBasedOnActiveModuleid(),
                          ),
                          color: getColorBasedOnActiveModuleid()),
                      child: Text(
                        messageList['message'] ?? "",
                        style: regular2(context).copyWith(color: Colors.white),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: Text(
                      getFormattedTime(
                          context: context,
                          time: messageList["timestamp"].toString()),
                      style: regular(context),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                imageUrl: messageList['attachment']['image'],
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              messageList['attachment']['image'],
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // Image is fully loaded
                                } else {
                                  return SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: shimmerContainer());
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getFormattedTime(
                                context: context,
                                time: "${messageList['timestamp']}",
                              ),
                              style: regular(context).copyWith(fontSize: 11),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: notifires.getbgcolor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 65,
        leading: BackButton(
          color: notifires.getGrey2Whitecolor,
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
