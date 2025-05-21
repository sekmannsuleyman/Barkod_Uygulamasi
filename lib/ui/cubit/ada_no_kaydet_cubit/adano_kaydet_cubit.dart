import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/datasources/ada_no_sorgulari/ada_no_kaydet_sorgu.dart';

class AdanoKaydetState {
  final String? message;

  AdanoKaydetState({this.message});
}

class AdanoKaydetCubit extends Cubit<AdanoKaydetState> {
  final AdaNoKaydetSorgu sorgu;

  AdanoKaydetCubit(this.sorgu) : super(AdanoKaydetState());

  Future<void> kaydet(String paletNo, String adaNo, String siraNo) async {
    try {
      final sicilNo = (await SharedPreferences.getInstance()).getString('kullanici_id') ?? '';
      final result = await sorgu.kaydetAdaNo(paletNo, adaNo, sicilNo, siraNo);
      emit(AdanoKaydetState(message: result));
    } catch (e) {
      emit(AdanoKaydetState(message: "Hata: $e"));
    }
  }
}