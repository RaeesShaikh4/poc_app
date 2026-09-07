import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/product_provider.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/product_card.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          appBar: _buildAppBar(context, isDark),
          body: Column(
            children: [
              if (provider.isOffline)
                ConnectivityBanner(
                  isOffline: provider.isOffline,
                  message: provider.errorMessage,
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _buildSearchBar(context, provider, isDark),
              ),

              // Subheader: Items Count, Sort & Filter buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _buildSubHeader(context, provider, isDark),
              ),

              const SizedBox(height: 6),

              // Product Grid
              Expanded(
                child: _buildBody(context, provider, isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.notes_rounded,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
              onPressed: () {
                // Drawer / Menu trigger
              },
            ),
          ),
        ),
      ),
      title: Text(
        'Stylish',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF4338CA),
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFFFE4E6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFFECDD3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 22,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ProductProvider provider, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppTheme.lightBorder,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: provider.search,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search any Product..',
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF9CA3AF),
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20, color: Color(0xFF9CA3AF)),
                  onPressed: () {
                    _searchController.clear();
                    provider.search('');
                  },
                )
              : const Icon(
                  Icons.mic_none_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context, ProductProvider provider, bool isDark) {
    final count = provider.products.length;
    final countDisplay = provider.selectedCategory != null || provider.searchQuery.isNotEmpty
        ? '$count Items'
        : '52,082+ Items';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Items Count
        Text(
          countDisplay,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
          ),
        ),

        // Sort & Filter Buttons
        Row(
          children: [
            // Sort Button
            _buildActionChip(
              label: 'Sort',
              icon: Icons.swap_vert_rounded,
              isDark: isDark,
              isActive: provider.sortOption != ProductSortOption.defaultSort,
              onTap: () => _showSortModal(context, provider, isDark),
            ),
            const SizedBox(width: 8),

            // Filter Button
            _buildActionChip(
              label: 'Filter',
              icon: Icons.filter_alt_outlined,
              isDark: isDark,
              isActive: provider.selectedCategory != null,
              onTap: () => _showFilterModal(context, provider, isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required bool isDark,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor.withOpacity(0.12)
                : (isDark ? AppTheme.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor
                  : (isDark ? const Color(0xFF334155) : AppTheme.lightBorder),
              width: 1,
            ),
            boxShadow: isDark || isActive
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppTheme.primaryColor
                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? AppTheme.primaryColor
                    : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortModal(BuildContext context, ProductProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                ),
                const Divider(),
                ...ProductSortOption.values.map((option) {
                  final isSelected = provider.sortOption == option;
                  return ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      provider.setSortOption(option);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterModal(BuildContext context, ProductProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      if (provider.selectedCategory != null)
                        TextButton(
                          onPressed: () {
                            provider.selectCategory(null);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset', style: TextStyle(color: AppTheme.primaryColor)),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'All Products',
                    style: TextStyle(
                      fontWeight: provider.selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                      color: provider.selectedCategory == null
                          ? AppTheme.primaryColor
                          : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                    ),
                  ),
                  trailing: provider.selectedCategory == null
                      ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    provider.selectCategory(null);
                    Navigator.pop(ctx);
                  },
                ),
                ...provider.categories.map((cat) {
                  final isSelected = provider.selectedCategory == cat;
                  return ListTile(
                    title: Text(
                      cat.toUpperCase(),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      provider.selectCategory(cat);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider provider, bool isDark) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5),
            SizedBox(height: 16),
            Text('Loading trending products...'),
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
                provider.isOffline ? Icons.wifi_off_rounded : Icons.search_off_rounded,
                size: 60,
                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 14),
              Text(
                provider.searchQuery.isNotEmpty
                    ? 'No products matched "${provider.searchQuery}"'
                    : (provider.errorMessage ?? 'No products available'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.fetchProducts(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchProducts(forceRefresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
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
