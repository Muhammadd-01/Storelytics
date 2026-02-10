import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers.dart';
import '../theme.dart';

class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storesAsync = ref.watch(allStoresProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registered Stores',
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
              'All stores registered on the platform',
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
              child: storesAsync.when(
                data: (stores) {
                  if (stores.isEmpty) {
                    return const Center(child: Text('No stores yet'));
                  }
                  return Card(
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark
                              ? AdminColors.darkSurface
                              : AdminColors.lightSurface,
                        ),
                        columns: const [
                          DataColumn(label: Text('Store Name')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Owner')),
                          DataColumn(label: Text('NIC')),
                          DataColumn(label: Text('Certification')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('Created')),
                        ],
                        rows:
                            stores
                                .map(
                                  (store) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          store.storeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(store.storeType.label)),
                                      DataCell(Text(store.ownerName)),
                                      DataCell(Text(store.ownerNic)),
                                      DataCell(Text(store.certificationNumber)),
                                      DataCell(Text(store.address)),
                                      DataCell(
                                        Text(
                                          DateFormat.yMMMd().format(
                                            store.createdAt,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  );
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
