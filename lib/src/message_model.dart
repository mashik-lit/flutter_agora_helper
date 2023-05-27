import 'dart:convert';

import 'message_types.dart';

class MessageModel {
  MessageModel({
    required this.type,
    required this.message,
  });

  final MessageTypes type;
  final String message;

  @override
  String toString() => '{"type": "${type.toString()}", "message": "$message"}';

  factory MessageModel.textMessage(String message) => MessageModel(
        message: message,
        type: MessageTypes.text,
      );

  factory MessageModel.videoCallRequest() => MessageModel(
        message: 'join_video',
        type: MessageTypes.videoCallRequest,
      );

  factory MessageModel.audioCallRequest() => MessageModel(
        message: 'join_audio',
        type: MessageTypes.audioCallRequest,
      );

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      type: MessageTypes.fromString(map['type']),
      message: map['message'] ?? '',
    );
  }

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}
