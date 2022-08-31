import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';

class AgoraRtcEngine {
  static late RtcEngine rtcEngine;
  static AgoraRtcEngine? _instance;

  AgoraRtcEngine._(RtcEngine engine) {
    rtcEngine = engine;
  }

  static Future<void> initialize(String appId) async {
    log('~~initializing agoraRtcEngine');
    try {
      final engine = await RtcEngine.create(appId);
      _instance ??= AgoraRtcEngine._(engine);
    } catch (e) {
      log('~~error initializing agoraRtcEngine');
    }

    log('~~initialized agoraRtcEngine');
  }
}
