import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/product_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/product_card.dart';
import '../widgets/sync_status_badge.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = sl<AppConfig>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(config.appName),
                      Text(
                        'FakeStore API • Retrofit & Hive Offline-First',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: config.environment.isDev
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: config.environment.isDev ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    config.environment.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: config.environment.isDev ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear Offline Hive Cache',
                onPressed: () async {
                  await provider.clearLocalCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hive Offline Cache Cleared!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Force Refresh (API)',
                onPressed: () => provider.fetchProducts(forceRefresh: true),
              ),
            ],
          ),
          body: Column(
            children: [
              ConnectivityBanner(
                isOffline: provider.isOffline,
                message: provider.errorMessage,
              ),
              // Search Bar & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: provider.search,
                      decoration: InputDecoration(
                        hintText: 'Search products, electronics, clothing...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.search('');
                                },
                              )
                            : null,
                      ),
                    ),
                    if (provider.categories.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CategoryChip(
                              label: 'All',
                              isSelected: provider.selectedCategory == null,
                              onTap: () => provider.selectCategory(null),
                            ),
                            ...provider.categories.map(
                              (cat) => CategoryChip(
                                label: cat,
                                isSelected: provider.selectedCategory == cat,
                                onTap: () => provider.selectCategory(cat),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SyncStatusBadge(
                          isFromCache: provider.isFromCache,
                          isOffline: provider.isOffline,
                        ),
                        Text(
                          '${provider.products.length} ${provider.products.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Products Grid
              Expanded(
                child: _buildBody(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching products via Retrofit...'),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                provider.isOffline ? Icons.wifi_off_rounded : Icons.shopping_bag_outlined,
                size: 64,
                color: AppTheme.darkTextSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'No products matched "${provider.searchQuery}"'
                    : (provider.errorMessage ?? 'No products available'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.fetchProducts(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry / Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchProducts(forceRefresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: provider.products.length,
        itemBuilder: (context, index) {
          final product = provider.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              context.push('/products/${product.id}');
            },
          );
        },
      ),
    );
  }
}
