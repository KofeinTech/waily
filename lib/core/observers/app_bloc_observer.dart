import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._talker);

  final Talker _talker;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _talker.debug(
      '${bloc.runtimeType}: ${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace, '${bloc.runtimeType} error');
    super.onError(bloc, error, stackTrace);
  }
}
