import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:billing_app/core/utils/money_format.dart';
import 'package:intl/intl.dart';
import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  /// Double height, single width — slight emphasis for shop name on thermal printers.
  static const List<int> textDoubleHeight = [0x1D, 0x21, 0x01];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> forceTextMode = [0x1B, 0x21, 0x00];
  static const List<int> cancelChineseMode = [0x1C, 0x2E];
  static const List<int> setInternationalCharsetUsa = [0x1B, 0x52, 0x00];
  static const List<int> lineFeed = [0x0A];

  static const int codeTablePc858 = 19;
  static const int codeTableWpc1258 = 52;

  static List<int> selectCodeTable(int codeTable) => [0x1B, 0x74, codeTable];
}

class PrinterHelper {
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _isConnected = !result;
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> printText(String text) async {
    if (!_isConnected) return;

    final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (!connectionStatus) return;

    final List<int> bytes = _buildVietnameseTextModeSetup();
    _appendEncodedText(bytes, text);
    await PrintBluetoothThermal.writeBytes(bytes);
  }

  /// Normal thermal paper width in dots (58mm printers).
  static const int _thermalBitmapWidthPx = 384;

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items, // Name, Qty, Price, Total
    required double total,
    required String footer,
    required String invoiceTitle,
    required String invoiceCodePrefix,
    required String sellerLabel,
    required String buyerLabel,
    required String signatureNote,
    required String logoImagePath,
    String? invoiceId,
    int? invoiceSequence,
    DateTime? createdAt,
  }) async {
    if (!_isConnected) return;
    final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (!connectionStatus) return;

    List<int> bytes = _buildVietnameseTextModeSetup();

    bytes += EscPos.alignLeft;
    final _ReceiptParts parts = _buildReceiptParts(
      shopName: shopName,
      address1: address1,
      address2: address2,
      phone: phone,
      items: items,
      total: total,
      footer: footer,
      createdAt: createdAt,
      invoiceTitle: invoiceTitle,
      invoiceCodePrefix: invoiceCodePrefix,
      invoiceId: invoiceId,
      invoiceSequence: invoiceSequence,
    );
    _ReceiptLineAlign? lastAlign;
    for (final line in parts.beforeTable) {
      if (lastAlign != line.align) {
        switch (line.align) {
          case _ReceiptLineAlign.left:
            bytes += EscPos.alignLeft;
            break;
          case _ReceiptLineAlign.center:
            bytes += EscPos.alignCenter;
            break;
          case _ReceiptLineAlign.right:
            bytes += EscPos.alignRight;
            break;
        }
        lastAlign = line.align;
      }
      if (line.style == _ReceiptLineStyle.shopName) {
        bytes += EscPos.boldOn;
        bytes += EscPos.textDoubleHeight;
        _appendEncodedText(bytes, line.text);
        bytes += EscPos.lineFeed;
        bytes += EscPos.textNormal;
        bytes += EscPos.boldOff;
      } else if (line.style == _ReceiptLineStyle.invoiceTitle) {
        bytes += EscPos.boldOn;
        bytes += EscPos.textLarge;
        _appendEncodedText(bytes, line.text);
        bytes += EscPos.lineFeed;
        bytes += EscPos.textNormal;
        bytes += EscPos.boldOff;
      } else {
        _appendEncodedText(bytes, line.text);
        bytes += EscPos.lineFeed;
      }
    }

    bytes += EscPos.alignLeft;
    final ui.Image? tableBitmap = await _renderSolidTableImage(
      widthPx: _thermalBitmapWidthPx,
      items: items,
      total: total,
      cellFontSize: 16,
      headerFontSize: 16,
      cellPadding: 5,
      borderWidth: 1.8,
    );
    if (tableBitmap != null) {
      try {
        bytes += await _escPosRasterBitmap(tableBitmap);
        bytes += EscPos.lineFeed;
      } finally {
        tableBitmap.dispose();
      }
    }

    for (final line in parts.afterTable) {
      if (lastAlign != line.align) {
        switch (line.align) {
          case _ReceiptLineAlign.left:
            bytes += EscPos.alignLeft;
            break;
          case _ReceiptLineAlign.center:
            bytes += EscPos.alignCenter;
            break;
          case _ReceiptLineAlign.right:
            bytes += EscPos.alignRight;
            break;
        }
        lastAlign = line.align;
      }
      if (line.style == _ReceiptLineStyle.shopName) {
        bytes += EscPos.boldOn;
        bytes += EscPos.textDoubleHeight;
        _appendEncodedText(bytes, line.text);
        bytes += EscPos.lineFeed;
        bytes += EscPos.textNormal;
        bytes += EscPos.boldOff;
      } else if (line.style == _ReceiptLineStyle.invoiceTitle) {
        bytes += EscPos.boldOn;
        bytes += EscPos.textLarge;
        _appendEncodedText(bytes, line.text);
        bytes += EscPos.lineFeed;
        bytes += EscPos.textNormal;
        bytes += EscPos.boldOff;
      } else {
        _appendEncodedText(bytes, line.text);
        bytes += EscPos.lineFeed;
      }
    }
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  Future<Uint8List> buildReceiptImageBytes({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items, // Name, Qty, Price, Total
    required double total,
    required String footer,
    required String invoiceTitle,
    required String invoiceCodePrefix,
    required String sellerLabel,
    required String buyerLabel,
    required String signatureNote,
    required String logoImagePath,
    String? invoiceId,
    int? invoiceSequence,
    DateTime? createdAt,
  }) async {
    final _ReceiptParts parts = _buildReceiptParts(
      shopName: shopName,
      address1: address1,
      address2: address2,
      phone: phone,
      items: items,
      total: total,
      footer: footer,
      createdAt: createdAt,
      invoiceTitle: invoiceTitle,
      invoiceCodePrefix: invoiceCodePrefix,
      invoiceId: invoiceId,
      invoiceSequence: invoiceSequence,
    );

    const TextStyle baseTextStyle = TextStyle(
      fontSize: 24,
      fontFamily: 'monospace',
      color: Colors.black,
      height: 1.35,
    );
    const TextStyle shopNameTextStyle = TextStyle(
      fontSize: 28,
      fontFamily: 'monospace',
      color: Colors.black,
      fontWeight: FontWeight.bold,
      height: 1.3,
    );
    const TextStyle titleTextStyle = TextStyle(
      fontSize: 32,
      fontFamily: 'monospace',
      color: Colors.black,
      fontWeight: FontWeight.bold,
      height: 1.25,
    );
    const double horizontalPadding = 28;
    const double verticalPadding = 32;
    const double spacing = 6;

    TextPainter _painterFor(_ReceiptLine line) {
      return TextPainter(
        text: TextSpan(
          text: line.text,
          style: switch (line.style) {
            _ReceiptLineStyle.invoiceTitle => titleTextStyle,
            _ReceiptLineStyle.shopName => shopNameTextStyle,
            _ReceiptLineStyle.normal => baseTextStyle,
          },
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
    }

    final List<TextPainter> headerPainters =
        parts.beforeTable.map(_painterFor).toList();
    final List<TextPainter> footerPainters =
        parts.afterTable.map(_painterFor).toList();

    double maxTextW = 400;
    for (final p in headerPainters) {
      if (p.width > maxTextW) maxTextW = p.width;
    }
    for (final p in footerPainters) {
      if (p.width > maxTextW) maxTextW = p.width;
    }

    final double tableInnerWidth = math.max(maxTextW, 520);
    final double tableHeight = _measureSolidTableHeight(
      width: tableInnerWidth,
      items: items,
      total: total,
      cellFontSize: 21,
      headerFontSize: 21,
      cellPadding: 8,
    );

    final double canvasWidth = tableInnerWidth + (horizontalPadding * 2);
    final double headerBlockHeight = headerPainters.fold<double>(
          0,
          (double s, TextPainter p) => s + p.height,
        ) +
        spacing * math.max(0, headerPainters.length - 1);
    final double footerBlockHeight = footerPainters.fold<double>(
          0,
          (double s, TextPainter p) => s + p.height,
        ) +
        spacing * math.max(0, footerPainters.length - 1);

    final _ReceiptLogo? receiptLogo = await _loadReceiptLogo(logoImagePath);
    final double canvasHeight = verticalPadding +
        (receiptLogo == null ? 0 : receiptLogo.height + spacing) +
        headerBlockHeight +
        spacing +
        tableHeight +
        spacing +
        footerBlockHeight +
        verticalPadding;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
      Paint()..color = Colors.white,
    );

    double y = verticalPadding;
    if (receiptLogo != null) {
      final double logoX = (canvasWidth - receiptLogo.width) / 2;
      canvas.drawImageRect(
        receiptLogo.image,
        Rect.fromLTWH(
          0,
          0,
          receiptLogo.image.width.toDouble(),
          receiptLogo.image.height.toDouble(),
        ),
        Rect.fromLTWH(logoX, y, receiptLogo.width, receiptLogo.height),
        Paint(),
      );
      y += receiptLogo.height + spacing;
    }

    for (int i = 0; i < headerPainters.length; i++) {
      final TextPainter painter = headerPainters[i];
      final double x = switch (parts.beforeTable[i].align) {
        _ReceiptLineAlign.center => (canvasWidth - painter.width) / 2,
        _ReceiptLineAlign.right =>
          canvasWidth - horizontalPadding - painter.width,
        _ReceiptLineAlign.left => horizontalPadding,
      };
      painter.paint(canvas, Offset(x, y));
      y += painter.height + spacing;
    }

    y += spacing;
    _paintSolidTable(
      canvas: canvas,
      topLeft: Offset(horizontalPadding, y),
      width: tableInnerWidth,
      items: items,
      total: total,
      cellFontSize: 21,
      headerFontSize: 21,
      cellPadding: 8,
      borderWidth: 1.8,
    );
    y += tableHeight + spacing;

    for (int i = 0; i < footerPainters.length; i++) {
      final TextPainter painter = footerPainters[i];
      final double x = switch (parts.afterTable[i].align) {
        _ReceiptLineAlign.center => (canvasWidth - painter.width) / 2,
        _ReceiptLineAlign.right =>
          canvasWidth - horizontalPadding - painter.width,
        _ReceiptLineAlign.left => horizontalPadding,
      };
      painter.paint(canvas, Offset(x, y));
      y += painter.height + spacing;
    }

    final ui.Image image = await recorder
        .endRecording()
        .toImage(canvasWidth.ceil(), canvasHeight.ceil());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Không thể tạo ảnh hóa đơn.');
    }
    return byteData.buffer.asUint8List();
  }

  List<int> _buildVietnameseTextModeSetup() {
    return <int>[
      ...EscPos.init,
      ...EscPos.cancelChineseMode,
      ...EscPos.setInternationalCharsetUsa,
      ...EscPos.forceTextMode,
      ...EscPos.selectCodeTable(EscPos.codeTableWpc1258),
    ];
  }

  _ReceiptParts _buildReceiptParts({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
    required String invoiceTitle,
    required String invoiceCodePrefix,
    String? invoiceId,
    int? invoiceSequence,
    DateTime? createdAt,
  }) {
    final String formattedDate = DateFormat('dd-MM-yyyy hh:mm a')
        .format(createdAt ?? DateTime.now());
    final String invoiceCode = _buildInvoiceCode(
      invoiceCodePrefix,
      invoiceId,
      invoiceSequence: invoiceSequence,
    );
    final String totalText = formatMoney(total);
    final String closingText =
        footer.trim().isEmpty ? 'Cảm ơn quý khách!' : footer.trim();
    final String saleAndCodeLine = invoiceCode.isNotEmpty
        ? 'Ngày bán: $formattedDate    Mã số: $invoiceCode'
        : 'Ngày bán: $formattedDate';

    final String titleText =
        invoiceTitle.trim().isEmpty ? 'HÓA ĐƠN BÁN HÀNG' : invoiceTitle.trim();

    final List<_ReceiptLine> beforeTable = <_ReceiptLine>[
      _ReceiptLine(
        shopName.toUpperCase(),
        align: _ReceiptLineAlign.center,
        style: _ReceiptLineStyle.shopName,
      ),
      _ReceiptLine(phone, align: _ReceiptLineAlign.center),
      if (address1.isNotEmpty)
        _ReceiptLine('Địa chỉ: $address1', align: _ReceiptLineAlign.center),
      if (address2.isNotEmpty)
        _ReceiptLine(address2, align: _ReceiptLineAlign.center),
      _ReceiptLine(
        titleText,
        align: _ReceiptLineAlign.center,
        style: _ReceiptLineStyle.invoiceTitle,
      ),
      const _ReceiptLine(''),
      _ReceiptLine(saleAndCodeLine),
    ];

    final List<_ReceiptLine> afterTable = <_ReceiptLine>[
      _ReceiptLine(
        'Tổng tiền đơn hàng: $totalText',
        align: _ReceiptLineAlign.right,
      ),
      _ReceiptLine(
        'TỔNG TIỀN HÀNG: $totalText',
        align: _ReceiptLineAlign.right,
      ),
      _ReceiptLine(
        _convertNumberToVietnameseWords(total),
        align: _ReceiptLineAlign.right,
      ),
      const _ReceiptLine('', align: _ReceiptLineAlign.center),
      _ReceiptLine(closingText, align: _ReceiptLineAlign.center),
    ];

    return _ReceiptParts(
      beforeTable: beforeTable,
      tableItems: items,
      tableTotal: total,
      afterTable: afterTable,
    );
  }

  double _measureSolidTableHeight({
    required double width,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cellFontSize,
    required double headerFontSize,
    required double cellPadding,
  }) {
    return _layoutSolidTable(
      width: width,
      items: items,
      total: total,
      cellFontSize: cellFontSize,
      headerFontSize: headerFontSize,
      cellPadding: cellPadding,
    ).totalHeight;
  }

  void _paintSolidTable({
    required Canvas canvas,
    required Offset topLeft,
    required double width,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cellFontSize,
    required double headerFontSize,
    required double cellPadding,
    double borderWidth = 1.5,
  }) {
    final _SolidTableLayout layout = _layoutSolidTable(
      width: width,
      items: items,
      total: total,
      cellFontSize: cellFontSize,
      headerFontSize: headerFontSize,
      cellPadding: cellPadding,
    );
    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    final Rect outer = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      width,
      layout.totalHeight,
    );
    canvas.drawRect(outer, borderPaint);

    double y = topLeft.dy;
    for (int i = 0; i < layout.rowHeights.length; i++) {
      y += layout.rowHeights[i];
      if (i < layout.rowHeights.length - 1) {
        canvas.drawLine(
          Offset(topLeft.dx, y),
          Offset(topLeft.dx + width, y),
          borderPaint,
        );
      }
    }

    double x = topLeft.dx;
    for (int c = 0; c < layout.columnWidths.length - 1; c++) {
      x += layout.columnWidths[c];
      canvas.drawLine(
        Offset(x, topLeft.dy),
        Offset(x, topLeft.dy + layout.totalHeight),
        borderPaint,
      );
    }

    y = topLeft.dy;
    for (int r = 0; r < layout.rows.length; r++) {
      final _SolidTableRow row = layout.rows[r];
      final double rowH = layout.rowHeights[r];
      double x = topLeft.dx;
      for (int c = 0; c < row.cells.length; c++) {
        final double colW = layout.columnWidths[c];
        final Rect cell = Rect.fromLTWH(x, y, colW, rowH);
        _paintSolidTableCell(
          canvas: canvas,
          cell: cell.deflate(cellPadding),
          lines: row.cells[c],
          style: row.bold ? layout.headerStyle : layout.cellStyle,
          alignRight: row.alignRight[c],
        );
        x += colW;
      }
      y += rowH;
    }
  }

  void _paintSolidTableCell({
    required Canvas canvas,
    required Rect cell,
    required List<String> lines,
    required TextStyle style,
    required bool alignRight,
  }) {
    double y = cell.top;
    for (final String line in lines) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: line, style: style),
        textDirection: ui.TextDirection.ltr,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        maxLines: 50,
      )..layout(maxWidth: cell.width);
      final double x =
          alignRight ? cell.right - tp.width : cell.left;
      tp.paint(canvas, Offset(x, y));
      y += tp.height;
    }
  }

  _SolidTableLayout _layoutSolidTable({
    required double width,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cellFontSize,
    required double headerFontSize,
    required double cellPadding,
  }) {
    final TextStyle cellStyle = TextStyle(
      fontSize: cellFontSize,
      fontFamily: 'monospace',
      color: Colors.black,
      height: 1.25,
    );
    final TextStyle headerStyle = TextStyle(
      fontSize: headerFontSize,
      fontFamily: 'monospace',
      color: Colors.black,
      fontWeight: FontWeight.bold,
      height: 1.25,
    );

    final double wName = width * 0.42;
    final double wQty = width * 0.11;
    final double wPrice = width * 0.23;
    final double wTotal = width - wName - wQty - wPrice;
    final List<double> columnWidths = <double>[wName, wQty, wPrice, wTotal];

    double measureCellHeight(List<String> lines, TextStyle style, double maxW) {
      double h = 0;
      for (final String line in lines) {
        final TextPainter tp = TextPainter(
          text: TextSpan(text: line, style: style),
          textDirection: ui.TextDirection.ltr,
          maxLines: 40,
        )..layout(maxWidth: maxW);
        h += tp.height;
      }
      return h;
    }

    double rowHeightForCells(
      _SolidTableRow row,
      TextStyle style,
    ) {
      double m = 0;
      for (int c = 0; c < 4; c++) {
        final double inner = columnWidths[c] - cellPadding * 2;
        final double h =
            measureCellHeight(row.cells[c], style, inner) + cellPadding * 2;
        if (h > m) m = h;
      }
      return m;
    }

    final List<_SolidTableRow> rows = <_SolidTableRow>[];
    final List<double> rowHeights = <double>[];

    rows.add(
      _SolidTableRow(
        cells: <List<String>>[
          <String>['Hàng hóa'],
          <String>['SL'],
          <String>['Giá'],
          <String>['T.Tiền'],
        ],
        alignRight: <bool>[false, true, true, true],
        bold: true,
      ),
    );
    rowHeights.add(rowHeightForCells(rows[0], headerStyle));

    final int nameChars =
        math.max(6, (wName / (cellFontSize * 0.52)).floor());

    int totalQty = 0;
    for (int i = 0; i < items.length; i++) {
      final Map<String, dynamic> item = items[i];
      final String indexedName = '${i + 1}. ${item['name']}';
      final String qty = item['qty'].toString();
      final String price = formatMoney(_toDouble(item['price']));
      final String lineTot = formatMoney(_toDouble(item['total']));
      totalQty += _toInt(item['qty']);

      final List<String> nameLines = _wrapText(indexedName, nameChars);

      rows.add(
        _SolidTableRow(
          cells: <List<String>>[
            nameLines,
            <String>[qty],
            <String>[price],
            <String>[lineTot],
          ],
          alignRight: <bool>[false, true, true, true],
          bold: false,
        ),
      );
      rowHeights.add(rowHeightForCells(rows.last, cellStyle));
    }

    rows.add(
      _SolidTableRow(
        cells: <List<String>>[
          <String>['Tổng'],
          <String>[totalQty.toString()],
          <String>[''],
          <String>[formatMoney(total)],
        ],
        alignRight: <bool>[false, true, true, true],
        bold: true,
      ),
    );
    rowHeights.add(rowHeightForCells(rows.last, headerStyle));

    final double totalHeight =
        rowHeights.fold<double>(0, (double a, double b) => a + b);

    return _SolidTableLayout(
      columnWidths: columnWidths,
      rowHeights: rowHeights,
      rows: rows,
      totalHeight: totalHeight,
      cellStyle: cellStyle,
      headerStyle: headerStyle,
    );
  }

  Future<ui.Image?> _renderSolidTableImage({
    required int widthPx,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cellFontSize,
    required double headerFontSize,
    required double cellPadding,
    required double borderWidth,
  }) async {
    final double w = widthPx.toDouble();
    final double h = _measureSolidTableHeight(
      width: w,
      items: items,
      total: total,
      cellFontSize: cellFontSize,
      headerFontSize: headerFontSize,
      cellPadding: cellPadding,
    );
    if (h <= 0) return null;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, w, h),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.white,
    );
    _paintSolidTable(
      canvas: canvas,
      topLeft: Offset.zero,
      width: w,
      items: items,
      total: total,
      cellFontSize: cellFontSize,
      headerFontSize: headerFontSize,
      cellPadding: cellPadding,
      borderWidth: borderWidth,
    );
    final ui.Picture pic = recorder.endRecording();
    final ui.Image out =
        await pic.toImage(widthPx, math.max(1, h.ceil()));
    return out;
  }

  /// ESC/POS GS v 0 — raster bitmap for common Epson-compatible printers.
  Future<List<int>> _escPosRasterBitmap(ui.Image image) async {
    final int width = image.width;
    final int height = image.height;
    final ByteData? rgba =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rgba == null) return <int>[];
    final Uint8List data = rgba.buffer.asUint8List();
    final int widthBytes = (width + 7) ~/ 8;
    final List<int> raster = <int>[];
    for (int y = 0; y < height; y++) {
      for (int xByte = 0; xByte < widthBytes; xByte++) {
        int bits = 0;
        for (int bit = 0; bit < 8; bit++) {
          final int x = xByte * 8 + bit;
          if (x < width) {
            final int o = (y * width + x) * 4;
            final int r = data[o];
            final int g = data[o + 1];
            final int b = data[o + 2];
            final int gray = (r + g + b) ~/ 3;
            if (gray < 140) {
              bits |= 0x80 >> bit;
            }
          }
        }
        raster.add(bits);
      }
    }
    return <int>[
      0x1D,
      0x76,
      0x30,
      0x00,
      widthBytes & 0xFF,
      (widthBytes >> 8) & 0xFF,
      height & 0xFF,
      (height >> 8) & 0xFF,
      ...raster,
    ];
  }

  String _buildInvoiceCode(
    String prefix,
    String? invoiceId, {
    int? invoiceSequence,
  }) {
    final String normalizedPrefix = prefix.trim();
    if (invoiceSequence != null) {
      final String numPart = invoiceSequence.toString().padLeft(6, '0');
      if (normalizedPrefix.isEmpty) return numPart;
      return '$normalizedPrefix$numPart'.trim();
    }
    final String rawId = (invoiceId ?? '').trim();
    if (normalizedPrefix.isEmpty && rawId.isEmpty) {
      return '';
    }
    if (rawId.isEmpty) {
      return normalizedPrefix;
    }
    final String suffix =
        rawId.length <= 4 ? rawId : rawId.substring(rawId.length - 4);
    return '$normalizedPrefix$suffix'.trim();
  }

  String _convertNumberToVietnameseWords(double value) {
    final int amount = value.round();
    if (amount == 0) return 'Không đồng';
    final List<String> unitNames = <String>['', 'nghìn', 'triệu', 'tỷ'];
    final List<String> chunks = <String>[];
    int remaining = amount;
    int unitIndex = 0;

    while (remaining > 0) {
      final int chunk = remaining % 1000;
      if (chunk > 0) {
        final String chunkText = _readThreeDigits(chunk, chunks.isNotEmpty);
        final String unit = unitNames[unitIndex];
        chunks.insert(0, unit.isEmpty ? chunkText : '$chunkText $unit');
      }
      remaining ~/= 1000;
      unitIndex++;
    }

    if (chunks.isEmpty) return 'Không đồng';
    final String sentence = chunks.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return '${_capitalizeFirst(sentence)} đồng';
  }

  String _readThreeDigits(int number, bool full) {
    final List<String> digits = <String>[
      'không',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín',
    ];
    final int hundred = number ~/ 100;
    final int ten = (number % 100) ~/ 10;
    final int one = number % 10;
    final List<String> parts = <String>[];

    if (full || hundred > 0) {
      parts.add('${digits[hundred]} trăm');
      if (ten == 0 && one > 0) {
        parts.add('lẻ');
      }
    }

    if (ten > 1) {
      parts.add('${digits[ten]} mươi');
      if (one == 1) {
        parts.add('mốt');
      } else if (one == 5) {
        parts.add('lăm');
      } else if (one > 0) {
        parts.add(digits[one]);
      }
    } else if (ten == 1) {
      parts.add('mười');
      if (one == 5) {
        parts.add('lăm');
      } else if (one > 0) {
        parts.add(digits[one]);
      }
    } else if (one > 0 && (hundred == 0 && !full)) {
      parts.add(digits[one]);
    } else if (one > 0) {
      parts.add(digits[one]);
    }

    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<_ReceiptLogo?> _loadReceiptLogo(String logoImagePath) async {
    final String path = logoImagePath.trim();
    if (path.isEmpty) return null;
    final File file = File(path);
    if (!await file.exists()) return null;
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 180,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    const double maxWidth = 180;
    const double maxHeight = 90;
    double drawWidth = image.width.toDouble();
    double drawHeight = image.height.toDouble();
    final double widthRatio = maxWidth / drawWidth;
    final double heightRatio = maxHeight / drawHeight;
    final double ratio = widthRatio < heightRatio ? widthRatio : heightRatio;
    if (ratio < 1) {
      drawWidth *= ratio;
      drawHeight *= ratio;
    }
    return _ReceiptLogo(image: image, width: drawWidth, height: drawHeight);
  }

  void _appendEncodedText(List<int> output, String text) {
    final _EncodedText encodedText = _encodeText(text);
    output.addAll(EscPos.selectCodeTable(encodedText.codeTable));
    output.addAll(encodedText.bytes);
  }

  _EncodedText _encodeText(String text) {
    try {
      return _EncodedText(
        bytes: List<int>.from(windows1258.encode(text, invalidCharacter: 0x3F)),
        codeTable: EscPos.codeTableWpc1258,
      );
    } catch (_) {
      try {
        return _EncodedText(
          bytes: List<int>.from(cp858.encode(text, invalidCharacter: 0x3F)),
          codeTable: EscPos.codeTablePc858,
        );
      } catch (_) {
        return _EncodedText(
          bytes: text.codeUnits.map((int unit) => unit <= 0xFF ? unit : 0x3F).toList(),
          codeTable: EscPos.codeTablePc858,
        );
      }
    }
  }

  List<String> _wrapText(String value, int width) {
    final String normalized = value.replaceAll('\n', ' ').trim();
    if (normalized.isEmpty) return <String>[''];
    final List<String> words = normalized.split(RegExp(r'\s+'));
    final List<String> lines = <String>[];
    String currentLine = '';

    for (final word in words) {
      if (word.length > width) {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = '';
        }
        int start = 0;
        while (start < word.length) {
          final int end = (start + width > word.length) ? word.length : start + width;
          lines.add(word.substring(start, end));
          start = end;
        }
        continue;
      }

      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ((currentLine.length + 1 + word.length) <= width) {
        currentLine = '$currentLine $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    return lines.isEmpty ? <String>[''] : lines;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? _toDouble(value).round();
  }
}

class _EncodedText {
  const _EncodedText({required this.bytes, required this.codeTable});

  final List<int> bytes;
  final int codeTable;
}

class _ReceiptLogo {
  const _ReceiptLogo({
    required this.image,
    required this.width,
    required this.height,
  });

  final ui.Image image;
  final double width;
  final double height;
}

enum _ReceiptLineAlign { left, center, right }

enum _ReceiptLineStyle { normal, shopName, invoiceTitle }

class _ReceiptLine {
  const _ReceiptLine(
    this.text, {
    this.align = _ReceiptLineAlign.left,
    this.style = _ReceiptLineStyle.normal,
  });

  final String text;
  final _ReceiptLineAlign align;
  final _ReceiptLineStyle style;
}

class _ReceiptParts {
  const _ReceiptParts({
    required this.beforeTable,
    required this.tableItems,
    required this.tableTotal,
    required this.afterTable,
  });

  final List<_ReceiptLine> beforeTable;
  final List<Map<String, dynamic>> tableItems;
  final double tableTotal;
  final List<_ReceiptLine> afterTable;
}

class _SolidTableLayout {
  const _SolidTableLayout({
    required this.columnWidths,
    required this.rowHeights,
    required this.rows,
    required this.totalHeight,
    required this.cellStyle,
    required this.headerStyle,
  });

  final List<double> columnWidths;
  final List<double> rowHeights;
  final List<_SolidTableRow> rows;
  final double totalHeight;
  final TextStyle cellStyle;
  final TextStyle headerStyle;
}

class _SolidTableRow {
  const _SolidTableRow({
    required this.cells,
    required this.alignRight,
    required this.bold,
  });

  final List<List<String>> cells;
  final List<bool> alignRight;
  final bool bold;
}
