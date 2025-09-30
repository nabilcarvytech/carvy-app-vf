class ChatMessages {
  String message;

  String itemName;
  String from;
  String receiverId;
  bool seen;
  String image;
  String roomId;
  String bookingIO;
  String bookingStatus;
    String userImage;
  String senderId;
  int timestamp;
  String timeZone;
  String playeridUser1;
  String playeridUser2;
  Map<String, dynamic> attachment;

  ChatMessages({
    required this.message,
    required this.from,
    required this.timeZone,

    required this.image,
    required this.itemName,
    required this.roomId,
    required this.bookingIO,
    required this.bookingStatus,
    required this.receiverId,
    required this.seen,
    required this.senderId,
        required this.userImage,
    required this.timestamp,
    required this.attachment,
    required this.playeridUser1,
    required this.playeridUser2,
    // Include in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'image': image,
     
      'timeZone': timeZone,
      'from': from,
      'itemName': itemName,
      'roomId': roomId,
      'receiverId': receiverId,
      'bookingId': bookingIO,
      'bookingStatus': bookingStatus,
         'userImage': userImage,
      'seen': seen,
      'senderId': senderId,
      'timestamp': timestamp,
      'attachment': attachment,
      'playerid_user1': playeridUser1,
      'playerid_user2': playeridUser2,
    };
  }
}
