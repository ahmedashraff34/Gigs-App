import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? avatarUrl;
  final String? username;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.avatarUrl,
    this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? Theme.of(context).colorScheme.primary.withOpacity(0.85)
        : Colors.grey.shade200;
    final textColor = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && avatarUrl != null)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(avatarUrl!),
              backgroundColor: Colors.grey.shade300,
            ),
          if (!isMe && avatarUrl == null)
            CircleAvatar(
              radius: 16,
              child: username != null && username!.isNotEmpty
                  ? Text(username![0].toUpperCase())
                  : const Icon(Icons.person, size: 16),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (username != null && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      username!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(
                    DateFormat('h:mm a').format(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
