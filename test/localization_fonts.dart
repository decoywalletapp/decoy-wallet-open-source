import 'package:flutter/services.dart';

Future<void> loadLocalizationFonts() async {
  final fonts = <String, List<String>>{
    'DECOY BEBAS': ['BebasNeue-Regular.ttf'],
    'InterTight': ['InterTight-Regular.ttf', 'InterTight-Bold.ttf'],
    'hello': ['Inter_24pt-Regular.ttf', 'Inter_28pt-Bold.ttf'],
    'Outterbox': ['Outfit-Regular.ttf', 'Outfit-Bold.ttf'],
    'robot': ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
    'Roboto': ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
    for (final family in [
      'NotoSansArabic',
      'NotoSansHebrew',
      'NotoSansDevanagari',
      'NotoSansJP',
      'NotoSansKR',
      'NotoSansSC',
    ])
      family: ['international/$family.ttf'],
  };
  for (final entry in fonts.entries) {
    final loader = FontLoader(entry.key);
    for (final asset in entry.value) {
      loader.addFont(rootBundle.load('assets/fonts/$asset'));
    }
    await loader.load();
  }
  await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
      .load();
}
