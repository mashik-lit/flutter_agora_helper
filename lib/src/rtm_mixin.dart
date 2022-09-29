import 'dart:developer';

import 'package:agora_rtm/agora_rtm.dart';

import 'agora_rtm_client.dart';
import 'chat_screen_actions.dart';
import 'message_model.dart';
import 'message_types.dart';

mixin AgoraRtmMixin {
  AgoraRtmClient client = RtmClient.client;
  ChatScreenActions? actions;
  AgoraRtmChannel? channel;
  bool theOtherIsOnline = false;

  Future<void> createChannel(String channelName) async {
    if (actions == null) {
      throw Exception("initialize ChatScreenActions before creating a channel");
    }
    try {
      channel = await client.createChannel(channelName);

      log("~~Channel ${channel?.channelId ?? 'null'} created");
    } catch (e) {
      log("~~Channel creation error: ${e.toString()}");
    }

    if (channel == null) return;

    try {
      await channel!.join();
      log("~~Joined in channel ${channel?.channelId ?? 'null'}");
    } catch (e) {
      log("~~Channel join error: ${e.toString()}");
      return;
    }

    final membersList = await channel!.getMembers();
    theOtherIsOnline = membersList.length > 1;
    actions!.updateUI();

    channel!.onMessageReceived = onMessageReceived;
    channel!.onMemberLeft = onMemberLeft;
    channel!.onMemberJoined = onMemberJoined;
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
    if (message.type == MessageTypes.audioCallRequest ||
        message.type == MessageTypes.videoCallRequest) {
      return;
    }
    actions!.saveMessage(message);

    actions!.addToList(message);

    actions!.scrollToBottom();

    actions!.updateUI();
  }

  Future<void> onMessageReceived(
    AgoraRtmMessage message,
    AgoraRtmMember fromMember,
  ) async {
    log("~~message_received: ${message.text}");
    final messageModel = MessageModel.fromJson(message.text);
    if (messageModel.type == MessageTypes.audioCallRequest ||
        messageModel.type == MessageTypes.videoCallRequest) {
      actions!.initiateVideoCall(messageModel.type);
      return;
    }

    actions!.addToList(messageModel, received: true);

    actions!.scrollToBottom();

    actions!.updateUI();
  }

  void onMemberJoined(AgoraRtmMember member) {
    theOtherIsOnline = true;
    actions!.updateUI();
  }

  void onMemberLeft(AgoraRtmMember member) {
    theOtherIsOnline = false;
    actions!.updateUI();
  }
}
