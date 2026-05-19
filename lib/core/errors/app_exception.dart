/// Error base controlado para mostrar mensajes seguros a la usuaria.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

final class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

final class BusinessRuleException extends AppException {
  const BusinessRuleException(super.message, {super.code});
}

final class UnknownAppException extends AppException {
  const UnknownAppException(super.message, {super.code});
}
