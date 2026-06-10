import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/model/conversation_model.dart';
import 'package:carvy/services/socket_service.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../utils/common_widget.dart';
import '../../work_space.dart';
import 'conversation_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<ConversationModel> _conversations = [];
  bool _loading = true;
  StreamSubscription<dynamic>? _socketSubscription;
  StreamSubscription<dynamic>? _inboxUpdateSubscription;

  String _firstValid(List<String?> values) {
    for (final v in values) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
    }
    return '';
  }

  bool _isCompositeId(String id) {
    final parts = id.split('_');
    return parts.length == 3 && parts.every((p) => p.trim().isNotEmpty);
  }

  bool _looksLikeMongoId(String id) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id.trim());
  }

  String _extractMongoId(String raw) {
    final match = RegExp(r'([a-fA-F0-9]{24})').firstMatch(raw);
    return match?.group(1) ?? '';
  }

  String _resolveHistoryId(ConversationModel conv) {
    final candidate = conv.conversationId.trim();
    if (_looksLikeMongoId(candidate)) return candidate;
    final extracted = _extractMongoId(candidate);
    if (extracted.isNotEmpty) return extracted;
    return candidate;
  }

  String _resolveConversationId(ConversationModel conv) {
    final original = conv.conversationId.trim();
    if (_isCompositeId(original)) return original;

    final current = userId.toString().trim();
    final bookingId = (conv.bookingId ?? '').trim();
    final peerId = (conv.recipientId ?? '').trim();
    final buyerId = _firstValid([conv.buyerId, current]);
    final sellerId = _firstValid([conv.sellerId, peerId]);

    if (bookingId.isNotEmpty && buyerId.isNotEmpty && sellerId.isNotEmpty) {
      return '${buyerId}_${bookingId}_${sellerId}';
    }
    if (bookingId.isNotEmpty && current.isNotEmpty && peerId.isNotEmpty) {
      return '${current}_${bookingId}_${peerId}';
    }
    return original;
  }

  Bookings _buildBookingForConversation(ConversationModel conv) {
    final current = userId.toString().trim();
    final peerId = (conv.recipientId ?? '').trim();
    final buyerId = _firstValid([conv.buyerId, current]);
    final sellerId = _firstValid([conv.sellerId, peerId]);
    final isCurrentBuyer = buyerId.isNotEmpty && buyerId == current;
    return Bookings(
      id: conv.bookingId,
      userid: buyerId.isNotEmpty ? buyerId : current,
      hostId: sellerId.isNotEmpty ? sellerId : peerId,
      hostName: isCurrentBuyer ? conv.fromName : null,
      userName: isCurrentBuyer ? null : conv.fromName,
      propTitle: conv.itemName,
      itemData: '',
    );
  }

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

  Future<void> _fetchInbox() async {
    if (token.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() => _loading = true);
    try {
      final res = await httpGetAdmin(Config.chatInboxPath, {});
      print('RAW RESPONSE: $res');
      // ignore: avoid_print
      print('📦 [API INBOX] Réponse brute du serveur : $res');
      final dynamic rawData = (res is Map) ? res['data'] : null;
      final int conversationCount = rawData is List
          ? rawData.length
          : rawData is Map && rawData['conversations'] is List
              ? (rawData['conversations'] as List).length
              : 0;
      // ignore: avoid_print
      print('📦 [API INBOX] Nombre de conversations trouvées : $conversationCount');
      final raw = _extractConversationsList(res);
      final uid = userId.toString();
      final parsed = <ConversationModel>[];
      for (final e in raw) {
        if (e is Map) {
          parsed.add(ConversationModel.fromJson(
            Map<String, dynamic>.from(e),
            uid,
          ));
        }
      }
      parsed.sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
      if (mounted) {
        final totalUnread = parsed.fold<int>(
          0,
          (sum, c) => sum + (c.unreadCount > 0 ? c.unreadCount : 0),
        );
        setState(() {
          _conversations = parsed;
          _loading = false;
        });
        generalController.totalUnreadCount.value = totalUnread;
      }
    } catch (e, st) {
      log('inbox fetch: $e', stackTrace: st);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> fetchConversations() async {
    await _fetchInbox();
  }

  List<dynamic> _extractConversationsList(dynamic res) {
    if (res is! Map) return [];
    if (res['error'] != null) return [];
    final d = res['data'];
    if (d is List) return d;
    if (d is Map) {
      if (d['conversations'] is List) return d['conversations'] as List;
      if (d['items'] is List) return d['items'] as List;
      if (d['inbox'] is List) return d['inbox'] as List;
    }
    if (res['conversations'] is List) return res['conversations'] as List;
    return [];
  }

  void _onSocketMessage(dynamic data) {
    if (!mounted) return;
    if (data is! Map) {
      _fetchInbox();
      return;
    }
    final map = Map<String, dynamic>.from(data);
    final rawCid = map['conversationId'] ??
        map['conversation_id'] ??
        map['roomId'] ??
        map['room_id'] ??
        map['id'];
    if (rawCid == null) {
      _fetchInbox();
      return;
    }
    final cid = rawCid.toString();
    final last = (map['text'] ??
            map['message'] ??
            map['lastMessage'] ??
            map['last_message'] ??
            '')
        .toString();
    final ts = _parseTsMs(map['timestamp'] ?? map['createdAt'] ?? map['created_at']);
    final senderId =
        (map['senderId'] ?? map['sender_id'] ?? '').toString();
    final isUnread =
        senderId.isNotEmpty && senderId != userId.toString();

    final idx = _conversations.indexWhere((c) => c.conversationId == cid);
    if (idx >= 0) {
      final c = _conversations[idx];
      setState(() {
        _conversations.removeAt(idx);
        _conversations.insert(
          0,
          c.copyWith(
            lastMessage: last.isNotEmpty ? last : c.lastMessage,
            timestampMs: ts,
            // Un unread true/bool existait déjà : on transforme en compteur.
            // Quand le message vient de l'autre participant, on incrémente.
            unreadCount: isUnread ? (c.unreadCount + 1) : c.unreadCount,
          ),
        );

        // Badge global : mise à jour instantanée.
        generalController.totalUnreadCount.value = _conversations.fold<int>(
          0,
          (sum, c) => sum + (c.unreadCount > 0 ? c.unreadCount : 0),
        );
      });
    } else {
      _fetchInbox();
    }
  }

  int _parseTsMs(dynamic t) {
    if (t == null) return DateTime.now().millisecondsSinceEpoch;
    if (t is int) return _normEpoch(t);
    if (t is num) return _normEpoch(t.toInt());
    final s = t.toString();
    final n = int.tryParse(s);
    if (n != null) return _normEpoch(n);
    try {
      return DateTime.parse(s).millisecondsSinceEpoch;
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  int _normEpoch(int v) {
    if (v < 10000000000) return v * 1000;
    return v;
  }

  @override
  void initState() {
    super.initState();
    isInboxOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (token.isNotEmpty) {
        SocketService.instance.connect();
      }
    });
    fetchConversations();
    _socketSubscription =
        SocketService.instance.newMessageStream.listen(_onSocketMessage);
    _inboxUpdateSubscription = SocketService.instance.onUpdateInbox((data) {
      // ignore: avoid_print
      print('🔄 SOCKET : Rafraîchissement de la liste des discussions');
      fetchConversations();
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _inboxUpdateSubscription?.cancel();
    super.dispose();
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
                      : _loading
                          ? chatInboxScreenShimmer()
                          : _conversations.isEmpty
                              ? Center(
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
                                )
                              : RefreshIndicator(
                                  color: getColorBasedOnActiveModuleid(),
                                  onRefresh: fetchConversations,
                                  child: ListView.builder(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    itemCount: _conversations.length,
                                    itemBuilder: (context, index) {
                                      final conv = _conversations[index];
                                      final timestampStr =
                                          conv.timestampMs.toString();
                                      final isUnread = conv.unreadCount > 0;

                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        child: Material(
                                          color: notifires.getBoxColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            onTap: () async {
                                              final currentUserId =
                                                  userId.toString().trim();
                                              final participants = conv.participants;
                                              final buyerFromParticipants =
                                                  participants.isNotEmpty
                                                      ? participants[0]
                                                      : '';
                                              final sellerFromParticipants =
                                                  participants.length > 1
                                                      ? participants[1]
                                                      : '';
                                              // On récupère l'ID de l'autre personne (le vendeur)
                                              String actualSellerId = '';
                                              if (participants.length >= 2) {
                                                actualSellerId = participants.firstWhere(
                                                  (id) => id != currentUserId,
                                                  orElse: () => '',
                                                );
                                              }

                                              // Si on ne le trouve pas, on utilise l'ID statique du log (Agence Carvy Test)
                                              if (actualSellerId.isEmpty) {
                                                actualSellerId = '69511e84eee94e05f0cd312e';
                                              }

                                              if (mounted) {
                                                setState(() {
                                                  _conversations[index] =
                                                      conv.copyWith(
                                                    unreadCount: 0,
                                                    unread: false,
                                                  );
                                                  generalController.totalUnreadCount
                                                      .value = _conversations.fold<int>(
                                                    0,
                                                    (sum, c) =>
                                                        sum + (c.unreadCount > 0 ? c.unreadCount : 0),
                                                  );
                                                });
                                              }

                                              await Get.to(() =>
                                                  ConversationScreen(
                                                    booking:
                                                        _buildBookingForConversation(
                                                            conv),
                                                    mongoId: conv.mongoId,
                                                    bookingId: conv.bookingId,
                                                    bookingStatus:
                                                        conv.bookingStatus,
                                                    from: conv.fromName,
                                                    title: conv.itemName,
                                                    image: conv.imageUrl
                                                            .isNotEmpty
                                                        ? conv.imageUrl
                                                        : null,
                                                    buyerId: currentUserId,
                                                    sellerId: actualSellerId,
                                                    city: conv.city,
                                                    senderId:
                                                        currentUserId,
                                                    reciverId: (() {
                                                      final r = (conv.recipientId ?? '').trim();
                                                      return r.toLowerCase() == 'null' ? '' : r;
                                                    })(),
                                                    playerId: conv.playerId,
                                                  ));
                                              if (mounted) {
                                                await fetchConversations();
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: 56,
                                                        height: 56,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: notifires
                                                              .getbgcolor,
                                                        ),
                                                        child: conv.imageUrl
                                                                .isEmpty
                                                            ? Icon(
                                                                Icons.person,
                                                                size: 32,
                                                                color: notifires
                                                                    .getGrey3Whitecolor)
                                                            : ClipOval(
                                                                child: Image
                                                                    .network(
                                                                  conv.imageUrl,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Icon(
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            32,
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
                                                            decoration:
                                                                BoxDecoration(
                                                              color: appgreen,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
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
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    conv.vehicleTitle ??
                                                                        'Véhicule',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 2),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          size:
                                                                              12,
                                                                          color:
                                                                              Colors.grey),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        conv.city ??
                                                                            'Maroc',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey[600],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              getFormattedTime(
                                                                  context:
                                                                      context,
                                                                  time:
                                                                      timestampStr),
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
                                                          conv.lastMessage,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: isUnread
                                                                ? Colors.black
                                                                : Colors.grey,
                                                            fontWeight:
                                                                isUnread
                                                                    ? FontWeight.bold
                                                                    : FontWeight.normal,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "${"From".tr}: ",
                                                              style:
                                                                  TextStyle(
                                                                fontSize: 12,
                                                                color: notifires
                                                                    .getGrey3Whitecolor,
                                                              ),
                                                            ),
                                                            Text(
                                                              conv.fromName,
                                                              style:
                                                                  TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: notifires
                                                                    .getGrey3Whitecolor,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            if (conv
                                                                .bookingStatus
                                                                .isNotEmpty)
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: conv.bookingStatus ==
                                                                              "Confirmed" ||
                                                                          conv.bookingStatus ==
                                                                              "Completed"
                                                                      ? Colors
                                                                          .green
                                                                          .withOpacity(
                                                                              0.2)
                                                                      : conv.bookingStatus ==
                                                                              "Pending"
                                                                          ? Colors.orange.withOpacity(
                                                                              0.2)
                                                                          : conv.bookingStatus == "Declined" || conv.bookingStatus == "Cancelled"
                                                                              ? Colors.red.withOpacity(0.2)
                                                                              : Colors.grey.withOpacity(0.2),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          12),
                                                                ),
                                                                child: Text(
                                                                  conv
                                                                      .bookingStatus,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: conv.bookingStatus ==
                                                                                "Confirmed" ||
                                                                            conv.bookingStatus ==
                                                                                "Completed"
                                                                        ? Colors
                                                                            .green
                                                                        : conv.bookingStatus ==
                                                                                "Pending"
                                                                            ? Colors.orange
                                                                            : conv.bookingStatus == "Declined" || conv.bookingStatus == "Cancelled"
                                                                                ? Colors.red
                                                                                : Colors.grey,
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
                                  ),
                                ),
            ),
    );
  }
}
