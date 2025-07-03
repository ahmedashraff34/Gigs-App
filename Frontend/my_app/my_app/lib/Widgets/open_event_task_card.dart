// import 'package:flutter/material.dart';
// import '../models/task_response.dart';
//
// class OpenEventTaskCard extends StatelessWidget {
//   final TaskResponse eventTask;
//   final VoidCallback? onTap;
//
//   const OpenEventTaskCard({
//     Key? key,
//     required this.eventTask,
//     this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(18),
//         child: Padding(
//           padding: const EdgeInsets.all(18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title
//               Text(
//                 eventTask.title,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
//               ),
//               const SizedBox(height: 6),
//               // Type, Pay, People
//               Row(
//                 children: [
//                   Flexible(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.secondary,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         eventTask.type ?? '',
//                         style: TextStyle(
//                           color: theme.colorScheme.primary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.attach_money, size: 16, color: theme.colorScheme.primary),
//                         Text(
//                           eventTask.fixedPay?.toStringAsFixed(0) ?? '',
//                           style: TextStyle(
//                             color: theme.colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text('People: ${eventTask.requiredPeople ?? ''}', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               // Description
//               Text(
//                 eventTask.description,
//                 style: TextStyle(fontSize: 15, color: theme.colorScheme.primary.withOpacity(0.85)),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: true,
//               ),
//               const SizedBox(height: 10),
//               // Location
//               Row(
//                 children: [
//                   Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
//                   const SizedBox(width: 4),
//                   Text(eventTask.location ?? '', style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7), fontSize: 14)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // Dates
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
//                   const SizedBox(width: 4),
//                   Text('From: ${eventTask.startDate ?? ''} To: ${eventTask.endDate ?? ''}', style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7), fontSize: 14)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // Status
//               Row(
//                 children: [
//                   Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
//                   const SizedBox(width: 4),
//                   Text('Status: ${eventTask.status}', style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7), fontSize: 14)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
