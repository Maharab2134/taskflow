import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaharab/core/utils/natural_language_parser.dart';

void main() {
  group('NaturalLanguageParser', () {
    test('extracts title and tomorrow due date', () {
      final result = NaturalLanguageParser.parse('Finish portfolio website tomorrow');
      expect(result.title.toLowerCase().contains('finish portfolio website'), isTrue);
      expect(result.dueDate, isNotNull);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(result.dueDate!.day, tomorrow.day);
    });

    test('extracts time', () {
      final result = NaturalLanguageParser.parse('Deploy release at 8 PM');
      expect(result.title.contains('Deploy release'), isTrue);
      expect(result.dueTime, isNotNull);
      expect(result.dueTime!.hour, 20);
      expect(result.dueTime!.minute, 0);
    });

    test('extracts urgent priority token', () {
      final result = NaturalLanguageParser.parse('Fix crash immediately urgent');
      expect(result.priority, 'urgent');
    });

    test('extracts high priority token', () {
      final result = NaturalLanguageParser.parse('Prepare presentation !high');
      expect(result.priority, 'high');
    });
  });
}
