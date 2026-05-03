import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:audioplayers/audioplayers.dart';
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
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/chat_message_payload.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/model/conversation_model.dart';
import 'package:carvy/services/socket_service.dart';
import '../../controller/global_scope_controller.dart';
import '../../utils/theme_style.dart';
import '../../work_space.dart';
import 'package:path/path.dart' as path;

class ConversationScreen extends StatefulWidget {
  final String? bookingId;
  final String? title;
  final String? vehicleTitle;
  final String? conversationId;
  final String? historyId;
  final String? socketRoomId;
  final String? buyerId;
  final String? sellerId;
  final String? senderId;
  final String? reciverId;
  final dynamic image;
  final String? from;
  final String? playerId;
  final String? bookingStatus;
  final String? city;
  final Bookings? booking;
  /// ID Mongo conversation / historique (diagnostic temps réel).
  final String? mongoId;
  const ConversationScreen({
    super.key,
    this.bookingId,
    this.title,
    this.vehicleTitle,
    this.image,
    this.conversationId,
    this.historyId,
    this.mongoId,
    this.socketRoomId,
    this.buyerId,
    this.sellerId,
    this.senderId,
    this.reciverId,
    this.from,
    this.playerId,
    this.bookingStatus,
    this.city,
    this.booking,
  });
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  GlobalScopeController globalScopeController = Get.find();
  TextEditingController textEditingControllermessage = TextEditingController();
  TextEditingController get _messageController => textEditingControllermessage;
  String roomId = "";
  ScrollController scrollController = ScrollController();
  bool isUploading = false;
  bool isSending = false;
  bool showGoToBottomButton = false;
  DateTime? lastNotificationTime;
  bool isOff = false;
  bool isCompleted = false;
  String bookingStatus = "";
  List<dynamic> catList = [];

  List<ChatMessagePayload> _messages = [];
  /// Dernier identifiant utilisé pour `GET /chat/history/...` (Mongo ou bookingId).
  String? _activeRestHistoryId;
  bool _loadingHistory = true;
  bool _isMarkedAsRead = false;
  StreamSubscription<dynamic>? _socketSubscription;
  Map<String, dynamic>? _bookingContext;
  String _effectiveSocketRoomId = '';
  final AudioPlayer _notificationPlayer = AudioPlayer();

  Future<void> _markConversationAsReadOnce() async {
    if (_isMarkedAsRead) return;
    final id =
        (widget.mongoId ?? _activeRestHistoryId ?? widget.historyId ?? '')
            .trim();
    if (id.isEmpty) return;
    _isMarkedAsRead = true;

    try {
      // Backend : PATCH /api/chat/read/:conversationId
      await httpPatch('chat/read/${Uri.encodeComponent(id)}');
    } catch (_) {
      // Best-effort : on ne bloque pas l'écran si la requête échoue.
    }
  }

  Future<void> _playIncomingMessageSound() async {
    debugPrint('🔊 Tentative de lecture : assets/sounds/notification.mp3');
    try {
      await _notificationPlayer.setVolume(1.0);
      await _notificationPlayer.play(AssetSource('sounds/notification.mp3'));
      debugPrint('✅ [SOUND] Lecture lancée avec succès');
    } catch (e, st) {
      // Rouge console (ANSI) pour repérage rapide dans adb / terminal
      debugPrint('\x1B[31m[SOUND ERROR] $e\x1B[0m');
      log('[SOUND] erreur lecture', error: e, stackTrace: st);
    }
  }


  String get _historyId {
    final explicit = (widget.historyId ?? '').trim();
    if (explicit.isNotEmpty) return _resolveMongoHistoryId(explicit);
    final fallback = (widget.conversationId ?? '').trim();
    return _resolveMongoHistoryId(fallback);
  }

  String get _socketRoomId {
    if (_effectiveSocketRoomId.trim().isNotEmpty) {
      return _effectiveSocketRoomId.trim();
    }
    final explicit = (widget.socketRoomId ?? '').trim();
    if (explicit.isNotEmpty) return explicit;
    final fallback = (widget.conversationId ?? '').trim();
    return fallback;
  }

  bool _looksLikeMongoId(String value) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
  }

  String _extractMongoId(String value) {
    final match = RegExp(r'([a-fA-F0-9]{24})').firstMatch(value);
    return match?.group(1) ?? '';
  }

  String _resolveMongoHistoryId(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    if (_looksLikeMongoId(v)) return v;
    final extracted = _extractMongoId(v);
    if (extracted.isNotEmpty) return extracted;
    // Fallback sécurité: on renvoie brut si aucun ObjectId n'est détecté.
    return v;
  }

  /// Même logique que [InboxScreen._extractConversationsList] pour GET /chat/inbox.
  List<dynamic> _extractInboxConversationsList(dynamic res) {
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

  /// Résout l’`_id` Mongo de la **conversation** (comme l’inbox) à partir du booking.
  Future<String?> _mongoFromInboxByBookingId(String bookingId) async {
    final bid = bookingId.trim();
    if (bid.isEmpty || token.isEmpty) return null;
    try {
      debugPrint(
          '🔎 [CHAT_INBOX_LOOKUP] GET ${Config.chatInboxPath} — recherche bookingId=$bid');
      final res = await httpGetAdmin(Config.chatInboxPath, {});
      final raw = _extractInboxConversationsList(res);
      final uid = userId.toString();
      for (final e in raw) {
        if (e is! Map) continue;
        final conv = ConversationModel.fromJson(
          Map<String, dynamic>.from(e),
          uid,
        );
        if ((conv.bookingId ?? '').trim() != bid) continue;
        final mid = (conv.mongoId ?? '').trim();
        if (_looksLikeMongoId(mid)) return mid;
        final cid = conv.conversationId.trim();
        if (_looksLikeMongoId(cid)) return cid;
        final extracted =
            RegExp(r'([a-fA-F0-9]{24})').firstMatch(cid)?.group(1) ?? '';
        if (_looksLikeMongoId(extracted)) return extracted;
      }
      debugPrint(
          '⚠️ [CHAT_INBOX_LOOKUP] Aucune conversation inbox pour bookingId=$bid');
    } catch (e, st) {
      log('inbox by booking', error: e, stackTrace: st);
    }
    return null;
  }

  /// Identifiant Mongo du **document conversation** pour `GET .../chat/history/:id`
  /// (jamais l’ObjectId « réservation » seul sans résolution).
  Future<String?> _resolveConversationMongoForHistory() async {
    final m = (widget.mongoId ?? '').trim();
    if (_looksLikeMongoId(m)) {
      debugPrint('📜 [CHAT_REST] Mongo conversation = widget.mongoId → $m');
      return m;
    }

    final bid = (widget.bookingId ?? widget.booking?.id ?? '').trim();
    if (bid.isNotEmpty) {
      final inboxMongo = await _mongoFromInboxByBookingId(bid);
      if (inboxMongo != null && _looksLikeMongoId(inboxMongo)) {
        debugPrint(
            '📜 [CHAT_REST] Mongo conversation = inbox (bookingId=$bid) → $inboxMongo');
        return inboxMongo;
      }
      final apiMongo = await _tryResolveConversationMongoFromBooking(bid);
      if (apiMongo != null && _looksLikeMongoId(apiMongo)) {
        debugPrint(
            '📜 [CHAT_REST] Mongo conversation = API conversation-for-booking → $apiMongo');
        return apiMongo;
      }
    }

    final h = (widget.historyId ?? '').trim();
    if (h.isNotEmpty && !h.contains('_') && _looksLikeMongoId(h)) {
      debugPrint(
          '📜 [CHAT_REST] Mongo conversation = widget.historyId (fallback) → $h');
      return h;
    }

    debugPrint(
        '❌ [CHAT_REST] Impossible de résoudre un Mongo **conversation** pour /chat/history');
    return null;
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      final s = (v ?? '').toString().trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null' && s.toLowerCase() != 'unknown') {
        return s;
      }
    }
    return '';
  }

  String _vehicleTitleFromBooking(Map<String, dynamic> booking) {
    final title = _firstNonEmpty([
      booking['itemTitle'],
      booking['item_title'],
      booking['propTitle'],
      booking['title'],
    ]);
    if (title.isNotEmpty) return title;

    dynamic itemData = booking['itemData'] ?? booking['item_data'];
    try {
      if (itemData is String && itemData.trim().isNotEmpty) {
        itemData = jsonDecode(itemData);
      }
      if (itemData is List && itemData.isNotEmpty) {
        final first = itemData.first;
        if (first is Map) {
          final data = Map<String, dynamic>.from(first);
          final make = _firstNonEmpty([
            data['make_type'],
            data['make'],
          ]);
          final model = _firstNonEmpty([
            data['model'],
            data['model_type'],
          ]);
          final combined = [make, model].where((e) => e.isNotEmpty).join(' ');
          if (combined.isNotEmpty) return combined;
        }
      } else if (itemData is Map) {
        final data = Map<String, dynamic>.from(itemData);
        final make = _firstNonEmpty([data['make_type'], data['make']]);
        final model = _firstNonEmpty([data['model'], data['model_type']]);
        final combined = [make, model].where((e) => e.isNotEmpty).join(' ');
        if (combined.isNotEmpty) return combined;
      }
    } catch (_) {}
    return '';
  }

  String _vehicleTitleFromBookingObject(Bookings booking) {
    final rawTitle = _firstNonEmpty([booking.propTitle]);
    if (rawTitle.isNotEmpty && rawTitle.toLowerCase() != 'vehicule sans titre') {
      return rawTitle;
    }
    dynamic itemData = booking.itemData;
    try {
      if (itemData is String && itemData.trim().isNotEmpty) {
        itemData = jsonDecode(itemData);
      }
      if (itemData is List && itemData.isNotEmpty) {
        final first = itemData.first;
        if (first is Map) {
          final data = Map<String, dynamic>.from(first);
          final make = _firstNonEmpty([data['make_type'], data['make']]);
          final model = _firstNonEmpty([data['model'], data['model_type']]);
          final combined = [make, model].where((e) => e.isNotEmpty).join(' ');
          if (combined.isNotEmpty) return combined;
        }
      }
    } catch (_) {}
    if (rawTitle.isNotEmpty) return rawTitle;
    return '';
  }

  String _displayVehicleTitle() {
    final fromVehicleTitle = _firstNonEmpty([widget.vehicleTitle]);
    if (fromVehicleTitle.isNotEmpty) return fromVehicleTitle;
    if (widget.booking != null) {
      final titleFromObj = _vehicleTitleFromBookingObject(widget.booking!);
      if (titleFromObj.isNotEmpty) return titleFromObj;
    }
    final fromBooking =
        _bookingContext == null ? '' : _vehicleTitleFromBooking(_bookingContext!);
    if (fromBooking.isNotEmpty) return fromBooking;
    final fromWidget = _firstNonEmpty([widget.title]);
    if (fromWidget.isNotEmpty) return fromWidget;
    return 'Vehicule sans titre';
  }

  String _displayFromSubtitle() {
    final currentUserId = userId.toString();
    if (widget.booking != null) {
      final isClient = (widget.booking!.userid ?? '').toString() == currentUserId;
      final hostName = _firstNonEmpty([
        widget.booking!.hostName,
        'Agence Carvy Test',
      ]);
      final clientName = _firstNonEmpty([
        widget.booking!.userName,
        widget.from,
        'Client',
      ]);
      final contactName = isClient ? hostName : clientName;
      return '${"From".tr}: $contactName';
    }

    final booking = _bookingContext;
    if (booking == null) {
      final fallback = _firstNonEmpty([widget.from, 'Agence Carvy Test']);
      return '${"From".tr}: $fallback';
    }
    final bookingUserId = _firstNonEmpty([
      booking['userid'],
      booking['user_id'],
      booking['userId'],
    ]);
    final hostName = _firstNonEmpty([
      booking['hostName'],
      booking['host_name'],
      'Agence Carvy Test',
    ]);
    final buyerName = _firstNonEmpty([
      booking['userName'],
      booking['user_name'],
      widget.from,
      'Client',
    ]);
    final contactName =
        (bookingUserId.isNotEmpty && bookingUserId == currentUserId)
            ? hostName
            : buyerName;
    return '${"From".tr}: $contactName';
  }

  bool _messageBelongsToCurrentConversation(ChatMessagePayload message) {
    final incomingCid = (message.conversationId ?? '').trim();
    if (incomingCid.isEmpty) return false;

    final socketRoomId = _socketRoomId.trim();
    final conversationId = (widget.conversationId ?? '').trim();
    final historyId = _historyId.trim();
    final restLayer = (_activeRestHistoryId ?? '').trim();

    // Accepte les différents identifiants utilisés selon les écrans/backend.
    return incomingCid == socketRoomId ||
        incomingCid == conversationId ||
        incomingCid == historyId ||
        (restLayer.isNotEmpty && incomingCid == restLayer);
  }

  Future<void> _fetchBookingContext() async {
    final bid = widget.bookingId?.trim() ?? '';
    if (bid.isEmpty) return;
    const types = ['upcoming', 'ongoing', 'previous', 'cancelled'];
    for (final type in types) {
      try {
        final res = await httpPost(Config.upcommingRecord, {
          'type': type,
          'offset': '0',
        });
        if (res is! Map || res['data'] is! Map) continue;
        final data = Map<String, dynamic>.from(res['data']);
        final list = data['Bookings'];
        if (list is! List) continue;
        for (final item in list) {
          if (item is! Map) continue;
          final booking = Map<String, dynamic>.from(item);
          final id = _firstNonEmpty([booking['_id'], booking['id']]);
          if (id == bid) {
            if (mounted) {
              setState(() {
                _bookingContext = booking;
              });
            }
            return;
          }
        }
      } catch (_) {
        // Best-effort uniquement: l'UI garde les fallback si la récupération échoue.
      }
    }
  }

  Future<String?> _tryResolveConversationMongoFromBooking(
      String bookingId) async {
    try {
      debugPrint(
          '🔎 [CHAT_RESOLVE] GET ${Config.chatConversationForBookingPath(bookingId)}');
      final res = await httpGetAdmin(
          Config.chatConversationForBookingPath(bookingId), {});
      if (res is! Map || res['error'] != null) return null;
      final dynamic d = res['data'];
      if (d is Map) {
        for (final key in ['mongoId', '_id', 'conversationMongoId', 'id']) {
          final v = d[key]?.toString().trim() ?? '';
          if (v.isNotEmpty && _looksLikeMongoId(v)) return v;
        }
        final conv = d['conversation'];
        if (conv is Map) {
          final v = conv['_id']?.toString().trim() ?? '';
          if (v.isNotEmpty && _looksLikeMongoId(v)) return v;
        }
      }
    } catch (e, st) {
      debugPrint('⚠️ [CHAT_RESOLVE] échec ou endpoint absent: $e');
      log('chat resolve by booking', error: e, stackTrace: st);
    }
    return null;
  }

  Future<void> _fetchChatHistory(String historyRestId) async {
    final historyId = historyRestId.trim();
    if (historyId.isEmpty) {
      return;
    }
    debugPrint('📡 [CHAT_REST] GET /api/chat/history/$historyId');
    debugPrint('🔗 [CHAT_REST] URL admin : ${Config.chatHistoryPath(historyId)}');
    try {
      final res = await httpGetAdmin(Config.chatHistoryPath(historyId), {});
      debugPrint('🧐 [CHAT_REST] Réponse brute (statut) : '
          '${res is Map ? (res['statusCode'] ?? res['status'] ?? 'OK map') : res.runtimeType}');
      final rawList = _extractMessagesList(res);
      final parsed = <ChatMessagePayload>[];
      for (final e in rawList) {
        if (e is Map) {
          parsed.add(ChatMessagePayload.fromJson(
              Map<String, dynamic>.from(e)));
        }
      }
      parsed.sort((a, b) => (b.timestampMs ?? 0).compareTo(a.timestampMs ?? 0));
      if (mounted) {
        setState(() {
          _messages = parsed;
        });
      }
    } catch (e, st) {
      log('chat history: $e', stackTrace: st);
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _loadingHistory = true);
    final String socketLabel = _socketRoomId;
    try {
      debugPrint('🛋️ [CHAT_SOCKET] Room Socket / composite = "$socketLabel"');

      final String? mongo = await _resolveConversationMongoForHistory();
      debugPrint(
          '📜 [CHAT_REST]   ID Mongo **conversation** pour GET .../chat/history = "${mongo ?? "(aucun)"}"');

      if (mongo == null || !_looksLikeMongoId(mongo)) {
        debugPrint(
            '❌ [CHAT_REST] Pas d’appel /chat/history sans document conversation Mongo valide');
        return;
      }

      _activeRestHistoryId = mongo;
      await _fetchChatHistory(mongo);
    } catch (e, st) {
      log('_loadMessages: $e', stackTrace: st);
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  List<dynamic> _extractMessagesList(dynamic res) {
    if (res is! Map) return [];
    if (res['error'] != null) return [];
    final d = res['data'];
    if (d is List) return d;
    if (d is Map) {
      if (d['messages'] is List) return d['messages'] as List;
      if (d['history'] is List) return d['history'] as List;
      if (d['items'] is List) return d['items'] as List;
    }
    if (res['messages'] is List) return res['messages'] as List;
    return [];
  }

  void _submitMessage() async {
    final String messageText = textEditingControllermessage.text.trim();
    // Validation coordonnees desactivee temporairement pour debug envoi.
    if (messageText.isEmpty) {
      return;
    }

    // Reconstruction agressive du CID si vide
    String cid = (_socketRoomId).trim();
    final socketRoomId = cid;
    // ignore: avoid_print
    print('📤 [DEBUG SEND] CID final: "$socketRoomId" | Text: "$messageText"');
    if (cid.isEmpty) {
      // On tente de reconstruire l'ID composite à la volée
      String? bId = (widget.bookingId ?? widget.booking?.id)?.trim();
      final buyId = widget.buyerId?.trim();
      final selId = widget.sellerId?.trim();

      // Fallback de secours : essayer d'extraire bookingId depuis historyId composite.
      if (bId == null || bId.isEmpty) {
        final historyRaw = (widget.historyId ?? '').trim();
        final historyParts = historyRaw.split('_');
        if (historyParts.length >= 3 && historyParts[1].trim().isNotEmpty) {
          bId = historyParts[1].trim();
        } else {
          bId = 'fallback_booking';
        }
      }

      if (bId != null &&
          bId.isNotEmpty &&
          buyId != null &&
          buyId.isNotEmpty &&
          selId != null &&
          selId.isNotEmpty) {
        cid = '${buyId}_${bId}_${selId}';
        // On met à jour la variable de classe pour les prochains messages
        _effectiveSocketRoomId = cid;
        // ignore: avoid_print
        print('🛠️ [FIX] CID reconstruit dynamiquement : "$cid"');
      }
    }
    if (cid.isEmpty) {
      // ignore: avoid_print
      print('❌ [CRITICAL] Impossible de construire le CID. Tous les IDs sont NULL !');
      final emergencyBuyer = _firstNonEmpty([
        widget.buyerId,
        widget.senderId,
        widget.booking?.userid,
        userId.toString(),
      ]);
      final emergencyBooking = _firstNonEmpty([
        widget.bookingId,
        widget.booking?.id,
        (widget.historyId ?? '').split('_').length >= 2
            ? (widget.historyId ?? '').split('_')[1]
            : '',
        'fallback_booking',
      ]);
      final emergencySeller = _firstNonEmpty([
        widget.sellerId,
        widget.reciverId,
        widget.booking?.hostId,
        'fallback_seller',
      ]);
      cid = '${emergencyBuyer}_${emergencyBooking}_${emergencySeller}';
      _effectiveSocketRoomId = cid;
      // ignore: avoid_print
      print('🧯 [EMERGENCY CID] CID forcé : "$cid"');
    }

    setState(() {
      isSending = true;
    });
    try {
      // ignore: avoid_print
      print("📤 [UI] Tentative d'envoi du message...");
      // ignore: avoid_print
      print('📡 [UI] État de la socket : ${SocketService.instance.isConnected}');
      // ignore: avoid_print
      print('🚀 SOCKET EMIT sur room : $cid');
      // ignore: avoid_print
      print('✈️ [SOCKET EMIT] Envoi sur la room : $_socketRoomId');
      SocketService.instance.sendMessage(cid, messageText);
      // ignore: avoid_print
      print('✅ [UI] Appel sendMessage effectué.');
    } finally {
      _messageController.clear();
      if (mounted) {
        setState(() => isSending = false);
      } else {
        isSending = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isChatOpen = true;
    _fetchBookingContext();
    _effectiveSocketRoomId = _socketRoomId;

    // Marquer comme lu une seule fois dès l'affichage de la page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markConversationAsReadOnce();
    });
    if (_effectiveSocketRoomId.isEmpty) {
      final buyerId =
          (widget.booking?.userid ?? widget.senderId ?? userId.toString())
              .toString()
              .trim();
      final bookingId =
          (widget.bookingId ?? widget.booking?.id ?? '').toString().trim();
      final sellerId =
          (widget.booking?.hostId ?? widget.reciverId ?? '').toString().trim();
      if (buyerId.isNotEmpty && bookingId.isNotEmpty && sellerId.isNotEmpty) {
        _effectiveSocketRoomId = '${buyerId}_${bookingId}_${sellerId}';
        // ignore: avoid_print
        print('🛠️ CID RECONSTRUIT : $_effectiveSocketRoomId');
      }
    }

    _socketSubscription = SocketService.instance.onNewMessage((data) {
      // ignore: avoid_print
      print('📥 [SOCKET RECEIVE] Un message vient d\'arriver !');
      // ignore: avoid_print
      print('📦 [SOCKET DATA] Contenu : $data');

      try {
        final Map<String, dynamic> raw =
            data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        final dynamic msgData = raw.containsKey('message') ? raw['message'] : raw;
        if (msgData is! Map) return;

        final newMessage =
            ChatMessagePayload.fromJson(Map<String, dynamic>.from(msgData));
        final currentRoom = _socketRoomId;

        // ignore: avoid_print
        print(
            '🔍 [MATCH CHECK] Room Message: ${newMessage.conversationId} | Room Écran: $currentRoom');

        if (mounted) {
          final bool alreadyExists =
              _messages.any((m) => (m.id ?? '') == (newMessage.id ?? ''));
          final bool sameConversation =
              _messageBelongsToCurrentConversation(newMessage);

          if (!alreadyExists && sameConversation) {
            // ignore: avoid_print
            print('✅ [UI UPDATE] Les IDs matchent ! Appel de setState().');
            setState(() {
              _messages.insert(0, newMessage);
            });
            if (scrollController.hasClients) {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          } else {
            // ignore: avoid_print
            print(alreadyExists
                ? '⚠️ [DUPLICATE] Message déjà présent, insertion ignorée.'
                : '❌ [MATCH FAIL] Le message appartient à une autre room.');
          }
        } else {
          // ignore: avoid_print
          print('⚠️ [WIDGET DEAD] Le widget n\'est plus monté, setState annulé.');
        }
      } catch (e, st) {
        // ignore: avoid_print
        print('❌ SOCKET : erreur parsing/traitement new_message: $e ; data=$data');
        log('new_message: $e', stackTrace: st);
      }
    });

    SocketService.instance.connect().then((_) {
      // Signal serveur `play_notification_sound` (indépendant de new_message)
      final sock = SocketService.instance.socket;
      if (sock != null) {
        sock.off('play_notification_sound');
        sock.on('play_notification_sound', (dynamic _) {
          debugPrint('🎵 [SOUND EVENT] Signal reçu du serveur !');
          _playIncomingMessageSound();
        });
      } else {
        debugPrint('⚠️ [SOUND] socket null après connect — listener play_notification_sound ignoré');
      }
      final cid = _socketRoomId;
      if (mounted && cid.isNotEmpty) {
        final id = cid;
        // ignore: avoid_print
        print('🕵️‍♂️ [DIAGNOSTIC CHAT] === DÉBUT ===');
        // ignore: avoid_print
        print("➡️ Source d'ouverture : ${widget.booking != null ? 'ICÔNE BOOKING' : 'INBOX'}");
        // ignore: avoid_print
        print('🆔 ID de conversation reçu (widget.conversationId) : "${widget.conversationId}"');
        // ignore: avoid_print
        print('🆔 ID historique reçu (widget.historyId) : "${widget.historyId}"');
        String finalRoomId = (widget.conversationId ?? widget.historyId ?? '').trim();
        // ignore: avoid_print
        print('🗝️ ID de ROOM final utilisé pour le SOCKET : "$finalRoomId"');
        if (!finalRoomId.contains('_')) {
          // ignore: avoid_print
          print("⚠️ ALERTE : L'ID utilisé n'est PAS un ID composite. Le temps réel risque de ne pas fonctionner avec ce backend.");
        }
        // ignore: avoid_print
        print('🕵️‍♂️ [DIAGNOSTIC CHAT] === FIN ===');
        final socketRoomId = cid;
        // ignore: avoid_print
        print('🕵️‍♂️ [DIAGNOSTIC ID] --- DÉBUT ---');
        // ignore: avoid_print
        print('1. widget.conversationId: "${widget.conversationId}"');
        // ignore: avoid_print
        print('2. widget.historyId: "${widget.historyId}"');
        // ignore: avoid_print
        print('3. widget.bookingId: "${widget.bookingId}"');
        // ignore: avoid_print
        print('4. widget.booking.id: "${widget.booking?.id}"');
        // ignore: avoid_print
        print('5. Variable socketRoomId actuelle: "$socketRoomId"');
        // ignore: avoid_print
        print('🕵️‍♂️ [DIAGNOSTIC ID] --- FIN ---');
        // ignore: avoid_print
        print('DEBUG SOCKET VENDEUR : joinRoom($id)');
        SocketService.instance.joinRoom(cid);
      }
      _loadMessages();
    });

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
    SocketService.instance.socket?.off('play_notification_sound');
    _socketSubscription?.cancel();
    _notificationPlayer.dispose();
    isChatOpen = false;
    scrollController.dispose();
    super.dispose();
  }

  bool clickOption = false;
  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🛋️ [CHAT_SOCKET] build → room = "$_socketRoomId" | 📜 [CHAT_REST] actif = "${_activeRestHistoryId ?? ''}" | widget.mongoId = "${widget.mongoId ?? ''}"');
    // ignore: avoid_print
    print('🎨 UI : Nombre de messages à afficher : ${_messages.length}');
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          SizedBox(
            width: Dimensions.containerWidth,
            child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: CustomAppBars(
                title: widget.vehicleTitle ?? 'Discussion',
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.vehicleTitle ?? 'Discussion',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    if ((widget.city ?? '').trim().isNotEmpty)
                                      Text(
                                        widget.city!.trim(),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                Text(_displayFromSubtitle(),
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
                        child: _loadingHistory
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: getColorBasedOnActiveModuleid(),
                                ),
                              )
                            : _messages.isEmpty
                                ? Center(
                                    child: Text(
                                      "No messages yet".tr,
                                      style: regular(context),
                                    ),
                                  )
                                : ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    controller: scrollController,
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      final m = _messages[index];
                                      final map = m.toLegacyMap();
                                      if (m.senderId == userId.toString()) {
                                        return _buildSenderMessage(
                                            context, map);
                                      }
                                      return _buildReceiverMessage(
                                          context, map);
                                    },
                                  ),
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
                                child: SafeArea(
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
        final downloadUrl = await uploadChatImage(compressedFile);
        if (downloadUrl == null || downloadUrl.isEmpty) {
          showErrorToastMessage("Échec de l'envoi de l'image".tr);
          setState(() {
            isUploading = false;
          });
          return;
        }
        final cid = _socketRoomId;
        if (cid.isNotEmpty) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final optimistic = ChatMessagePayload(
            id: 'local_img_$now',
            conversationId: cid,
            senderId: userId.toString(),
            text: '',
            timestampMs: now,
            attachment: {'image': downloadUrl},
            seen: true,
            pending: true,
          );
          setState(() {
            _messages.insert(0, optimistic);
          });
          SocketService.instance.sendMessage(cid, downloadUrl);
        }

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
