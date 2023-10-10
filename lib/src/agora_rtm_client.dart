import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter_agora_helper/src/logger.dart';

class RtmClient {
  static late AgoraRtmClient client;
  static RtmClient? _instance;

  RtmClient._(AgoraRtmClient rtmClient) {
    client = rtmClient;

    client.onConnectionStateChanged2 =
        (RtmConnectionState state, RtmConnectionChangeReason reason) {
      log('csc: $state, reason: $reason');
    };

    client.getRtmCallManager().onLocalInvitationReceivedByPeer = (LocalInvitation invite) {
      log('Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}, ${invite.channelId}');
    };

    client.getRtmCallManager().onRemoteInvitationReceived =
        (RemoteInvitation invite) {
      log('Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');
    };
  }

  static Future<void> initialize(String appId) async {
    log('initializing agoraRtmClient');
    _instance ??= RtmClient._(await AgoraRtmClient.createInstance(appId));

    log('initialized agoraRtmClient');
  }
}

String connectionState(int state) {
  switch (state) {
    case 1:
      return 'Disconnected';
    case 2:
      return 'Connecting';
    case 3:
      return 'Connected';
    case 4:
      return 'Reconnecting';
    case 5:
      return 'Aborted';
  }
  return state.toString();
}

String connectionChangeReason(int reason) {
  switch (reason) {
    case 1:
      return 'Login';
    case 2:
      return 'Login Success';
    case 3:
      return 'Login Failure';
    case 4:
      return 'Login Timeout';
    case 5:
      return 'Interrupted';
    case 6:
      return 'Logout';
    case 7:
      return 'Banned by Server';
    case 8:
      return 'Remote Login';
  }
  return reason.toString();
}
