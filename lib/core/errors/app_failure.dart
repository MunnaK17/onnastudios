sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.cause});
}

final class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode, super.cause});

  final int? statusCode;
}

final class CacheFailure extends AppFailure {
  const CacheFailure(super.message, {super.cause});
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.cause});
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong', Object? cause])
    : super(cause: cause);
}
