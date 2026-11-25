import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses id, name, and email', () {
      final user = UserModel.fromJson(testUser(
        id: 'abc-123',
        name: 'Milan',
        email: 'milan@example.com',
      ).toJson());

      expect(user.id, 'abc-123');
      expect(user.name, 'Milan');
      expect(user.email, 'milan@example.com');
    });

    test('toJson produces the expected shape', () {
      expect(testUser().toJson(), <String, dynamic>{
        'id': 'user-1',
        'name': 'Test User',
        'email': 'test@example.com',
      });
    });
  });

  group('AuthResponse.fromJson', () {
    test('parses the token and nested user', () {
      final response = AuthResponse.fromJson(authJson(
        token: 'jwt-abc',
        user: testUser(name: 'Ada', email: 'ada@example.com').toJson(),
      ));

      expect(response.token, 'jwt-abc');
      expect(response.user.name, 'Ada');
      expect(response.user.email, 'ada@example.com');
    });
  });
}
