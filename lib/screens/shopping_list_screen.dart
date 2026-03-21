// shopping_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/recipe_provider.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  Future<void> _exportPdf(
    BuildContext context,
    Map<String, List<String>> list,
  ) async {
    final pdf = pw.Document();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "My Shopping List",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("Date: $date"),
            pw.Divider(),
            ...list.entries
                .map(
                  (entry) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          entry.key,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      ...entry.value.map((item) => pw.Bullet(text: item)),
                    ],
                  ),
                )
                ,
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final items = provider.shoppingList;

    return Scaffold(
      appBar: AppBar(title: Text("Shopping List")),
      body: items.isEmpty
          ? Center(
              child: Text(
                "Your shopping list is empty! Start adding ingredients.",
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _exportPdf(context, items),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text("Export"),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                      ),
                      onPressed: () => provider.clearShoppingList(),
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text(
                        "Clear All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: items.entries
                        .map(
                          (entry) => ExpansionTile(
                            title: Text(
                              entry.key,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            initiallyExpanded: true,
                            children: entry.value
                                .map(
                                  (ing) => ListTile(
                                    title: Text(ing),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_circle_outline),
                                      onPressed: () => provider
                                          .toggleIngredient(entry.key, ing),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
