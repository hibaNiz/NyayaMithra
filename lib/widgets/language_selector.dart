import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final double iconSize;
  
  const LanguageSelector({
    super.key,
    this.showLabel = true,
    this.iconSize = 24,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<String>(
          onSelected: (value) => provider.setLanguage(value),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppTheme.surfaceColor,
          itemBuilder: (context) => AppConstants.supportedLanguages.entries
              .map((entry) => PopupMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: provider.selectedLanguage == entry.key
                                ? AppTheme.secondaryColor.withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: provider.selectedLanguage == entry.key
                                  ? AppTheme.secondaryColor
                                  : Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.value,
                          style: TextStyle(
                            color: provider.selectedLanguage == entry.key
                                ? AppTheme.secondaryColor
                                : Colors.white,
                            fontWeight: provider.selectedLanguage == entry.key
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (provider.selectedLanguage == entry.key) ...[
                          const Spacer(),
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.secondaryColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language_rounded,
                  color: AppTheme.secondaryColor,
                  size: iconSize,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.supportedLanguages[provider.selectedLanguage] ??
                        'English',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
