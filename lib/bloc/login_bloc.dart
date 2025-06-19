import 'package:my_berita/model/auth/login_response.dart';
import 'package:my_berita/repository/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final AuthRepository _repository = AuthRepository();
  final BehaviorSubject<LoginResponse> _subject = BehaviorSubject<LoginResponse>();

  login(String email, String password) async {

    LoginResponse response = await _repository.login(email, password);
    if (!_subject.isClosed) {
      _subject.sink.add(response);
    }
  }

  void drainStream() {
    _subject.add(LoginResponse.withError(''));
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<LoginResponse> get subject => _subject;
}

final loginBloc = LoginBloc();
