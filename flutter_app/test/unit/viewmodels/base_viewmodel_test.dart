import 'package:flutter_app/presentation/viewmodels/base_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestViewModel extends BaseViewModel {}

void main() {
  late _TestViewModel viewModel;
  late int notifications;

  setUp(() {
    viewModel = _TestViewModel();
    notifications = 0;
    viewModel.addListener(() => notifications++);
  });

  test('starts idle with no error', () {
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, isNull);
  });

  test('setBusy updates loading state and clears any error', () {
    viewModel.setError('Oops');
    viewModel.setBusy(true);

    expect(viewModel.isLoading, isTrue);
    expect(viewModel.error, isNull);
  });

  test('setError stops loading and stores the message', () {
    viewModel.setBusy(true);

    viewModel.setError('Something failed');

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, 'Something failed');
  });

  test('clearError only removes the message', () {
    viewModel.setBusy(true);
    viewModel.setError('Failure');

    viewModel.clearError();

    expect(viewModel.error, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('notifies listeners for every state change', () {
    viewModel.setBusy(true);
    viewModel.setBusy(false);
    viewModel.setError('Failure');
    viewModel.clearError();

    expect(notifications, 4);
  });
}
