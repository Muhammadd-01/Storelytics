import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers.dart';
import '../theme.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color:
                    isDark
                        ? AdminColors.darkTextPrimary
                        : AdminColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage registered users and their access',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(child: Text('No users yet'));
                  }
                  return _UsersTable(users: users, isDark: isDark);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<UserModel> users;
  final bool isDark;

  const _UsersTable({required this.users, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? AdminColors.darkSurface : AdminColors.lightSurface,
          ),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((user) => _buildRow(context, user)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, UserModel user) {
    return DataRow(
      cells: [
        DataCell(
          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        DataCell(Text(user.email)),
        DataCell(_RoleBadge(role: user.role)),
        DataCell(Text(user.subscriptionPlan.label)),
        DataCell(_StatusBadge(isActive: user.isActive)),
        DataCell(
          Switch(
            value: user.isActive,
            activeThumbColor: AdminColors.profit,
            onChanged: (value) => _toggleUser(user.uid, value),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleUser(String uid, bool active) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isActive': active,
    });
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color =
        role == UserRole.admin ? AdminColors.accent : AdminColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AdminColors.profit : AdminColors.loss).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Disabled',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AdminColors.profit : AdminColors.loss,
        ),
      ),
    );
  }
}
