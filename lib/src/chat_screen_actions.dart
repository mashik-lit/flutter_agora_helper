import 'package:flutter/material.dart';

import 'message_model.dart';

abstract class ChatScreenActions extends State {
  Future<void> saveMessage(MessageModel message);
  void initiateVideoCall();
  void addToList(MessageModel model, {bool received = false});
  void scrollToBottom();
}