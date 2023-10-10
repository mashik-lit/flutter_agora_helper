import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter_agora_helper/src/logger.dart';

class AgoraChatClient {
  static Future<void> initialize(String appId) async {
    ChatOptions options = ChatOptions(
      appKey: appId,
      autoLogin: false,
    );
    try {
      await ChatClient.getInstance.init(options);
      // Notify the SDK that the UI is ready. After the following method is executed, callbacks within `ChatRoomEventHandler`, ` ChatContactEventHandler`, and `ChatGroupEventHandler` can be triggered.
      await ChatClient.getInstance.startCallback();
      log("Agora chat client initialized");
    } on Exception catch (e) {
      log("Agora chat client initialization failed - ${e.toString()}");
    }
  }

  static Future<void> signIn({
    required String userId,
    required String token,
  }) async {
    try {
      await ChatClient.getInstance.loginWithAgoraToken(
        userId,
        token,
      );
      log("login succeed, userId: $userId");
    } on ChatError catch (e) {
      log("login failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  static Future<void> signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      log("sign out succeed");
    } on ChatError catch (e) {
      log(
        "sign out failed, code: ${e.code}, desc: ${e.description}",
      );
    }
  }

  static Future<void> sendTextMessage({
    required String targetId,
    required String content,
  }) async {
    var msg = ChatMessage.createTxtSendMessage(
      targetId: targetId,
      content: content,
      chatType: ChatType.Chat,
    );

    ChatClient.getInstance.chatManager.sendMessage(msg);
  }
}
