import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_language_controller.dart';
import 'app_localizations.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  final controller = context.read<AppLanguageController>();
  final selected = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    builder: (sheetContext) {
      final strings = AppLocalizations.of(sheetContext)!;
      final choices = <String, String>{
        'system': strings.msgUseDeviceLanguage,
        ...AppLanguageController.languageNames,
      };
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(strings.msgLanguage,
                          style: Theme.of(sheetContext).textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(sheetContext)
                          .closeButtonTooltip,
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final choice in choices.entries)
                      ListTile(
                        key: ValueKey('language-${choice.key}'),
                        title: Text(choice.value,
                            textAlign: Directionality.of(sheetContext) ==
                                    TextDirection.rtl
                                ? TextAlign.right
                                : TextAlign.left,
                            textDirection: choice.key == 'system'
                                ? Directionality.of(sheetContext)
                                : {'ar', 'he'}.contains(choice.key)
                                    ? TextDirection.rtl
                                    : TextDirection.ltr),
                        selected:
                            choice.key == (controller.languageCode ?? 'system'),
                        trailing: choice.key ==
                                (controller.languageCode ?? 'system')
                            ? const Icon(Icons.check, color: Color(0xFFFF6500))
                            : null,
                        onTap: () => Navigator.pop(sheetContext, choice.key),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
  if (selected == null) return;
  final saved =
      await controller.setLanguage(selected == 'system' ? null : selected);
  if (!saved && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!
          .msgCouldNotSaveYourLanguagePleaseTryAgain),
    ));
  }
}

class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          key: const ValueKey('language-picker'),
          onPressed: () => showLanguagePicker(context),
          icon: const Icon(Icons.language, size: 20),
          label: Text(strings.msgLanguage),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF15161E),
            minimumSize: const Size(48, 48),
          ),
        ),
      ),
    );
  }
}
