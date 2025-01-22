part of 'splash_cubit.dart';

sealed class SplashState {}

final class SplashInitial extends SplashState {}

final class SplashNoInternet extends SplashState {
  final String message;

  SplashNoInternet(this.message);

  List<Object> get props => [message];
}

final class SplashUnauthenticated extends SplashState {}

final class SplashAuthenticated extends SplashState {
  final String user;

  SplashAuthenticated(this.user);

  List<Object> get props => [user];
}

final class SplashError extends SplashState {
  final String message;

  SplashError(this.message);

  List<Object> get props => [message];
}
