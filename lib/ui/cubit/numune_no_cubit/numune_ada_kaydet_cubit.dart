import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/datasources/numune_ada_no_sorgular/numune_ada_kaydet_sorgu.dart';

class NumuneAdaKaydetState {
  final String? message;

  NumuneAdaKaydetState({this.message});
}

class NumuneAdaKaydetCubit extends Cubit<NumuneAdaKaydetState> {
  final NumuneAdaKaydetSorgu sorgu;

  NumuneAdaKaydetCubit(this.sorgu) : super(NumuneAdaKaydetState());

  Future<void> kaydetNumuneAdaKaydet(String malzemeKodu, String rafNo, String gozNo) async {
    try {
      final sicilNo = (await SharedPreferences.getInstance()).getString('kullanici_id') ?? '';
      final result = await sorgu.kaydetNumuneAda(malzemeKodu, rafNo, gozNo, sicilNo);
      emit(NumuneAdaKaydetState(message: result));
    } catch (e) {
      emit(NumuneAdaKaydetState(message: "Hata: $e"));
    }
  }
}