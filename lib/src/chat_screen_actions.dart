import 'message_model.dart';

abstract class ChatScreenActions {
  Future<void> saveMessage(MessageModel message);
  void initiateVideoCall();
  void addToList(MessageModel model, {bool received = false});
  void scrollToBottom();
  void updateUI();
}
