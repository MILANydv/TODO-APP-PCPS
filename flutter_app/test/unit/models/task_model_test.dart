import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('TaskModel.fromJson', () {
    test('parses every field from an API payload', () {
      final json = testTask(id: 42, title: 'Learn Flutter').toJson();

      final task = TaskModel.fromJson(json);

      expect(task.id, 42);
      expect(task.userId, 'user-1');
      expect(task.title, 'Learn Flutter');
      expect(task.description, 'Test description');
      expect(task.isCompleted, isFalse);
      expect(task.createdAt, '2026-11-21T14:23:09.280Z');
    });

    test('accepts a string id as returned by some stores', () {
      final task = TaskModel.fromJson(<String, dynamic>{
        'id': '17',
        'userId': 'u1',
        'title': 'String id',
        'description': '',
        'isCompleted': false,
        'createdAt': 'now',
      });

      expect(task.id, 17);
    });

    test('defaults missing description and isCompleted', () {
      final task = TaskModel.fromJson(<String, dynamic>{
        'id': 1,
        'userId': 'u1',
        'title': 'Minimal',
        'createdAt': 'now',
      });

      expect(task.description, '');
      expect(task.isCompleted, isFalse);
    });
  });

  group('TaskModel.toJson', () {
    test('round-trips through fromJson', () {
      final original = testTask(
        id: 7,
        isCompleted: true,
        description: 'Done already',
      );

      expect(TaskModel.fromJson(original.toJson()).toJson(), original.toJson());
    });
  });

  group('TaskModel.copyWith', () {
    test('replaces only the provided fields', () {
      final task = testTask();

      final updated = task.copyWith(title: 'New title', isCompleted: true);

      expect(updated.title, 'New title');
      expect(updated.isCompleted, isTrue);
      expect(updated.id, task.id);
      expect(updated.userId, task.userId);
      expect(updated.description, task.description);
      expect(updated.createdAt, task.createdAt);
      expect(task.title, 'Test task', reason: 'original must stay unchanged');
    });

    test('returns equivalent values when nothing is provided', () {
      final task = testTask();

      expect(task.copyWith().toJson(), task.toJson());
    });
  });
}
