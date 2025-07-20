import 'package:ali_grad/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/message_bubble.dart';
import '../widgets/new_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUsername;
  final String otherUserId;
  final String otherUsername;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUsername,
    required this.otherUserId,
    required this.otherUsername,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final chatId =
        ChatService().getChatId(widget.currentUserId, widget.otherUserId);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherUsername,
          style: AppTheme.textStyle0.copyWith(color: AppTheme.textColor2),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService().chatMessages(chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg['senderId'] == widget.currentUserId;
                    return MessageBubble(
                      text: msg['text'] ?? '',
                      isMe: isMe,
                      timestamp: (msg['timestamp'] is Timestamp)
                          ? (msg['timestamp'] as Timestamp).toDate()
                          : DateTime.now(),
                      username:
                          isMe ? widget.currentUsername : widget.otherUsername,
                    );
                  },
                );
              },
            ),
          ),
          NewMessage(
            onSend: (text) {
              ChatService().sendMessage(
                myUserId: widget.currentUserId,
                myUsername: widget.currentUsername,
                otherUserId: widget.otherUserId,
                otherUsername: widget.otherUsername,
                text: text,
              );
            },
          ),
        ],
      ),
    );
  }
}
