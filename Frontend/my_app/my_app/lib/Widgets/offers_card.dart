import 'package:flutter/material.dart';
import '../Screens/Chat_messages.dart';
import '../Screens/chat_page.dart';
import '../services/token_service.dart';
import '../services/task_service.dart';
import '../models/offer.dart';

// OffersCard widget for displaying offer information
class OffersCard extends StatelessWidget {
  final String profileImage;
  final String runnerName;
  final String? runnerId;
  final double amount;
  final String message;
  final DateTime timestamp;
  final double rating;
  final VoidCallback? onAccept;
  final VoidCallback? onChat;
  final String? offerId;
  final String? taskId;
  final int? taskPosterId;
  final OfferStatus? status;

  const OffersCard({
    Key? key,
    this.profileImage = 'https://via.placeholder.com/50',
    this.runnerName = 'John Doe',
    this.runnerId,
    this.amount = 0.0,
    this.message = '',
    required this.timestamp,
    this.rating = 4.5,
    this.onAccept,
    this.onChat,
    this.offerId,
    this.taskId,
    this.taskPosterId,
    this.status,
  }) : super(key: key);

  bool get _canAcceptOffer {
    return status == null || status == OfferStatus.PENDING;
  }

  Color _getStatusColor() {
    switch (status) {
      case OfferStatus.ACCEPTED:
        return Colors.green;
      case OfferStatus.CANCELLED:
        return Colors.red;
      case OfferStatus.AWAITING_PAYMENT:
        return Colors.orange;
      case OfferStatus.PENDING:
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (status) {
      case OfferStatus.ACCEPTED:
        return 'Accepted';
      case OfferStatus.CANCELLED:
        return 'Cancelled';
      case OfferStatus.AWAITING_PAYMENT:
        return 'Awaiting Payment';
      case OfferStatus.PENDING:
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(profileImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    runnerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _canAcceptOffer && onAccept != null ? onAccept : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Accept Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
