part of 'video_call_controller.dart';

final remoteUser = StateProvider<int?>((ref) => null);
final joinedInChannel = StateProvider<bool>((ref) => false);
final localAudioMuted = StateProvider<bool>((ref) => false);
final localVideoStopped = StateProvider<bool>((ref) => false);
final remoteAudioMuted = StateProvider<bool>((ref) => false);
final remoteVideoStopped = StateProvider<bool>((ref) => false);
final rtcEngine = StateProvider<RtcEngine>((ref) => AgoraRtcEngine.rtcEngine);

final videoCallController = StateNotifierProvider(
  (ref) => VideoCallController(ref),
);
