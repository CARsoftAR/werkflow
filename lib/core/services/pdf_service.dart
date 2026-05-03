import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/models.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<pw.Document> _buildDocument(Presupuesto budget, Cliente client, BusinessInfo? business) async {
    final pdf = pw.Document();
    final businessInfo = business ?? BusinessInfo(
      name: 'Electricista Dante',
      phone: '1550432855',
      email: 'info@electricistasur.com',
      website: 'www.electricistasur.com',
      address: 'Av. 12 de Octubre 620, Quilmes',
      footerTitle: 'Términos & y condiciones',
      footerText: 'Los presupuestos tienen una validez de 15 días desde la emisión del mismo...',
    );

    pw.Font f900;
    pw.Font f700;
    pw.Font f400;
    
    try {
      f900 = await PdfGoogleFonts.interBlack().timeout(const Duration(seconds: 5));
      f700 = await PdfGoogleFonts.interBold().timeout(const Duration(seconds: 5));
      f400 = await PdfGoogleFonts.interRegular().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("Font loading failed or timed out: $e");
      f900 = pw.Font.helveticaBold();
      f700 = pw.Font.helveticaBold();
      f400 = pw.Font.helvetica();
    }

    pw.MemoryImage? headerImage;
    try {
      if (businessInfo.headerImagePath != null && businessInfo.headerImagePath!.isNotEmpty) {
        String path = businessInfo.headerImagePath!;
        if (path.startsWith('file://')) {
          path = path.substring(7);
        }
        final file = File(path);
        if (file.existsSync()) {
          headerImage = pw.MemoryImage(file.readAsBytesSync());
        }
      }
    } catch (e) {
      debugPrint("Image loading error: $e");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Container(
              width: double.infinity,
              child: pw.Stack(
                alignment: pw.Alignment.topRight,
                children: [
                  if (headerImage != null)
                    pw.ConstrainedBox(
                      constraints: const pw.BoxConstraints(maxHeight: 200),
                      child: pw.Image(headerImage, fit: pw.BoxFit.fitWidth),
                    )
                  else
                    pw.Container(
                      height: 120,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(businessInfo.name, style: pw.TextStyle(font: f900, fontSize: 22)),
                          pw.SizedBox(height: 4),
                          pw.Text(businessInfo.address, style: pw.TextStyle(font: f700, fontSize: 10)),
                          pw.Text(businessInfo.phone, style: pw.TextStyle(font: f700, fontSize: 10)),
                        ],
                      ),
                    ),
                  
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Text('Presupuesto', style: pw.TextStyle(font: f900, fontSize: 32, color: headerImage != null ? PdfColors.white : PdfColors.black)),
                  ),
                ],
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('COBRAR A', style: pw.TextStyle(font: f900, fontSize: 14)),
                        pw.Text(client.nombre, style: pw.TextStyle(font: f700, fontSize: 12)),
                        if (client.cuitDireccion != null) 
                          pw.Text(client.cuitDireccion!, style: pw.TextStyle(font: f400, fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Nº DE PRESUPUESTO', 'EST${budget.id?.toString().padLeft(5, '0') ?? '00000'}', f900, f400),
                        _buildInfoRow('FECHA', DateFormat('dd/MM/yyyy').format(budget.fecha), f900, f400),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.black),
                    children: [
                      _buildTableCell('Descripción', f900, color: PdfColors.white, padding: 8),
                      _buildTableCell('CANT.', f900, color: PdfColors.white, padding: 8, align: pw.TextAlign.center),
                      _buildTableCell('Precio', f900, color: PdfColors.white, padding: 8, align: pw.TextAlign.right),
                      _buildTableCell('Importe', f900, color: PdfColors.white, padding: 8, align: pw.TextAlign.right),
                    ],
                  ),
                  ...budget.items.map((item) => pw.TableRow(
                    children: [
                      _buildTableCell(item.descripcion, f400, padding: 8),
                      _buildTableCell(item.cantidad.toStringAsFixed(0), f400, padding: 8, align: pw.TextAlign.center),
                      _buildTableCell('\$${item.precioUnitario.toStringAsFixed(2)}', f400, padding: 8, align: pw.TextAlign.right),
                      _buildTableCell('\$${item.subtotal.toStringAsFixed(2)}', f400, padding: 8, align: pw.TextAlign.right),
                    ],
                  )),
                ],
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            color: PdfColors.black,
                            child: pw.Text('TOTAL', style: pw.TextStyle(font: f900, color: PdfColors.white, fontSize: 16)),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            color: PdfColors.black,
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('\$${budget.totalGeneral.toStringAsFixed(2)}', style: pw.TextStyle(font: f900, color: PdfColors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(businessInfo.footerTitle, style: pw.TextStyle(font: f900, fontSize: 13)),
                  pw.SizedBox(height: 4),
                  pw.Text(businessInfo.footerText, style: pw.TextStyle(font: f400, fontSize: 10), maxLines: 4),
                  pw.SizedBox(height: 20),
                  // DECORATIVE BAR
                  pw.Container(
                    height: 5,
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 3, child: pw.Container(color: const PdfColor.fromInt(0xFF1B1B1E))),
                        pw.Expanded(flex: 1, child: pw.Container(color: const PdfColor.fromInt(0xFFEF233C))),
                        pw.Expanded(flex: 2, child: pw.Container(color: const PdfColor.fromInt(0xFFFFC300))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    return pdf;
  }

  static Future<void> generateAndPrintBudget(Presupuesto budget, Cliente client, BusinessInfo? business) async {
    try {
      final pdf = await _buildDocument(budget, client, business);
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      throw Exception("Error layout: $e");
    }
  }

  static Future<String> generateBudgetFile(Presupuesto budget, Cliente client, BusinessInfo? business) async {
    try {
      final pdf = await _buildDocument(budget, client, business);
      final bytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final fileName = 'Presupuesto_EST${budget.id ?? "NEW"}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      throw Exception("Error saving PDF: $e");
    }
  }


  static pw.Widget _buildInfoRow(String label, String value, pw.Font fontLabel, pw.Font fontValue) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: fontLabel, fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(font: fontValue, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {PdfColor color = PdfColors.black, double padding = 4, pw.TextAlign align = pw.TextAlign.left, double fontSize = 9}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(padding),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize, color: color),
        textAlign: align,
      ),
    );
  }
}
