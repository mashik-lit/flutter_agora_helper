import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../agora_helper.dart';
import 'logger.dart';

final peerMessageProvider =
    StateNotifierProvider<PeerMessageNotifier, PeerMessage?>(
  (ref) => PeerMessageNotifier(null),
);

class PeerMessageNotifier extends StateNotifier<PeerMessage?> {
  PeerMessageNotifier(super.state) {
    RtmClient.client.onMessageReceived =
        (RtmMessage message, String peerId) {
      log("Peer msg: $peerId, msg: ${message.text}");
      state = PeerMessage(
        message: message,
        peerId: peerId,
      );
    };
  }
}

class PeerMessage {
  PeerMessage({
    required this.message,
    required this.peerId,
  });

  final RtmMessage message;
  final String peerId;
}
