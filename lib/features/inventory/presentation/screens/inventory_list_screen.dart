import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storelytics/core/extensions.dart';
import 'package:storelytics/features/auth/presentation/providers/auth_providers.dart';
import 'package:storelytics/features/inventory/data/models/inventory_item_model.dart';
import 'package:storelytics/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:storelytics/shared/widgets/common_widgets.dart';
import 'package:storelytics/theme/app_colors.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

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

        final storeId = user.storeId!;
        final selectedCategory = ref.watch(selectedCategoryProvider);
        final searchQuery = ref.watch(inventorySearchQueryProvider);

        final itemsAsync =
            selectedCategory != null
                ? ref.watch(
                  inventoryByCategoryProvider((
                    storeId: storeId,
                    category: selectedCategory,
                  )),
                )
                : ref.watch(inventoryListProvider(storeId));

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
              'Inventory',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed:
                    () => showSearch(
                      context: context,
                      delegate: _InventorySearchDelegate(storeId, ref),
                    ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/inventory/add'),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Product',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  _CategoryChips(storeId: storeId),
                  const SizedBox(height: 12),
                  Expanded(
                    child: itemsAsync.when(
                      loading: () => const AppLoadingWidget(),
                      error: (e, _) => AppErrorWidget(message: e.toString()),
                      data: (items) {
                        final filtered =
                            searchQuery.isEmpty
                                ? items
                                : items
                                    .where(
                                      (i) => i.name.toLowerCase().contains(
                                        searchQuery.toLowerCase(),
                                      ),
                                    )
                                    .toList();

                        if (filtered.isEmpty) {
                          return const EmptyStateWidget(
                            icon: Icons.inventory_2_outlined,
                            title: 'Empty Inventory',
                            subtitle: 'Start by adding some products',
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            10,
                            20,
                            120,
                          ), // Increased bottom padding
                          itemCount: filtered.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _InventoryItemTile(item: filtered[index]);
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

class _CategoryChips extends ConsumerWidget {
  final String storeId;
  const _CategoryChips({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider(storeId));
    final selected = ref.watch(selectedCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 50),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ModernFilterChip(
                label: 'All Products',
                isSelected: selected == null,
                onSelected:
                    () =>
                        ref.read(selectedCategoryProvider.notifier).state =
                            null,
                isDark: isDark,
              ),
              ...categories.map(
                (cat) => _ModernFilterChip(
                  label: cat,
                  isSelected: selected == cat,
                  onSelected:
                      () =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              selected == cat ? null : cat,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isDark;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.secondary,
        labelStyle: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor:
            isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        elevation: isSelected ? 4 : 0,
        pressElevation: 8,
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final InventoryItem item;
  const _InventoryItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/inventory/${item.itemId}', extra: item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image / Placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  image:
                      item.imageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(item.imageUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    item.imageUrl == null
                        ? const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.secondary,
                          size: 30,
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.category} • ${item.sellingPrice.toCurrency}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStockIndicator(item),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(InventoryItem item) {
    final color =
        item.isOutOfStock
            ? AppColors.loss
            : item.isLowStock
            ? AppColors.warning
            : AppColors.profit;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '${item.stockQuantity} in stock',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InventorySearchDelegate extends SearchDelegate<String> {
  final String storeId;
  final WidgetRef ref;

  _InventorySearchDelegate(this.storeId, this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search products',
        subtitle: 'Find items by name or category',
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final results = ref.watch(
          inventorySearchProvider((storeId: storeId, query: query)),
        );
        return results.when(
          loading: () => const AppLoadingWidget(),
          error: (e, _) => AppErrorWidget(message: e.toString()),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'No products found',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _InventoryItemTile(item: items[i]),
            );
          },
        );
      },
    );
  }
}
