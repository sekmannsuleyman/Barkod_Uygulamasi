import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bien_proje/data/datasources/sevkiyat_sorgular%C4%B1/sevkiyat_yukleme.dart';

class SevkiyatYuklemeState {
  final String? message;
  final String? agirlik;

  SevkiyatYuklemeState({this.message, this.agirlik});
}

class SevkiyatYuklemeCubit extends Cubit<SevkiyatYuklemeState> {
  final SevkiyatYukleme krepo;

  SevkiyatYuklemeCubit(this.krepo) : super(SevkiyatYuklemeState());

  Future<void> kaydetSevkiyatYuklemeCubit(String emirNo, String barkodNo, String sicilNo) async {
    try {
      final result = await krepo.kaydetSevkiyatYuklemeCubit(emirNo, barkodNo, sicilNo);
      emit(SevkiyatYuklemeState(message: result));
    } catch (e) {
      emit(SevkiyatYuklemeState(message: "Hata: $e"));
    }
  }

  Future<void> getAgirlik(String emirNo) async {
    try {
      final agirlik = await krepo.getAgirlik(emirNo);
      emit(SevkiyatYuklemeState(agirlik: agirlik));
    } catch (e) {
      emit(SevkiyatYuklemeState(message: "Hata: $e"));
    }
  }
}