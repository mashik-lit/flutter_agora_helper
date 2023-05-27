import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_agora_helper/src/logger.dart';

class AgoraRtcEngine {
  static late RtcEngine rtcEngine;
  static AgoraRtcEngine? _instance;

  AgoraRtcEngine._(RtcEngine engine) {
    rtcEngine = engine;
  }

  static Future<void> initialize(String appId) async {
    log('initiazing agoraRtcEngine');
    try {
      final engine = createAgoraRtcEngine();
      engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _instance ??= AgoraRtcEngine._(engine);
    } catch (e) {
      log('error initializing agoraRtcEngine');
    }

    log('initialized agoraRtcEngine');
  }
}
