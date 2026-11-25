import 'dart:convert';

import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/core/network/api_client.dart';
import 'package:flutter_app/core/network/app_exception.dart';
import 'package:flutter_app/data/repositories/task_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_data.dart';

void main() {
  late http.Request lastRequest;
  late http.Response Function(http.Request) responder;
  late TaskRepositoryImpl repository;

  setUp(() async {
    responder = (_) => http.Response('{}', 200);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    repository = TaskRepositoryImpl(
      ApiClient(MockClient((request) async {
        lastRequest = request;
        return responder(request);
      }), prefs),
    );
  });

  test('getTasks parses the data array into TaskModels', () async {
    final tasks = <dynamic>[
      testTask(id: 1, title: 'First').toJson(),
      testTask(id: 2, title: 'Second', isCompleted: true).toJson(),
    ];
    responder = (_) => http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'count': tasks.length,
            'data': tasks,
          }),
          200,
        );

    final result = await repository.getTasks();

    expect(result, hasLength(2));
    expect(result.first.title, 'First');
    expect(result.last.isCompleted, isTrue);
    expect(lastRequest.method, 'GET');
    expect(lastRequest.url.path, AppConstants.tasksEndpoint);
  });

  test('createTask posts title and description and parses the new task',
      () async {
    responder = (_) => http.Response(
          jsonEncode(taskJson(testTask(id: 9, title: 'New'))),
          201,
        );

    final task = await repository.createTask(
      title: 'New',
      description: 'Description',
    );

    expect(task.id, 9);
    expect(lastRequest.method, 'POST');
    expect(jsonDecode(lastRequest.body), <String, dynamic>{
      'title': 'New',
      'description': 'Description',
    });
  });

  test('updateTask sends only the supplied fields to the task path', () async {
    responder = (_) => http.Response(
          jsonEncode(taskJson(
            testTask(id: 3, title: 'Old', isCompleted: true),
          )),
          200,
        );

    final task = await repository.updateTask(id: 3, isCompleted: true);

    expect(task.isCompleted, isTrue);
    expect(lastRequest.method, 'PATCH');
    expect(lastRequest.url.path, '${AppConstants.tasksEndpoint}/3');
    expect(jsonDecode(lastRequest.body), <String, dynamic>{
      'isCompleted': true,
    });
  });

  test('deleteTask calls DELETE on the task path', () async {
    responder = (_) => http.Response(
          '{"success":true,"message":"Task deleted"}',
          200,
        );

    await repository.deleteTask(12);

    expect(lastRequest.method, 'DELETE');
    expect(lastRequest.url.path, '${AppConstants.tasksEndpoint}/12');
  });

  test('surfaces typed exceptions from the API client', () async {
    responder = (_) => http.Response(
          '{"message":"Task not found"}',
          404,
        );

    expect(
      repository.deleteTask(999),
      throwsA(
        isA<BadRequestException>()
            .having((e) => e.message, 'message', 'Task not found')
            .having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });
}
