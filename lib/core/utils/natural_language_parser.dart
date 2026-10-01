import 'package:flutter/material.dart';

class ParsedTaskResult {
  final String title;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final String priority;
  final String? category;

  ParsedTaskResult({
    required this.title,
    this.dueDate,
    this.dueTime,
    this.priority = 'medium',
    this.category,
  });
}

class NaturalLanguageParser {
  NaturalLanguageParser._();

  static ParsedTaskResult parse(String input) {
    if (input.trim().isEmpty) {
      return ParsedTaskResult(title: '');
    }

    String workingText = input;
    DateTime? parsedDate;
    TimeOfDay? parsedTime;
    String parsedPriority = 'medium';
    String? parsedCategory;

    final lower = input.toLowerCase();

    // 1. Detect Priority markers
    if (lower.contains('!urgent') || lower.contains('asap') || lower.contains('urgent')) {
      parsedPriority = 'urgent';
      workingText = workingText
          .replaceAll(RegExp(r'!urgent|asap|urgent', caseSensitive: false), '')
          .trim();
    } else if (lower.contains('!high') || lower.contains('high priority')) {
      parsedPriority = 'high';
      workingText = workingText
          .replaceAll(RegExp(r'!high|high priority', caseSensitive: false), '')
          .trim();
    } else if (lower.contains('!low') || lower.contains('low priority')) {
      parsedPriority = 'low';
      workingText = workingText
          .replaceAll(RegExp(r'!low|low priority', caseSensitive: false), '')
          .trim();
    }

    // 2. Detect category / tag (#design, #dev, #personal)
    final tagRegex = RegExp(r'#(\w+)');
    final tagMatch = tagRegex.firstMatch(workingText);
    if (tagMatch != null) {
      parsedCategory = tagMatch.group(1);
      workingText = workingText.replaceFirst(tagMatch.group(0)!, '').trim();
    }

    // 3. Detect time (e.g., "at 8 PM", "at 14:30", "at 9:00am", "8pm", "8:30pm")
    final timeRegex = RegExp(r'\b(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b|\bat\s+(\d{1,2}):(\d{2})\b', caseSensitive: false);
    final timeMatch = timeRegex.firstMatch(workingText);
    if (timeMatch != null) {
      final hourStr = timeMatch.group(1) ?? timeMatch.group(4);
      final minuteStr = timeMatch.group(2) ?? timeMatch.group(5) ?? '0';
      final amPm = timeMatch.group(3)?.toLowerCase();

      int hour = int.tryParse(hourStr ?? '') ?? 9;
      final int minute = int.tryParse(minuteStr) ?? 0;

      if (amPm == 'pm' && hour < 12) {
        hour += 12;
      } else if (amPm == 'am' && hour == 12) {
        hour = 0;
      }

      parsedTime = TimeOfDay(hour: hour, minute: minute);
      workingText = workingText.replaceFirst(timeMatch.group(0)!, '').trim();
    }

    // 4. Detect Relative Date (today, tomorrow, next monday, etc.)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (RegExp(r'\btomorrow\b', caseSensitive: false).hasMatch(workingText)) {
      parsedDate = today.add(const Duration(days: 1));
      workingText = workingText.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '').trim();
    } else if (RegExp(r'\btoday\b', caseSensitive: false).hasMatch(workingText)) {
      parsedDate = today;
      workingText = workingText.replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '').trim();
    } else if (RegExp(r'\byesterday\b', caseSensitive: false).hasMatch(workingText)) {
      parsedDate = today.subtract(const Duration(days: 1));
      workingText = workingText.replaceAll(RegExp(r'\byesterday\b', caseSensitive: false), '').trim();
    } else {
      // Days of week: monday, tuesday, etc.
      final daysOfWeek = {
        'monday': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'friday': DateTime.friday,
        'saturday': DateTime.saturday,
        'sunday': DateTime.sunday,
      };

      for (final entry in daysOfWeek.entries) {
        final pattern = RegExp('\\b(?:next\\s+)?${entry.key}\\b', caseSensitive: false);
        if (pattern.hasMatch(workingText)) {
          int diff = entry.value - today.weekday;
          if (diff <= 0) diff += 7;
          parsedDate = today.add(Duration(days: diff));
          workingText = workingText.replaceAll(pattern, '').trim();
          break;
        }
      }
    }

    // Clean up title: remove dangling "at", "on", extra whitespace
    String cleanTitle = workingText
        .replaceAll(RegExp(r'\s+at\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+on\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleanTitle.isEmpty) {
      cleanTitle = input;
    }

    return ParsedTaskResult(
      title: cleanTitle,
      dueDate: parsedDate,
      dueTime: parsedTime,
      priority: parsedPriority,
      category: parsedCategory,
    );
  }
}
