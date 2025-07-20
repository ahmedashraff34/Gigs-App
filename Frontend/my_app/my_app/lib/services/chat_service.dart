import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  // Get chat document ID for two users
  String getChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  // Stream of recent chats for a user
  Stream<List<Map<String, dynamic>>> recentChats(String myUserId) {
    return _db.collection('chat')
      .where('participants', arrayContains: myUserId)
      .orderBy('lastTimestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stream of messages for a chat
  Stream<List<Map<String, dynamic>>> chatMessages(String chatId) {
    return _db.collection('chat')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Send a message
  Future<void> sendMessage({
    required String myUserId,
    required String myUsername,
    required String otherUserId,
    required String otherUsername,
    required String text,
  }) async {
    final chatId = getChatId(myUserId, otherUserId);
    final chatDoc = _db.collection('chat').doc(chatId);

    // Set or update chat document
    await chatDoc.set({
      'user1Id': myUserId.compareTo(otherUserId) < 0 ? myUserId : otherUserId,
      'user1Name': myUserId.compareTo(otherUserId) < 0 ? myUsername : otherUsername,
      'user2Id': myUserId.compareTo(otherUserId) < 0 ? otherUserId : myUserId,
      'user2Name': myUserId.compareTo(otherUserId) < 0 ? otherUsername : myUsername,
      'participants': [myUserId, otherUserId],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add message to subcollection
    await chatDoc.collection('messages').add({
      'senderId': myUserId,
      'receiverId': otherUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
