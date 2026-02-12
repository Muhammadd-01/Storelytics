import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storelytics/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  /// Stream notifications for a specific store
  Stream<List<NotificationModel>> streamNotifications(String storeId) {
    return _collection
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data()))
              .toList();
        });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _collection.doc(notificationId).update({'isRead': true});
  }

  /// Mark all as read
  Future<void> markAllAsRead(String storeId) async {
    final batch = _firestore.batch();
    final snapshot =
        await _collection
            .where('storeId', isEqualTo: storeId)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _collection.doc(notificationId).delete();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, storeId) {
      return ref
          .watch(notificationRepositoryProvider)
          .streamNotifications(storeId);
    });

final unreadNotificationsCountProvider = Provider.family<int, String>((
  ref,
  storeId,
) {
  final notificationsAsync = ref.watch(notificationStreamProvider(storeId));
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
