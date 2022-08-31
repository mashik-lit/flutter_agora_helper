import 'dart:developer';

import 'package:agora_rtm/agora_rtm.dart';

mixin AgoraRtmMixin {
  AgoraRtmClient? client;
  late void Function(
    AgoraRtmMessage message,
    AgoraRtmMember fromMember,
  )? onMessageReceived;

  late AgoraRtmChannel? channel;

  void createChannel(String channelName) async {
    if (client == null) {
      throw Exception("initialize AgoraRtmClient before creating a channel");
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

    if (onMessageReceived != null) {
      channel!.onMessageReceived = onMessageReceived;
    } else {
      log("~~No onMessageReceived callback assigned");
    }
  }

  Future<void> sendMessage(String message) async {
    if (channel == null) {
      throw Exception("Initialize the channel to send a message");
    }
    try {
      await channel!.sendMessage(AgoraRtmMessage.fromText(message));
      log("~~message sent to ${channel!.channelId}");
    } catch (e) {
      log("~~sendMessage Error: ${e.toString()}");
    }
  }
}
