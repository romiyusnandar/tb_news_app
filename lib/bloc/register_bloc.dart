import 'package:my_berita/model/auth/register_response.dart';
import 'package:my_berita/repository/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc {
  final AuthRepository _repository = AuthRepository();
  final BehaviorSubject<RegisterResponse> _subject = BehaviorSubject<RegisterResponse>();

  register(String email, String password, String name, String title, String avatar) async {
    RegisterResponse response = await _repository.register(email, password, name, title, avatar);
    if (!_subject.isClosed) {
      _subject.sink.add(response);
    }
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<RegisterResponse> get subject => _subject;
}

final registerBloc = RegisterBloc();
