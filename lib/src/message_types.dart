enum MessageTypes {
  text,
  prescription,
  image,
  audio,
  video,
  audioCallRequest,
  videoCallRequest
}

String typeString(MessageTypes type) {
    switch (type) {
      case MessageTypes.text:
        return 'text';
      case MessageTypes.prescription:
        return 'prescription';
      case MessageTypes.image:
        return 'image';
      case MessageTypes.audio:
        return 'audio';
      case MessageTypes.videoCallRequest:
        return 'video_call_request';
      case MessageTypes.video:
        return 'video';
      case MessageTypes.audioCallRequest:
        return 'audio_call_request';
    }
  }
 MessageTypes getType(String string) {
    switch (string) {
      case 'text':
        return MessageTypes.text;
      case 'prescription':
        return MessageTypes.prescription;
      case 'image':
        return MessageTypes.image;
      case 'audio':
        return MessageTypes.audio;
      case 'video_call_request':
        return MessageTypes.videoCallRequest;
      case 'video':
        return MessageTypes.video;
      case 'audio_call_request':
        return MessageTypes.audioCallRequest;
      default:
        return MessageTypes.text;
    }
  }