import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/ambar_sayim_sorgulari/ambar_sayim_sayim_sorgu.dart';

class AmbarSayimSorguState {
  final List<Map<String, String>> data;
  final String? error;

  AmbarSayimSorguState({this.data = const [], this.error});
}

class AmbarSayimSorguCubit extends Cubit<AmbarSayimSorguState> {
  final AmbarSayimSorguSorgu sorgu;

  AmbarSayimSorguCubit(this.sorgu) : super(AmbarSayimSorguState());

  Future<void> kaydetAmbarSayimSorgu(String rafNo, String gozNo, String barkodNo) async {
    try {
      final result = await sorgu.kaydetAmbarSayimSorgu(rafNo, gozNo, barkodNo);
      emit(AmbarSayimSorguState(data: result));
    } catch (e) {
      emit(AmbarSayimSorguState(error: e.toString()));
    }
  }
}