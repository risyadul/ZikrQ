// lib/presentation/pages/surah_detail/surah_detail_page.dart
import 'package:flutter/material.dart';

class SurahDetailPage extends StatelessWidget {
  const SurahDetailPage({required this.surahId, super.key});
  final int surahId;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Surah $surahId')));
}
