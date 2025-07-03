import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Returns the chat document ID for two users, creating it if needed
  Future<String> getOrCreateChatId(String userId1, String userId2) async {
    final users = [userId1, userId2]..sort();
    final chatQuery = await _db
        .collection('chat')
        .where('users', isEqualTo: users)
        .limit(1)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      return chatQuery.docs.first.id;
    } else {
      final doc = await _db.collection('chat').add({
        'users': users,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
      return doc.id;
    }
  }

  // Stream messages for a chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chat')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    await _db.collection('chat').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Update last message in chat doc
    await _db.collection('chat').doc(chatId).update({
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream all chats for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _db
        .collection('chat')
        .where('users', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }
} 