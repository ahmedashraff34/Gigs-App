import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/chat_messages.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String? currentUserId;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
      currentUsername = prefs.getString('username') ?? 'Me';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Debug: Print the current user ID
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChatService().recentChats(currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final chats = snapshot.data ?? [];
        final users = chats.map((chat) {
          final isUser1 = chat['user1Id'] == currentUserId;
          final otherId = isUser1 ? chat['user2Id'] : chat['user1Id'];
          final otherName = isUser1 ? chat['user2Name'] : chat['user1Name'];
          return ChatUser(
            userId: otherId,
            username: otherName,
            avatarUrl: null, // Add avatar if available
            lastMessage: chat['lastMessage'] ?? '',
            lastTimestamp: (chat['lastTimestamp'] is Timestamp)
                ? (chat['lastTimestamp'] as Timestamp).toDate()
                : DateTime.now(),
          );
        }).toList();
        return ChatMessages(
          users: users,
          onChatTap: (user) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  currentUserId: currentUserId!,
                  currentUsername: currentUsername!,
                  otherUserId: user.userId,
                  otherUsername: user.username,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
