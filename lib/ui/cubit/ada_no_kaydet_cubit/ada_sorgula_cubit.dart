import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/ada_no_sorgulari/ada_sorgu_sorgu.dart';

class AdaSorgulaState {
  final List<Map<String, String>> data;
  final String? error;

  AdaSorgulaState({this.data = const [], this.error});
}

class AdaSorgulaCubit extends Cubit<AdaSorgulaState> {
  final AdaSorguSorgu sorgu;

  AdaSorgulaCubit(this.sorgu) : super(AdaSorgulaState());

  Future<void> kaydetAdaSorgula(String adaNo, String siraNo) async {
    try {
      final result = await sorgu.kaydetAdaSorgu(adaNo, siraNo);
      emit(AdaSorgulaState(data: result));
    } catch (e) {
      emit(AdaSorgulaState(error: e.toString()));
    }
  }
}