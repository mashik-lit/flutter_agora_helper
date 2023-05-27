import 'package:flutter_agora_helper/agora_helper.dart';

abstract class ChatScreenActions {
  Future<void> saveMessage(MessageModel message);
  void addToList(MessageModel model, {bool received = false});
  void scrollToBottom();
  void updateUI();
}
