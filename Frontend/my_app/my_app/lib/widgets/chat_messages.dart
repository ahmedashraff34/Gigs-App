import 'package:ali_grad/constants/theme.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatUser {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastTimestamp;

  ChatUser({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastTimestamp,
  });
}

class ChatMessages extends StatelessWidget {
  final List<ChatUser> users;
  final void Function(ChatUser user) onChatTap;
  const ChatMessages({Key? key, required this.users, required this.onChatTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Chats"),
      body: users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/no_chats.svg',
                    width: 100,
                    height: 100,
                    semanticsLabel: 'Logo',
                  ),
                  SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final user = users[i];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () => onChatTap(user),
                    leading: user.avatarUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.avatarUrl!),
                            radius: 28,
                          )
                        : CircleAvatar(
                            radius: 28,
                            child: Text(user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : '?'),
                          ),
                    title: Text(
                      user.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 17),
                    ),
                    subtitle: Text(
                      user.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    trailing: Text(
                      _formatTime(user.lastTimestamp),
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    tileColor: Colors.white,
                    hoverColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.04),
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      // Today
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      // Show date
      return '${time.month}/${time.day}';
    }
  }
}
