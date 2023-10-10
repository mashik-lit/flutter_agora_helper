import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agora_helper/ui/no_video_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gen/assets.gen.dart';
import '../src/agora_rtc_engine.dart';
import '../src/video_call_controller/video_call_controller.dart';
import 'buttons.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.channelName,
    required this.audioOnly,
    required this.uid,
    this.onPop,
    required this.role,
    required this.bgColor,
    required this.avatarUrl,
  }) : super(key: key);

  final String channelName;
  final String token;
  final bool audioOnly;
  final int uid;
  final ValueChanged<int>? onPop;
  final ClientRoleType role;
  final Color bgColor;
  final String avatarUrl;

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
    await ref
        .read(videoCallController.notifier)
        .setupVideoSDKEngine(widget.audioOnly);
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _renderRemoteVideo(),
            ),
            if (!widget.audioOnly)
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: size.width * 0.3,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
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
                  Consumer(builder: (context, ref, child) {
                    final state = ref.watch(localAudioMuted);
                    return ThatButton(
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
                    return ThatButton(
                      onPressed: () => ref
                          .read(videoCallController.notifier)
                          .switchRemoteAudioStreams(),
                      isRed: state,
                      redIcon: Assets.icons.volumeSlash,
                      whiteIcon: Assets.icons.volumeHigh,
                    );
                  }),
                  if (!widget.audioOnly)
                    Consumer(builder: (context, ref, child) {
                      final state = ref.watch(localVideoStopped);
                      return ThatButton(
                        onPressed: () => ref
                            .read(videoCallController.notifier)
                            .switchLocalVideoStream(),
                        isRed: state,
                        redIcon: Assets.icons.videoSlash,
                        whiteIcon: Assets.icons.video2,
                      );
                    }),
                  EndCallButton(
                    onPressed: () {
                      ref.read(videoCallController.notifier).leave();
                    },
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
          if (widget.audioOnly) {
            return child!;
          }
          final user = ref.watch(remoteUser);
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
        child: NoVideoView(
          avatarUrl: widget.avatarUrl,
          bgColor: widget.bgColor,
        ),
      );

  Widget _renderLocalPreview() => Consumer(
        builder: (context, ref, child) {
          final joined = ref.watch(joinedInChannel);
          if (!joined) {
            return child!;
          }
          return AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: AgoraRtcEngine.rtcEngine,
              canvas: const VideoCanvas(
                uid: 0,
                renderMode: RenderModeType.renderModeHidden,
              ),
            ),
          );
        },
        child: const SizedBox.shrink(),
      );
}
