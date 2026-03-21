import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/shopping_list_item.dart';

class PdfGenerator {
  static Future<void> exportShoppingList(List<ShoppingListItem> items) async {
    final pdf = pw.Document();

    final groupedItems = <String, List<String>>{};
    for (var item in items) {
      if (!groupedItems.containsKey(item.recipeName)) {
        groupedItems[item.recipeName] = [];
      }
      groupedItems[item.recipeName]!.add(item.ingredient);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('My Shopping List', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),
            ]
          );
        },
        build: (context) {
          final List<pw.Widget> children = [];
          
          if (groupedItems.isEmpty) {
            children.add(pw.Text('Your shopping list is empty.'));
          } else {
            groupedItems.forEach((recipeName, ingredients) {
              children.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(recipeName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFFFF6D00))), // Primary color
                      pw.SizedBox(height: 8),
                      ...ingredients.map((ingredient) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ', style: const pw.TextStyle(fontSize: 14)),
                            pw.Expanded(child: pw.Text(ingredient, style: const pw.TextStyle(fontSize: 14))),
                          ]
                        ),
                      )),
                    ]
                  )
                )
              );
            });
          }

          return children;
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Shopping_List.pdf',
    );
  }
}
