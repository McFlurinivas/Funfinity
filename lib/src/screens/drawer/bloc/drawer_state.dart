part of 'drawer_bloc.dart';

sealed class DrawerState {}

class DrawerInitial extends DrawerState {}

class DrawerLoading extends DrawerState {}

class DrawerLoaded extends DrawerState {
  final UserModel users;
  DrawerLoaded(this.users);
}

class DrawerSwitchToggled extends DrawerState {
  final bool isBgMusicSwitched;
  final bool isSfxMusicSwitched;
  final bool isVibratingSwitched;
  DrawerSwitchToggled(this.isBgMusicSwitched, this.isSfxMusicSwitched,
      this.isVibratingSwitched);
}

class DrawerSignOut extends DrawerState {}

class DrawerError extends DrawerState {
  final String errorMessage;
  DrawerError(this.errorMessage);
}
