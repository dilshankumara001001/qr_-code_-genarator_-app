import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(const QrStudioApp());

class QrStudioApp extends StatelessWidget {
  const QrStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Studio',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F3),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E6655)),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE3E8E3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0E6655), width: 2)),
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
      home: const QrHomePage(),
    );
  }
}

enum QrMode { text, url, email, phone }

class QrHomePage extends StatefulWidget {
  const QrHomePage({super.key});

  @override
  State<QrHomePage> createState() => _QrHomePageState();
}

class _QrHomePageState extends State<QrHomePage> {
  final controller = TextEditingController();
  QrMode mode = QrMode.text;
  bool copied = false;

  String get data {
    final value = controller.text.trim();
    switch (mode) {
      case QrMode.url:
        return value.isEmpty || value.startsWith('http') ? value : 'https://$value';
      case QrMode.email:
        return value.isEmpty ? '' : 'mailto:$value';
      case QrMode.phone:
        return value.isEmpty ? '' : 'tel:$value';
      case QrMode.text:
        return value;
    }
  }

  String get hint => switch (mode) {
        QrMode.url => 'example.com or https://example.com',
        QrMode.email => 'hello@example.com',
        QrMode.phone => '+94 77 123 4567',
        QrMode.text => 'Type anything you want to share',
      };

  void copyContent() {
    if (data.isEmpty) return;
    Clipboard.setData(ClipboardData(text: data));
    setState(() => copied = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR content copied to clipboard')));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 24,
        title: const Row(children: [Icon(Icons.qr_code_2_rounded, color: Color(0xFF0E6655), size: 30), SizedBox(width: 9), Text('QR Studio', style: TextStyle(fontWeight: FontWeight.w800))]),
        actions: const [Padding(padding: EdgeInsets.only(right: 24), child: Center(child: Text('MINI PROJECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.2))))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Make it scannable.', style: TextStyle(fontSize: 42, height: 1.05, fontWeight: FontWeight.w900, color: Color(0xFF12352F))),
                const SizedBox(height: 10),
                const Text('Turn links, messages, and contact details into a QR code in seconds.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 34),
                LayoutBuilder(builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 700;
                  return Flex(direction: stacked ? Axis.vertical : Axis.horizontal, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Flexible(flex: stacked ? 0 : 5, fit: stacked ? FlexFit.loose : FlexFit.tight, child: inputPanel()),
                    SizedBox(width: stacked ? 0 : 24, height: stacked ? 24 : 0),
                    Flexible(flex: stacked ? 0 : 4, fit: stacked ? FlexFit.loose : FlexFit.tight, child: previewPanel()),
                  ]);
                }),
                const SizedBox(height: 24),
                const Row(children: [Icon(Icons.lock_outline_rounded, size: 16, color: Colors.black45), SizedBox(width: 7), Text('Your content stays on this device. Nothing is uploaded.', style: TextStyle(color: Colors.black45, fontSize: 12))]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget inputPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFE4F0E9), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('1  Choose a format', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 18),
        Wrap(spacing: 8, runSpacing: 8, children: [
          formatButton(QrMode.text, Icons.notes_rounded, 'Text'), formatButton(QrMode.url, Icons.link_rounded, 'Website'), formatButton(QrMode.email, Icons.mail_outline_rounded, 'Email'), formatButton(QrMode.phone, Icons.phone_outlined, 'Phone'),
        ]),
        const SizedBox(height: 28),
        const Text('2  Add your content', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 14),
        TextField(controller: controller, maxLines: mode == QrMode.text ? 5 : 2, onChanged: (_) => setState(() => copied = false), decoration: InputDecoration(hintText: hint, suffixIcon: controller.text.isEmpty ? null : IconButton(onPressed: () { controller.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)))),
        const SizedBox(height: 16),
        TextButton.icon(onPressed: () { controller.text = 'Thanks for scanning! Have a great day.'; setState(() {}); }, icon: const Icon(Icons.auto_awesome_rounded, size: 18), label: const Text('Try a sample')),
      ]),
    );
  }

  Widget formatButton(QrMode value, IconData icon, String label) {
    final selected = mode == value;
    return InkWell(
      onTap: () => setState(() { mode = value; copied = false; }),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11), decoration: BoxDecoration(color: selected ? const Color(0xFF0E6655) : Colors.white.withOpacity(.72), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 17, color: selected ? Colors.white : const Color(0xFF45645C)), const SizedBox(width: 7), Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF45645C), fontWeight: FontWeight.w700))])),
    );
  }

  Widget previewPanel() {
    final hasData = data.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF12352F), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('LIVE PREVIEW', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: .7)),
        const SizedBox(height: 18),
        Center(child: Container(width: 250, height: 250, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: hasData ? QrImageView(data: data, version: QrVersions.auto, size: 218, eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF12352F)), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF12352F))) : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.qr_code_rounded, size: 55, color: Color(0xFFD3DDD7)), SizedBox(height: 10), Text('Your QR appears here', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w600))])))),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: hasData ? copyContent : null, icon: Icon(copied ? Icons.check_rounded : Icons.copy_rounded), label: Text(copied ? 'Copied' : 'Copy content'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE1A94B), foregroundColor: const Color(0xFF12352F), padding: const EdgeInsets.symmetric(vertical: 15)))),
        const SizedBox(height: 10),
        Center(child: Text(hasData ? 'Ready to scan' : 'Enter content to generate', style: const TextStyle(color: Colors.white60, fontSize: 12))),
      ]),
    );
  }
}
