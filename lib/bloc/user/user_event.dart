abstract class UserEvent {}

class LoadUser extends UserEvent {
  final String uid;

  LoadUser(this.uid);
}