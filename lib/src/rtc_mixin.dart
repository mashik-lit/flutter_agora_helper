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
    bool localAudioMuted = false,
    bool localVideoStopped = false,
    bool remoteAudioMuted = false,
    bool remoteVideoStopped = false,
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
          publishLocalAudio: !localAudioMuted,
          publishLocalVideo: !localVideoStopped,
          autoSubscribeAudio: !remoteAudioMuted,
          autoSubscribeVideo: !remoteVideoStopped,
        ),
      );

      log("~~joinChannel Success");
    } catch (e) {
      log("~~joinChannel Error: ${e.toString()}");
    }
  }
}
