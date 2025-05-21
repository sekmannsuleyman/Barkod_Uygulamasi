import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/sayim_sorgular/sayim_gerial_sorgu.dart';

class SayimGerialState {
  final String? message;
  final bool isError;

  SayimGerialState({this.message, this.isError = false});
}

class SayimGerialCubit extends Cubit<SayimGerialState> {
  final SayimGerialSorgu sorgu;

  SayimGerialCubit(this.sorgu) : super(SayimGerialState());

  Future<void> kaydetSayimGerialCubit(String barkodNo) async {
    try {
      final result = await sorgu.kaydetSayimGerial(barkodNo);
      emit(SayimGerialState(message: result, isError: false));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(SayimGerialState(message: errorMessage, isError: true));
    }
  }
}