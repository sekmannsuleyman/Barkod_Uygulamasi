import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/datasources/ambar_sayim_sorgulari/ambar_sayimlar.dart';

class AmbarSayimState {
  final String? message;

  AmbarSayimState({this.message});
}

class AmbarSayimCubit extends Cubit<AmbarSayimState> {
  final AmbarSayimSorgu sorgu;

  AmbarSayimCubit(this.sorgu) : super(AmbarSayimState());

  Future<void> kaydetAmbarSayim(
      String rafNo, String gozNo, String barkodNo, String adet, String sayimNo) async {
    try {
      final sicilNo = (await SharedPreferences.getInstance()).getString('kullanici_id') ?? '';
      final result = await sorgu.kaydetAmbarSayim(rafNo, gozNo, barkodNo, adet, sayimNo, sicilNo);
      emit(AmbarSayimState(message: result));
    } catch (e) {
      emit(AmbarSayimState(message: "Hata: $e"));
    }
  }
}