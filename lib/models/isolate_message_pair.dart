class IsolateMessagePair<ST, RT> {
  const IsolateMessagePair({
    required this.sendedMessage,
    required this.receivedMessage,
  });
  final ST sendedMessage;
  final RT receivedMessage;
}
