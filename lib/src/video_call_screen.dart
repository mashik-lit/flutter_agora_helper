import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gen/assets.gen.dart';
import '../theme/colors.dart' as colors;
import '../theme/text_styles.dart';
import 'agora_rtc_engine.dart';
import 'video_call_controller/video_call_controller.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.channelName,
    this.audioOnly = false,
    required this.uid,
    this.onPop,
    required this.role,
  }) : super(key: key);

  final String channelName;
  final String token;
  final bool audioOnly;
  final int uid;
  final ValueChanged<int>? onPop;
  final ClientRoleType role;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => startCall(),
    );
  }

  Future<void> startCall() async {
    await ref.read(videoCallController.notifier).setupVideoSDKEngine();
    await ref.read(videoCallController.notifier).joinRTCCall(
          channelName: widget.channelName,
          uid: widget.uid,
          audioOnly: widget.audioOnly,
          token: widget.token,
          role: widget.role,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(joinedInChannel, (previous, next) {
      if (!next) {
        if (widget.onPop != null) {
          widget.onPop!(1);
        }
      }
    });
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
                child: _renderLocalPreview(),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 24.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer(builder: (context, ref, child) {
                    final state = ref.watch(localAudioMuted);
                    return _ThatButton(
                      onPressed: () => ref
                          .read(videoCallController.notifier)
                          .swithcLocalAudioStream(),
                      isRed: state,
                      redIcon: Assets.icons.microphoneSlash,
                      whiteIcon: Assets.icons.microphone2,
                    );
                  }),
                  Consumer(builder: (context, ref, child) {
                    final state = ref.watch(remoteAudioMuted);
                    return _ThatButton(
                      onPressed: () => ref
                          .read(videoCallController.notifier)
                          .switchRemoteAudioStreams(),
                      isRed: state,
                      redIcon: Assets.icons.volumeSlash,
                      whiteIcon: Assets.icons.volumeHigh,
                    );
                  }),
                  Consumer(builder: (context, ref, child) {
                    final state = ref.watch(localVideoStopped);
                    return _ThatButton(
                      onPressed: () => ref
                          .read(videoCallController.notifier)
                          .switchLocalVideoStream(),
                      isRed: state,
                      redIcon: Assets.icons.videoSlash,
                      whiteIcon: Assets.icons.video2,
                    );
                  }),
                  _ThatButton(
                    onPressed: () {
                      ref.read(videoCallController.notifier).leave();
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

  Widget _renderRemoteVideo() => Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(remoteUser);
          log("~~renderRemoteVideo: $user");
          if (user == null) {
            return child!;
          }
          return AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: AgoraRtcEngine.rtcEngine,
              canvas: VideoCanvas(uid: user),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          );
        },
        child: Text(
          'Please wait for remote user to join',
          style: TextStyles.body2.red(),
        ),
      );

  Widget _renderLocalPreview() => Consumer(
        builder: (context, ref, child) {
          final joined = ref.read(joinedInChannel);
          if (!joined) {
            return child!;
          }
          return AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: AgoraRtcEngine.rtcEngine,
              canvas: VideoCanvas(uid: widget.uid),
            ),
          );
        },
        child: const SizedBox.shrink(),
      );
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
