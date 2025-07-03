// import 'package:flutter/material.dart';
//
// class ChatMessages extends StatelessWidget {
//   final String chatPartnerName;
//   final String chatPartnerId;
//   const ChatMessages({Key? key, required this.chatPartnerName, required this.chatPartnerId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const CircleAvatar(
//               backgroundImage: AssetImage('assets/images/placeholder_profile.jpg'),
//             ),
//             const SizedBox(width: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(chatPartnerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                 Text('ID: $chatPartnerId', style: const TextStyle(fontSize: 12, color: Colors.white70)),
//               ],
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF075E54),
//       ),
//       body: ListView(
//         children: [
//           _buildChatTile(chatPartnerName, 'Hey, is the task still available?', '10:30 AM'),
//           _buildChatTile('You', 'Yes, it is!', '10:31 AM'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChatTile(String name, String lastMessage, String time) {
//     return ListTile(
//       leading: const CircleAvatar(
//         backgroundImage: AssetImage('assets/images/placeholder_profile.jpg'),
//       ),
//       title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//       subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
//       trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//       onTap: () {},
//     );
//   }
// }
