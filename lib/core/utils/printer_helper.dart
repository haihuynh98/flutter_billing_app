import 'package:intl/intl.dart';
import 'package:charset/charset.dart';
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

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items, // Name, Qty, Price, Total
    required double total,
    required String footer,
  }) async {
    if (!_isConnected) return;
    final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (!connectionStatus) return;

    List<int> bytes = _buildVietnameseTextModeSetup();

    bytes += EscPos.alignCenter;
    bytes += EscPos.boldOn;
    bytes += EscPos.textLarge;
    _appendEncodedText(bytes, shopName);
    bytes += EscPos.lineFeed;

    bytes += EscPos.textNormal;
    bytes += EscPos.boldOff;
    if (address1.isNotEmpty) {
      _appendEncodedText(bytes, address1);
      bytes += EscPos.lineFeed;
    }
    if (address2.isNotEmpty) {
      _appendEncodedText(bytes, address2);
      bytes += EscPos.lineFeed;
    }
    _appendEncodedText(bytes, phone);
    bytes += EscPos.lineFeed;

    final String formattedDate =
        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    _appendEncodedText(bytes, formattedDate);
    bytes += EscPos.lineFeed;

    _appendEncodedText(bytes, '--------------------------------');
    bytes += EscPos.lineFeed;

    bytes += EscPos.alignLeft;
    _appendEncodedText(bytes, 'Mat hang         Gia  Thanh tien');
    bytes += EscPos.lineFeed;
    _appendEncodedText(bytes, '--------------------------------');
    bytes += EscPos.lineFeed;

    for (final item in items) {
      final String name = item['name'].toString();
      final String qty = item['qty'].toString();
      final String price = item['price'].toString();
      final String totalItem = item['total'].toString();

      String prefix = '${qty}x $name';
      if (prefix.length > 16) prefix = prefix.substring(0, 16);

      final String line = prefix.padRight(16) + price.padRight(8) + totalItem;
      _appendEncodedText(bytes, line);
      bytes += EscPos.lineFeed;
    }

    _appendEncodedText(bytes, '--------------------------------');
    bytes += EscPos.lineFeed;

    bytes += EscPos.alignRight;
    bytes += EscPos.boldOn;
    _appendEncodedText(bytes, 'TONG CONG: $total');
    bytes += EscPos.lineFeed;
    bytes += EscPos.boldOff;
    bytes += EscPos.lineFeed;

    bytes += EscPos.alignCenter;
    _appendEncodedText(bytes, footer);
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed;

    await PrintBluetoothThermal.writeBytes(bytes);
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
}

class _EncodedText {
  const _EncodedText({required this.bytes, required this.codeTable});

  final List<int> bytes;
  final int codeTable;
}
