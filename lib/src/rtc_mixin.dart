import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';

mixin RtcMixin {
  RtcEngine? rtcEngine;
  Future<void> joinRTCCall({
    required String channelName,
    required int optionalUid,
    String? token,
    UidWithElapsedAndChannelCallback? joinChannelSuccess,
    UidWithElapsedCallback? userJoined,
    UserOfflineCallback? userOffline,
    bool publishLocalAudio = false,
    bool publishLocalVideo = false,
    bool autoSubscribeAudio = false,
    bool autoSubscribeVideo = false,
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

    rtcEngine!.enableVideo();

    try {
      rtcEngine!.leaveChannel();
      log("~~joining channel : $channelName");

      await rtcEngine!.joinChannel(
        token,
        channelName,
        null,
        optionalUid,
        ChannelMediaOptions(
          publishLocalAudio: publishLocalAudio,
          publishLocalVideo: publishLocalVideo,
          autoSubscribeAudio: autoSubscribeAudio,
          autoSubscribeVideo: autoSubscribeVideo,
        ),
      );

      log("~~joinChannel Success");
    } catch (e) {
      log("~~joinChannel Error: ${e.toString()}");
    }
  }
}
