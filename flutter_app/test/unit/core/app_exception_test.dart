import 'package:flutter_app/core/network/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException hierarchy', () {
    test('all data exceptions are AppExceptions', () {
      expect(FetchDataException('offline'), isA<AppException>());
      expect(BadRequestException('bad', 400), isA<AppException>());
      expect(UnauthorisedException('server', 500), isA<AppException>());
    });

    test('preserves message and optional status code', () {
      const exception = BadRequestException('Invalid email', 400);

      expect(exception.message, 'Invalid email');
      expect(exception.statusCode, 400);
    });

    test('statusCode is null when not supplied', () {
      expect(FetchDataException('Network error: failed').statusCode, isNull);
    });

    test('toString includes message and status code', () {
      const exception = UnauthorisedException('Server error', 503);

      expect(
        exception.toString(),
        'AppException: Server error (statusCode: 503)',
      );
    });
  });
}
