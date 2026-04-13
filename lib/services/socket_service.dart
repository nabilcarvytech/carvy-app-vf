import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:carvy/api/config.dart';
import 'package:carvy/work_space.dart';

/// Client Socket.IO (singleton) pour le chat temps réel côté Node.js.
/// Les écrans s’abonnent à [newMessageStream] pour un flux réactif (équivalent Firebase).
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  factory SocketService() => instance;

  io.Socket? _socket;

  final StreamController<dynamic> _newMessageController =
      StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _updateInboxController =
      StreamController<dynamic>.broadcast();
  Timer? _unreadRefreshDebounce;

  /// Flux des événements `new_message` (plusieurs listeners possibles).
  Stream<dynamic> get newMessageStream => _newMessageController.stream;
  /// Flux des événements qui doivent déclencher un refresh de l'inbox.
  Stream<dynamic> get updateInboxStream => _updateInboxController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Socket brute (null si pas encore connecté). Pour écouter des événements custom côté écran.
  io.Socket? get socket => _socket;

  /// URL du handshake Socket.IO (dérivée de [Config.baseUrlWithoutV1]).
  /// Si le serveur écoute sur l’origine sans `/api`, adaptez [Config] ou cette méthode.
  String _socketUrl() {
    var base = Config.baseUrlWithoutV1;
    if (!base.startsWith('http')) {
      base = 'https://$base';
    }
    return base.replaceAll(RegExp(r'/$'), '');
  }

  /// Connexion avec JWT dans les en-têtes (comme attendu par le backend).
  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final jwt = token;
    if (jwt.isEmpty) {
      // ignore: avoid_print
      print('[SocketService] connect ignoré : token vide');
      return;
    }

    await disconnect();

    // Forcer la connexion sur l’origine Nginx sécurisée servant Socket.IO
    final url = 'https://carvy.tech';
    _socket = io.io(
      url,
      io.OptionBuilder()
          .enableForceNew()
          .setTransports(['websocket'])
          .setPath('/socket.io/')
          .setExtraHeaders(<String, dynamic>{
            'Authorization': 'Bearer $jwt',
          })
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      // ignore: avoid_print
      print('[SocketService] connecté : $url');
      _attachNewMessageListener();
    });

    _socket!.onConnectError((dynamic err) {
      // ignore: avoid_print
      print('[SocketService] erreur connexion: $err');
      // ignore: avoid_print
      print('[SocketService] erreur détail (brut): ${err is Object ? err.toString() : err}');
    });

    _socket!.onDisconnect((dynamic reason) {
      // ignore: avoid_print
      print('[SocketService] déconnecté: $reason');
    });

    _socket!.onReconnect((dynamic _) {
      _attachNewMessageListener();
    });

    _attachNewMessageListener();

    // Log de tentative de connexion (utile pour diagnostiquer le chemin Nginx)
    // ignore: avoid_print
    print('Tentative de connexion Socket sur: https://carvy.tech/socket.io/');
    _socket!.connect();
  }

  void _attachNewMessageListener() {
    _socket?.off('new_message');
    _socket?.on('new_message', (dynamic data) {
      _newMessageController.add(data);
      _updateInboxController.add(data);
      _scheduleUnreadRefresh();
    });
    _socket?.off('update_inbox');
    _socket?.on('update_inbox', (dynamic data) {
      _updateInboxController.add(data);
      _scheduleUnreadRefresh();
    });
    _socket?.off('inbox_updated');
    _socket?.on('inbox_updated', (dynamic data) {
      _updateInboxController.add(data);
      _scheduleUnreadRefresh();
    });
  }

  void _scheduleUnreadRefresh() {
    _unreadRefreshDebounce?.cancel();
    _unreadRefreshDebounce = Timer(const Duration(milliseconds: 500), () {
      try {
        generalController.fetchTotalUnreadCount();
      } catch (_) {
        // Controller pas encore prêt : on ignore.
      }
    });
  }

  /// Ferme la connexion Socket.IO.
  Future<void> disconnect() async {
    _unreadRefreshDebounce?.cancel();
    _socket?.off('new_message');
    _socket?.off('update_inbox');
    _socket?.off('inbox_updated');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Rejoint une room de conversation (événement serveur `join_room`).
  void joinRoom(String conversationId) {
    if (conversationId.isEmpty) return;
    _socket?.emit('join_room', <String, dynamic>{
      'conversationId': conversationId,
    });
  }

  /// Envoie un message texte (événement serveur `send_message`).
  void sendMessage(String conversationId, String text) {
    if (conversationId.isEmpty || text.isEmpty) return;
    // ignore: avoid_print
    print('✈️ [SOCKET_SERVICE] Émission vers le serveur...');
    // ignore: avoid_print
    print('📦 [SOCKET_SERVICE] Room: $conversationId | Event: send_message');
    if (_socket == null || !(_socket!.connected)) {
      // ignore: avoid_print
      print('❌ [SOCKET_SERVICE] ERREUR : La socket est déconnectée !');
    }
    _socket?.emit('send_message', <String, dynamic>{
      'conversationId': conversationId,
      'text': text,
    });
  }

  /// Abonnement style callback ; retourner [StreamSubscription.cancel] au dispose de l’écran.
  StreamSubscription<dynamic> onNewMessage(void Function(dynamic data) callback) {
    return newMessageStream.listen(callback);
  }

  StreamSubscription<dynamic> onUpdateInbox(void Function(dynamic data) callback) {
    return updateInboxStream.listen(callback);
  }

  /// Ferme uniquement la socket ; le [newMessageStream] reste utilisable après un nouveau [connect].
  Future<void> shutdown() async {
    await disconnect();
  }
}
