import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WifiAnalyzerScreen extends ConsumerStatefulWidget {
  const WifiAnalyzerScreen({super.key});

  @override
  ConsumerState<WifiAnalyzerScreen> createState() => _WifiAnalyzerScreenState();
}

class _WifiAnalyzerScreenState extends ConsumerState<WifiAnalyzerScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: _buildCardInfo(),
    );
  }

  Widget _buildCardInfo() {
    return Card(
      child: Column(
        children: [
          Text('JARINGAN TERHUBUNG'),
          Text('SSID'),
          Row(
            children: [
              Column(
                children: [
                  _buildInfoCustom('Band', '2.4 GHz'),
                  _buildInfoCustom('Frekuensi', '2437 MHz'),
                ],
              ),
              Column(
                children: [
                  _buildInfoCustom('Channel', '6'),
                  _buildInfoCustom('Sinyal', '-48 dBm'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCustom(String label, String value) {
    return Column(children: [Text(label), Text(value)]);
  }
}
