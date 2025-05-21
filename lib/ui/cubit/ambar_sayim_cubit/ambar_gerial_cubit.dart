import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/ambar_sayim_sorgulari/ambar_gerial_sorgu.dart';

class AmbarGerialState {
  final String? message;
  final bool isError;

  AmbarGerialState({this.message, this.isError = false});
}

class AmbarGerialCubit extends Cubit<AmbarGerialState> {
  final AmbarGerialSorgu sorgu;

  AmbarGerialCubit(this.sorgu) : super(AmbarGerialState());

  Future<void> kaydetAmbarGerial(String barkodNo) async {
    try {
      final result = await sorgu.kaydetAmbarGerial(barkodNo);
      emit(AmbarGerialState(message: result, isError: false));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AmbarGerialState(message: errorMessage, isError: true));
    }
  }
}