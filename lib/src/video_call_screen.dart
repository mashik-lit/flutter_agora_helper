import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import 'package:flutter_agora_helper/agora_helper.dart';

import '../gen/assets.gen.dart';
import '../theme/colors.dart' as colors;
import '../theme/text_styles.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.channelName,
    this.audioOnly = false,
    required this.uid,
    this.onPop,
  }) : super(key: key);

  final String channelName;
  final String token;
  final bool audioOnly;
  final int uid;
  final ValueChanged<int>? onPop;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with RtcMixin {
  int? _remoteUserId;
  int? _localUserId;
  RtcConnection? _connection;

  bool localAudioMuted = false;
  bool localVideoStopped = false;
  bool remoteAudioMuted = false;
  bool remoteVideoStopped = false;

  @override
  void initState() {
    super.initState();
    rtcEngine = AgoraRtcEngine.rtcEngine;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setupCall());
  }

  Future<void> setupCall() async {
    await rtcEngine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        orientationMode: OrientationMode.orientationModeFixedPortrait,
        degradationPreference: DegradationPreference.maintainQuality,
      ),
    );
    await joinRTCCall(
      channelName: widget.channelName,
      optionalUid: widget.uid,
      audioOnly: widget.audioOnly,
      token: widget.token,
      onJoinChannelSuccess: (connection, elapsed) {
        log("~~local user ${connection.localUid} joined");
        _localUserId = connection.localUid;
        setState(() {});
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        log("~~remote user $remoteUid joined");
        setState(() {
          _remoteUserId = remoteUid;
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        log("~~remote user $remoteUid left channel");
        setState(() {
          _remoteUserId = null;
        });
        if (widget.onPop != null) {
          widget.onPop!(0);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _renderRemoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 100.0,
                width: 100.0,
                child: Center(
                  child: _renderLocalPreview(),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 24.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ThatButton(
                    onPressed: () {
                      setState(() {
                        localAudioMuted = !localAudioMuted;
                      });
                      rtcEngine!.muteLocalAudioStream(localAudioMuted);
                    },
                    isRed: localAudioMuted,
                    redIcon: Assets.icons.microphoneSlash,
                    whiteIcon: Assets.icons.microphone2,
                  ),
                  _ThatButton(
                    onPressed: () {
                      setState(() {
                        remoteAudioMuted = !remoteAudioMuted;
                      });
                      rtcEngine!.muteAllRemoteAudioStreams(remoteAudioMuted);
                    },
                    isRed: remoteAudioMuted,
                    redIcon: Assets.icons.volumeSlash,
                    whiteIcon: Assets.icons.volumeHigh,
                  ),
                  _ThatButton(
                    onPressed: () {
                      setState(() {
                        localVideoStopped = !localVideoStopped;
                      });
                      rtcEngine!.muteLocalVideoStream(localVideoStopped);
                    },
                    isRed: localVideoStopped,
                    redIcon: Assets.icons.videoSlash,
                    whiteIcon: Assets.icons.video2,
                  ),
                  _ThatButton(
                    onPressed: () {
                      rtcEngine!.leaveChannel();
                      if (widget.onPop != null) {
                        widget.onPop!(1);
                      }
                    },
                    isRed: true,
                    redIcon: Assets.icons.callSlash,
                    whiteIcon: Assets.icons.callSlash,
                    iconHeight: MediaQuery.of(context).size.width * 0.1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUserId != null && rtcEngine != null) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: rtcEngine!,
          canvas: VideoCanvas(uid: _remoteUserId),
        ),
      );
    } else {
      return Text(
        'Please wait for remote user to join',
        style: TextStyles.body2.red(),
      );
    }
  }

  Widget _renderLocalPreview() {
    if (rtcEngine != null && _connection != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: rtcEngine!,
          canvas: VideoCanvas(uid: _localUserId),
          connection: _connection!,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _ThatButton extends StatelessWidget {
  const _ThatButton({
    Key? key,
    required this.onPressed,
    required this.isRed,
    required this.redIcon,
    required this.whiteIcon,
    this.iconHeight,
  }) : super(key: key);

  final VoidCallback onPressed;
  final bool isRed;
  final SvgGenImage redIcon;
  final SvgGenImage whiteIcon;
  final double? iconHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.0125,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isRed ? colors.red : colors.light.withOpacity(0.5),
          padding: const EdgeInsets.all(12),
        ),
        child: (isRed ? redIcon : whiteIcon).svg(
          color: colors.white,
          height: iconHeight ?? MediaQuery.of(context).size.width * 0.06,
        ),
      ),
    );
  }
}
