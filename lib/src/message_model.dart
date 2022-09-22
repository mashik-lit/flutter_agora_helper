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
  String toString() => '{"type": "$typeString", "message": "$message"}';

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

  String get typeString {
    switch (type) {
      case MessageTypes.text:
        return 'text';
      case MessageTypes.prescription:
        return 'prescription';
      case MessageTypes.image:
        return 'image';
      case MessageTypes.audio:
        return 'audio';
      case MessageTypes.videoCallRequest:
        return 'video_call_request';
      case MessageTypes.video:
        return 'video';
      case MessageTypes.audioCallRequest:
        return 'audio_call_request';
    }
  }

  static MessageTypes getType(String string) {
    switch (string) {
      case 'text':
        return MessageTypes.text;
      case 'prescription':
        return MessageTypes.prescription;
      case 'image':
        return MessageTypes.image;
      case 'audio':
        return MessageTypes.audio;
      case 'video_call_request':
        return MessageTypes.videoCallRequest;
      case 'video':
        return MessageTypes.video;
      case 'audio_call_request':
        return MessageTypes.audioCallRequest;
      default:
        return MessageTypes.text;
    }
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      type: getType(map['type']),
      message: map['message'] ?? '',
    );
  }

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}
