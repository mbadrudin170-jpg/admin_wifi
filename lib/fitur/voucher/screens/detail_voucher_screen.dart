import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailVoucherScreen extends ConsumerWidget {
  final String id;
  const DetailVoucherScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: Center(child: Text('DetailVoucherScreen')),
    );
  }
}
