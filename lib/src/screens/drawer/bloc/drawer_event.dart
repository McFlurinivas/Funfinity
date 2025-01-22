part of 'drawer_bloc.dart';

sealed class DrawerEvent {}

class LoadUser extends DrawerEvent {}

class SignOut extends DrawerEvent {}

enum SwitchType { bgMusic, sfxMusic, vibration }

class SwitchToggled extends DrawerEvent {
  final SwitchType switchType;
  final bool value;

  SwitchToggled({required this.switchType, required this.value});
}
