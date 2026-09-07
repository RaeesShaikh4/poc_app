import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poc_mcp_app/features/products/domain/entities/product_entity.dart';
import 'package:poc_mcp_app/features/products/presentation/widgets/category_chip.dart';
import 'package:poc_mcp_app/features/products/presentation/widgets/product_card.dart';
import 'package:poc_mcp_app/features/products/presentation/widgets/sync_status_badge.dart';

void main() {
  group('Widget Smoke Tests', () {
    testWidgets('CategoryChip renders and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: 'Electronics',
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ELECTRONICS'), findsOneWidget);
      await tester.tap(find.text('ELECTRONICS'));
      expect(tapped, isTrue);
    });

    testWidgets('SyncStatusBadge renders correct status for cache', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              isFromCache: true,
              isOffline: false,
            ),
          ),
        ),
      );

      expect(find.text('Loaded from Hive Cache'), findsOneWidget);
      expect(find.byIcon(Icons.storage_rounded), findsOneWidget);
    });

    testWidgets('SyncStatusBadge renders correct status for offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncStatusBadge(
              isFromCache: true,
              isOffline: true,
            ),
          ),
        ),
      );

      expect(find.text('Offline Mode (Hive Cache)'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('ProductCard renders product title, price, and description', (WidgetTester tester) async {
      bool tapped = false;
      const testProduct = ProductEntity(
        id: 1,
        title: 'Black Winter Hoodie',
        price: 499.0,
        description: 'Autumn And Winter Casual cotton-padded jacket',
        category: 'clothing',
        image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
        ratingRate: 4.5,
        ratingCount: 6890,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ProductCard(
                product: testProduct,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Black Winter Hoodie'), findsOneWidget);
      expect(find.text('₹499'), findsOneWidget);
      expect(find.text('Autumn And Winter Casual cotton-padded jacket'), findsOneWidget);

      await tester.tap(find.text('Black Winter Hoodie'));
      expect(tapped, isTrue);
    });
  });
}
