import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

typedef UserJoined = void Function(
  RtcConnection connection,
  int remoteUid,
  int elapsed,
);

typedef OnJoinChannelSuccess = void Function(
  RtcConnection connection,
  int elapsed,
);

typedef OnUserOffline = void Function(
  RtcConnection connection,
  int remoteUid,
  UserOfflineReasonType reason,
);

mixin RtcMixin {
  RtcEngine? rtcEngine;
  Future<void> joinRTCCall({
    required String channelName,
    required int optionalUid,
    required String token,
    bool audioOnly = false,
    OnJoinChannelSuccess? onJoinChannelSuccess,
    UserJoined? onUserJoined,
    OnUserOffline? onUserOffline,
  }) async {
    if (rtcEngine == null) {
      throw Exception('Initialize rtcEngine before ini');
    }
    log("~~Setting event handlers");

    try {
      rtcEngine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: onJoinChannelSuccess,
        onUserJoined: onUserJoined,
        onUserOffline: onUserOffline,
      ));
      log("~~Event handlers Set");
    } catch (e) {
      log("~~Error Event handlers Set: ${e.toString()}");
    }

    if (!audioOnly) {
      rtcEngine!.enableVideo();
    }

    try {
      rtcEngine!.leaveChannel();
      log("~~joining channel : $channelName");

      await rtcEngine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: optionalUid,
        options: const ChannelMediaOptions(),
      );

      log("~~joinChannel Success");
    } catch (e) {
      log("~~joinChannel Error: ${e.toString()}");
    }
  }
}
