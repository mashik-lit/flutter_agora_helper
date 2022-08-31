// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';

import 'package:agora_rtm/agora_rtm.dart';

import 'chat_screen_actions.dart';
import 'message_model.dart';

mixin AgoraRtmMixin {
  AgoraRtmClient? client;
  ChatScreenActions? actions;
  AgoraRtmChannel? channel;

  void createChannel(String channelName) async {
    if (client == null) {
      throw Exception("initialize AgoraRtmClient before creating a channel");
    }
    if (actions == null) {
      throw Exception("initialize ChatScreenActions before creating a channel");
    }
    try {
      channel = await client!.createChannel(channelName);

      log("~~Channel ${channel?.channelId ?? 'null'} created");
    } catch (e) {
      log("~~Channel creation error: ${e.toString()}");
    }

    if (channel == null) return;

    try {
      await channel!.join();
      log("~~Joined in channel ${channel?.channelId ?? 'null'}");
    } on Exception catch (e) {
      log("~~Channel join error: ${e.toString()}");
    }

    channel!.onMessageReceived = onMessageReceived;
  }

  Future<void> sendMessage(MessageModel message) async {
    if (channel == null) {
      throw Exception("Initialize the channel to send a message");
    }
    try {
      await channel!.sendMessage(AgoraRtmMessage.fromText(message.toString()));
      log("~~message sent to ${channel!.channelId}");
    } catch (e) {
      log("~~sendMessage Error: ${e.toString()}");
    }
    actions!.saveMessage(message);

    actions!.addToList(message);

    actions!.scrollToBottom();

    actions!.setState(() {});
  }

  Future<void> onMessageReceived(
    AgoraRtmMessage message,
    AgoraRtmMember fromMember,
  ) async {
    log("~~message_received: ${message.text}");
    if (message.text.contains('join_video_call')) {
      actions!.initiateVideoCall();
      return;
    }
    final messageModel = MessageModel.fromJson(message.text);

    actions!.addToList(messageModel, received: true);

    actions!.scrollToBottom();

    actions!.setState(() {});
  }
}
