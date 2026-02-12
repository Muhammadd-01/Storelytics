import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/demand/data/models/demand_model.dart';
import 'package:storelytics/features/demand/presentation/providers/demand_providers.dart';
import 'package:storelytics/shared/widgets/app_text_field.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/core/validators.dart';
import 'package:storelytics/theme/app_colors.dart';
import 'package:storelytics/theme/app_spacing.dart';

class DemandListScreen extends ConsumerWidget {
  const DemandListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoadingWidget()),
      error: (e, _) => Scaffold(body: AppErrorWidget(message: e.toString())),
      data: (user) {
        if (user == null || user.currentStoreId == null) {
          return const Scaffold(
            body: EmptyStateWidget(icon: Icons.store, title: 'No store'),
          );
        }

        final demandsAsync = ref.watch(
          demandStreamProvider(user.currentStoreId!),
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            title: const Text('Demand Log'),
          ),
          floatingActionButtonLocation: const RaisedFabLocation(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed:
                () => _showAddDemandDialog(context, ref, user.currentStoreId!),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Log Demand'),
          ),
          body: demandsAsync.when(
            loading: () => const AppLoadingWidget(),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (demands) {
              if (demands.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.trending_up_outlined,
                  title: 'No demand logs',
                  subtitle:
                      'Log items that customers request but are unavailable',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  150,
                ),
                itemCount: demands.length,
                itemBuilder: (context, index) {
                  final demand = demands[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${demand.timesRequested}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        demand.itemName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${demand.timesRequested} requests • ${demand.date.formatted}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.secondary,
                            ),
                            onPressed:
                                () => ref
                                    .read(demandRepositoryProvider)
                                    .incrementDemand(demand.demandId, 1),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.loss,
                              size: 20,
                            ),
                            onPressed:
                                () => ref
                                    .read(demandRepositoryProvider)
                                    .deleteDemand(demand.demandId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showAddDemandDialog(
    BuildContext context,
    WidgetRef ref,
    String storeId,
  ) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Log Missing Item Demand'),
            content: Form(
              key: formKey,
              child: AppTextField(
                controller: nameController,
                label: 'Item Name',
                hint: 'Item requested by customer',
                validator: (v) => Validators.required(v, 'Item name'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final name = nameController.text.trim();

                  // Check for existing
                  final existing = await ref
                      .read(demandRepositoryProvider)
                      .getDemandByItemName(storeId, name);
                  if (existing != null) {
                    await ref
                        .read(demandRepositoryProvider)
                        .incrementDemand(existing.demandId, 1);
                  } else {
                    await ref
                        .read(demandRepositoryProvider)
                        .addDemand(
                          DemandModel(
                            demandId: const Uuid().v4(),
                            storeId: storeId,
                            itemName: name,
                            timesRequested: 1,
                            date: DateTime.now(),
                            createdAt: DateTime.now(),
                          ),
                        );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
