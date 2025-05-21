import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/sayim_sorgular/sayim_sorgu_sorgu.dart';

class SayimSorguState {
  final List<Map<String, String>> data;
  final String? error;

  SayimSorguState({this.data = const [], this.error});
}

class SayimSorguCubit extends Cubit<SayimSorguState> {
  final SayimSorguSorgu krepo;

  SayimSorguCubit(this.krepo) : super(SayimSorguState());

  Future<void> kaydetSayimSorguCubit(String rafNo, String barkodNo) async {
    try {
      final sonuc = await krepo.kaydetSayimSorguCubit(rafNo, barkodNo);
      emit(SayimSorguState(data: sonuc));
    } catch (e) {
      emit(SayimSorguState(error: e.toString()));
    }
  }
}