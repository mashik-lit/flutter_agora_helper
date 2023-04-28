import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../agora_rtc_engine.dart';

part 'providers.dart';

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

class VideoCallController extends StateNotifier<void> {
  VideoCallController(this.ref) : super(Null) {
    rtcEngine = AgoraRtcEngine.rtcEngine;
  }

  late RtcEngine rtcEngine;
  final Ref ref;

  Future<void> setupVideoSDKEngine() async {
    await [Permission.microphone, Permission.camera].request();

    const configuration = VideoEncoderConfiguration(
      dimensions: VideoDimensions(
        width: 1920,
        height: 1080,
      ),
      advanceOptions: AdvanceOptions(
        compressionPreference: CompressionPreference.preferQuality,
        encodingPreference: EncodingPreference.preferAuto,
      ),
      codecType: VideoCodecType.videoCodecGenericH264,
      degradationPreference: DegradationPreference.maintainQuality,
      orientationMode: OrientationMode.orientationModeFixedPortrait,
    );

    await rtcEngine.setVideoEncoderConfiguration(configuration);

    await rtcEngine.enableVideo();

    try {
      rtcEngine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          log("~~local user ${connection.localUid} joined in ${connection.channelId}");

          ref.read(joinedInChannel.notifier).state = true;
          try {
            rtcEngine.startPreview(
              sourceType: VideoSourceType.videoSourceCameraSecondary,
            );
          } catch (e) {
            log("~~startPreview-Error: ${e.toString()}");
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          log("~~remote user $remoteUid joined in ${connection.channelId}");
          ref.read(remoteUser.notifier).state = remoteUid;
        },
        onUserOffline: (connection, remoteUid, reason) {
          log("~~remote user $remoteUid left ${connection.channelId}");
          leave();
        },
        onError: (err, msg) {
          log("~~Error: ${err.name} - $msg");
        },
        onPermissionError: (permissionType) {
          log("~~PermissionError: ${permissionType.name}");
        },
      ));
      log("~~Event handlers Set");
    } catch (e) {
      log("~~Error Event handlers Set: ${e.toString()}");
    }
  }

  Future<void> joinRTCCall({
    required String channelName,
    required int uid,
    required String token,
    bool audioOnly = false,
    required ClientRoleType role,
  }) async {
    // await rtcEngine.startPreview();
    try {
      log("~~joining channel : $channelName, role: ${role.toString()}");

      await rtcEngine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: role,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      log("~~joinChannel Success");
      // rtcEngine.startPreview();
    } catch (e) {
      log("~~joinChannel Error: ${e.toString()}");
    }
  }

  Future<void> swithcLocalAudioStream() async {
    final value = ref.read(localAudioMuted);
    await rtcEngine.muteLocalAudioStream(!value);
    ref.read(localAudioMuted.notifier).state = !value;
  }

  Future<void> switchRemoteAudioStreams() async {
    final value = ref.read(remoteAudioMuted);
    rtcEngine.muteAllRemoteAudioStreams(!value);
    ref.read(remoteAudioMuted.notifier).state = !value;
  }

  Future<void> switchLocalVideoStream() async {
    final value = ref.read(localVideoStopped);
    rtcEngine.muteLocalVideoStream(!value);
    ref.read(localVideoStopped.notifier).state = !value;
  }

  Future<void> leave() async {
    ref.read(joinedInChannel.notifier).state = false;
    ref.read(remoteUser.notifier).state = null;
    await rtcEngine.leaveChannel();
  }
}
