class IsolateMessagePair<ST, RT> {
  final ST sendedMessage;
  final RT receivedMessage;

  const IsolateMessagePair({
    required this.sendedMessage,
    required this.receivedMessage,
  });
}
