import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = AuthViewModel(repository);
  });

  group('state delegation', () {
    test('exposes user, token, and login status from the repository', () {
      final user = testUser(name: 'Milan');
      final repository = FakeAuthRepository();
      repository.setSession(token: 'jwt-abc', user: user);
      final viewModel = AuthViewModel(repository);

      expect(viewModel.user?.name, 'Milan');
      expect(viewModel.token, 'jwt-abc');
      expect(viewModel.isLoggedIn, isTrue);
    });

    test('reports logged out when no token is stored', () {
      expect(viewModel.isLoggedIn, isFalse);
      expect(viewModel.token, isNull);
      expect(viewModel.user, isNull);
    });
  });

  group('register', () {
    test('returns true, forwards arguments, and clears loading', () async {
      final result = await viewModel.register(
        name: 'Milan',
        email: 'milan@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(repository.calls, contains('register'));
      expect(repository.lastName, 'Milan');
      expect(repository.lastEmail, 'milan@example.com');
      expect(repository.lastPassword, 'password123');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('returns false and captures the error message on failure', () async {
      repository.registerError = Exception('Email already exists');

      final result = await viewModel.register(
        name: 'Milan',
        email: 'milan@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(viewModel.error, contains('Email already exists'));
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('login', () {
    test('returns true and forwards credentials', () async {
      final result = await viewModel.login(
        email: 'a@b.com',
        password: 'secret',
      );

      expect(result, isTrue);
      expect(repository.lastEmail, 'a@b.com');
      expect(repository.lastPassword, 'secret');
      expect(viewModel.isLoading, isFalse);
    });

    test('returns false and records the error on invalid credentials',
        () async {
      repository.loginError = Exception('Invalid email or password');

      final result = await viewModel.login(
        email: 'a@b.com',
        password: 'wrong',
      );

      expect(result, isFalse);
      expect(viewModel.error, contains('Invalid email or password'));
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('refreshProfile and updateProfile', () {
    test('refreshProfile fetches the user and reports success', () async {
      final result = await viewModel.refreshProfile();

      expect(result, isTrue);
      expect(repository.calls, contains('getMe'));
      expect(viewModel.isLoading, isFalse);
    });

    test('refreshProfile captures failures', () async {
      repository.getMeError = Exception('Unauthorized');

      final result = await viewModel.refreshProfile();

      expect(result, isFalse);
      expect(viewModel.error, contains('Unauthorized'));
    });

    test('updateProfile forwards only the supplied fields', () async {
      final result = await viewModel.updateProfile(name: 'New name');

      expect(result, isTrue);
      expect(repository.lastUpdatedName, 'New name');
      expect(repository.lastUpdatedEmail, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('updateProfile captures failures', () async {
      repository.updateProfileError = Exception('Update failed');

      final result = await viewModel.updateProfile(email: 'new@example.com');

      expect(result, isFalse);
      expect(viewModel.error, contains('Update failed'));
    });
  });

  group('logout', () {
    test('clears the session and any previous error', () async {
      repository.loginError = Exception('Old error');
      await viewModel.login(email: 'a@b.com', password: 'wrong');
      expect(viewModel.error, isNotNull);

      await viewModel.logout();

      expect(repository.calls.last, 'logout');
      expect(viewModel.error, isNull);
      expect(viewModel.isLoggedIn, isFalse);
    });

    test('notifies listeners even when already idle', () async {
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      await viewModel.logout();

      expect(notifications, greaterThanOrEqualTo(1));
    });
  });

  test('UserModel exposed by the repository is the same object', () {
    final user = testUser();
    final repository = FakeAuthRepository(user: user);
    final viewModel = AuthViewModel(repository);

    expect(identical(viewModel.user, user), isTrue);
  });
}
