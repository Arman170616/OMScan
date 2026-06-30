import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cart_item.dart';
import '../utils/formatter.dart';

class InvoiceService {
  static Future<void> downloadInvoice(Order order) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontSemiBold = await PdfGoogleFonts.interSemiBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('OMSCAN',
                          style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 28,
                              color: PdfColor.fromHex('#1D4ED8'))),
                      pw.SizedBox(height: 4),
                      pw.Text('Omani Mobile POS System',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 11,
                              color: PdfColor.fromHex('#6B7280'))),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE',
                          style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 20,
                              color: PdfColor.fromHex('#111827'))),
                      pw.SizedBox(height: 4),
                      pw.Text(formatOrderId(order.id),
                          style: pw.TextStyle(
                              font: fontSemiBold,
                              fontSize: 13,
                              color: PdfColor.fromHex('#1D4ED8'))),
                      pw.SizedBox(height: 2),
                      pw.Text(formatDateTime(order.createdAt),
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColor.fromHex('#6B7280'))),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColor.fromHex('#E5E7EB'), thickness: 1),
              pw.SizedBox(height: 16),

              // Payment method chip
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#EFF6FF'),
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(
                          color: PdfColor.fromHex('#BFDBFE'), width: 1),
                    ),
                    child: pw.Text('Payment: ${order.paymentMethod}',
                        style: pw.TextStyle(
                            font: fontSemiBold,
                            fontSize: 10,
                            color: PdfColor.fromHex('#1D4ED8'))),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Items table header
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.only(
                    topLeft: const pw.Radius.circular(6),
                    topRight: const pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 5,
                        child: pw.Text('PRODUCT',
                            style: pw.TextStyle(
                                font: fontSemiBold,
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: PdfColor.fromHex('#6B7280')))),
                    pw.SizedBox(
                        width: 60,
                        child: pw.Text('QTY',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                font: fontSemiBold,
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: PdfColor.fromHex('#6B7280')))),
                    pw.SizedBox(
                        width: 80,
                        child: pw.Text('PRICE',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                font: fontSemiBold,
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: PdfColor.fromHex('#6B7280')))),
                    pw.SizedBox(
                        width: 90,
                        child: pw.Text('TOTAL',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                font: fontSemiBold,
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: PdfColor.fromHex('#6B7280')))),
                  ],
                ),
              ),

              // Items
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#E5E7EB'), width: 1),
                  borderRadius: pw.BorderRadius.only(
                    bottomLeft: const pw.Radius.circular(6),
                    bottomRight: const pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  children: order.items.asMap().entries.map((e) {
                    final item = e.value;
                    final isLast = e.key == order.items.length - 1;
                    return pw.Column(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 5,
                                child: pw.Text(item.product.name,
                                    style: pw.TextStyle(
                                        font: fontSemiBold,
                                        fontSize: 11,
                                        color:
                                            PdfColor.fromHex('#111827'))),
                              ),
                              pw.SizedBox(
                                width: 60,
                                child: pw.Text('${item.quantity}',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                        font: font,
                                        fontSize: 11,
                                        color:
                                            PdfColor.fromHex('#374151'))),
                              ),
                              pw.SizedBox(
                                width: 80,
                                child: pw.Text(
                                    formatCurrency(item.product.price),
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                        font: font,
                                        fontSize: 11,
                                        color:
                                            PdfColor.fromHex('#374151'))),
                              ),
                              pw.SizedBox(
                                width: 90,
                                child: pw.Text(
                                    formatCurrency(item.subtotal),
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                        font: fontSemiBold,
                                        fontSize: 11,
                                        color:
                                            PdfColor.fromHex('#111827'))),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          pw.Divider(
                              color: PdfColor.fromHex('#F3F4F6'),
                              thickness: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

              pw.SizedBox(height: 12),

              // Total row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#EFF6FF'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(
                          color: PdfColor.fromHex('#BFDBFE'), width: 1),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text('TOTAL  ',
                            style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 13,
                                color: PdfColor.fromHex('#374151'))),
                        pw.Text(formatCurrency(order.total),
                            style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 18,
                                color: PdfColor.fromHex('#1D4ED8'))),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColor.fromHex('#E5E7EB'), thickness: 1),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('Thank you for your purchase!',
                    style: pw.TextStyle(
                        font: fontSemiBold,
                        fontSize: 11,
                        color: PdfColor.fromHex('#1D4ED8'))),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text('Generated by OMScan POS',
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 9,
                        color: PdfColor.fromHex('#9CA3AF'))),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Invoice_${formatOrderId(order.id)}.pdf',
    );
  }
}
