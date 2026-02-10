import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/sales/presentation/providers/sales_providers.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/theme/app_colors.dart';

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoadingWidget()),
      error: (e, _) => Scaffold(body: AppErrorWidget(message: e.toString())),
      data: (user) {
        if (user == null || user.storeId == null) {
          return const Scaffold(
            body: EmptyStateWidget(icon: Icons.store, title: 'No store'),
          );
        }

        final salesAsync = ref.watch(salesStreamProvider(user.storeId!));

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.white60,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => context.go('/'),
                ),
              ),
            ),
            title: const Text(
              'Sales History',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/sales/record'),
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 100),
                  Expanded(
                    child: salesAsync.when(
                      loading: () => const AppLoadingWidget(),
                      error: (e, _) => AppErrorWidget(message: e.toString()),
                      data: (sales) {
                        if (sales.isEmpty) {
                          return const EmptyStateWidget(
                            icon: Icons.receipt_long_rounded,
                            title: 'No sales history',
                            subtitle: 'Your transactions will appear here',
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            10,
                            20,
                            120,
                          ), // Increased bottom padding
                          itemCount: sales.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final sale = sales[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    isDark ? AppColors.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: (sale.profit >= 0
                                            ? AppColors.profit
                                            : AppColors.loss)
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      sale.profit >= 0
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      color:
                                          sale.profit >= 0
                                              ? AppColors.profit
                                              : AppColors.loss,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sale.itemName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${sale.quantity} units • ${sale.date.formatted}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDark
                                                    ? Colors.white60
                                                    : Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        sale.revenue.toCurrency,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${sale.profit >= 0 ? "+" : ""}${sale.profit.toCurrency}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              sale.profit >= 0
                                                  ? AppColors.profit
                                                  : AppColors.loss,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
