import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image container
              Expanded(
                flex: 11,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                  child: Container(
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.all(10),
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Product Info section
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title & Subtitle/Description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),

                      // Price and Rating Row
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          _buildRatingRow(isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(bool isDark) {
    final double rating = product.ratingRate;
    final int filledStars = rating.floor().clamp(0, 5);
    final bool hasHalfStar = (rating - filledStars) >= 0.5 && filledStars < 5;

    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < filledStars
                ? Icons.star_rounded
                : (i == filledStars && hasHalfStar ? Icons.star_half_rounded : Icons.star_border_rounded),
            size: 13,
            color: (i < filledStars || (i == filledStars && hasHalfStar))
                ? AppTheme.starColor
                : (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
          ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            _formatCount(product.ratingCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 100000) {
      final inLakh = count / 100000;
      return '${inLakh.toStringAsFixed(1)}L';
    } else if (count >= 1000) {
      final inK = count / 1000;
      return '${inK.toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
