import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/recipe_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isExporting = false;

  Future<void> _sharePdf(Map<String, List<String>> list) async {
    setState(() => _isExporting = true);

    try {
      final pdf = pw.Document();
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Use MultiPage to handle long lists across multiple sheets
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                "My Shopping List",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text("Generated on: $date"),
            pw.Divider(),
            ...list.entries.map(
              (entry) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entry.value.map((item) => pw.Bullet(text: item)),
                  pw.SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      );

      // sharePdf opens the native system share sheet directly
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'shopping_list_$date.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating PDF: $e")));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final items = provider.shoppingList;

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),
      body: items.isEmpty
          ? const Center(child: Text("Your shopping list is empty!"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Updated Share Button
                      ElevatedButton.icon(
                        onPressed: _isExporting ? null : () => _sharePdf(items),
                        icon: _isExporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.share),
                        label: const Text("Share PDF"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => provider.clearShoppingList(),
                        icon: const Icon(Icons.delete),
                        label: const Text("Clear All"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: items.entries.map((entry) {
                      return ExpansionTile(
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        initiallyExpanded: true,
                        children: entry.value.map((ing) {
                          return ListTile(
                            title: Text(ing),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  provider.toggleIngredient(entry.key, ing),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
