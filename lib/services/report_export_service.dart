import 'dart:io';

import 'package:excel_plus/excel_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../app/hrms_app.dart';

class ReportExportService {
  Future<File> exportPdf({required String title, required List<String> headers, required List<List<String>> rows}) async {
    final document = pw.Document();
    document.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (_) => [
      pw.Header(level: 0, child: pw.Text(title)),
      pw.TableHelper.fromTextArray(headers: headers, data: rows),
      pw.SizedBox(height: 12),
      pw.Text('Generated: ${DateTime.now().toLocal()}'),
    ]));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${_safe(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await document.save(), flush: true);
    return file;
  }

  Future<File> exportEmployeeExcel({required List<Employee> employees}) async {
    final excel = Excel.createExcel();
    final sheet = excel['Employees'];
    final headers = ['ID', 'Name', 'Department', 'Designation', 'Phone', 'Email', 'Status', 'Joining Date'];
    for (var c = 0; c < headers.length; c++) sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0), TextCellValue(headers[c]));
    for (var r = 0; r < employees.length; r++) {
      final e = employees[r];
      final values = [e.id, e.name, e.department, e.designation, e.phone, e.email, e.status, e.joiningDate.toIso8601String().split('T').first];
      for (var c = 0; c < values.length; c++) sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1), TextCellValue(values[c]));
    }
    final bytes = excel.save();
    if (bytes == null) throw StateError('Could not create Excel workbook');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/employees_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _safe(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
}
