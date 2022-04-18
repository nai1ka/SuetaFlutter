class ChatMessage{
  String messageContent;
  MessageTypes messageType;
  ChatMessage(this.messageContent, this.messageType);
}


enum MessageTypes{
 sender,receiver
}