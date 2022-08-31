import 'message_model.dart';

abstract class AbstractMessagesNotifier {
  Future<void> saveMessage({
    required String channelName,
    required MessageModel message,
    required int doctorId,
    required int bookingId,
    required int memberId,
    required bool notify,
  });
}