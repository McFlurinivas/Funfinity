part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final UserModel user;

  const LoginSuccess(this.user);

  @override
  List<Object> get props => [user];
}

final class GoogleSignOutSuccess extends LoginState {}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object> get props => [message];
}
