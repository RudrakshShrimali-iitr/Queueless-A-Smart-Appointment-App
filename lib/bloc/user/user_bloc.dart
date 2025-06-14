import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_event.dart';
import 'user_state.dart';
import '../../models/user_model.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(event.uid).get();
      final user = AppUser.fromMap(doc.data()!);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('Failed to load user: $e'));
    }
  }
}