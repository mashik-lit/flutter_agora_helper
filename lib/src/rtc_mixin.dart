import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';

mixin RtcMixin {
  RtcEngine? rtcEngine;
  Future<void> joinRTCCall({
    required String channelName,
    required int optionalUid,
    String? token,
    bool audioOnly = false,
    UidWithElapsedAndChannelCallback? joinChannelSuccess,
    UidWithElapsedCallback? userJoined,
    UserOfflineCallback? userOffline,
  }) async {
    if (rtcEngine == null) {
      throw Exception('Initialize rtcEngine before ini');
    }
    log("~~Setting event handlers");

    try {
      rtcEngine!.setEventHandler(
        RtcEngineEventHandler(
          joinChannelSuccess: joinChannelSuccess,
          userJoined: userJoined,
          userOffline: userOffline,
        ),
      );

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
        token,
        channelName,
        null,
        optionalUid,
        ChannelMediaOptions(),
      );

      log("~~joinChannel Success");
    } catch (e) {
      log("~~joinChannel Error: ${e.toString()}");
    }
  }
}
