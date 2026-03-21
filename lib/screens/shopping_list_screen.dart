import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../utils/constants.dart';
import '../utils/pdf_generator.dart';
import '../widgets/empty_state.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isExporting = false;

  void _exportPdf(BuildContext context) async {
    final provider = context.read<ShoppingListProvider>();
    if (provider.items.isEmpty) return;

    setState(() {
      _isExporting = true;
    });

    try {
      await PdfGenerator.exportShoppingList(provider.items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context),
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              context.read<ShoppingListProvider>().clearList();
            },
            tooltip: 'Clear List',
          ),
        ],
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, child) {
          if (provider.items.isEmpty) {
            return const EmptyState(
              title: 'Your List is Empty',
              message: 'Mark ingredients you don\'t have while browsing recipes, and they will appear here.',
              icon: Icons.shopping_basket_outlined,
            );
          }

          final groupedItems = <String, List<String>>{};
          for (var item in provider.items) {
            if (!groupedItems.containsKey(item.recipeName)) {
              groupedItems[item.recipeName] = [];
            }
            groupedItems[item.recipeName]!.add(item.ingredient);
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                  final recipeName = groupedItems.keys.elementAt(index);
                  final ingredients = groupedItems.values.elementAt(index);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipeName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const Divider(),
                          ...ingredients.map((ingredient) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textLight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_isExporting)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Generating PDF...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
