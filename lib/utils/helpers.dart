import 'package:cloud_firestore/cloud_firestore.dart';

String formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return 'Just now';
  final dateTime = timestamp.toDate();
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else {
    return '${difference.inDays}d';
  }
}
