import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/numune_ada_no_sorgular/numune_ada_sorgu.dart';

class NumuneAdaSorgulaState {
  final List<Map<String, String>> data;
  final String? error;

  NumuneAdaSorgulaState({this.data = const [], this.error});
}

class NumuneAdaSorgulaCubit extends Cubit<NumuneAdaSorgulaState> {
  final NumuneAdaSorgu sorgu;

  NumuneAdaSorgulaCubit(this.sorgu) : super(NumuneAdaSorgulaState());

  Future<void> kaydetNumuneAdaSorgula(String rafNo, String gozNo) async {
    try {
      final result = await sorgu.kaydetNumuneAdaSorgu(rafNo, gozNo);
      emit(NumuneAdaSorgulaState(data: result));
    } catch (e) {
      emit(NumuneAdaSorgulaState(error: e.toString()));
    }
  }
}