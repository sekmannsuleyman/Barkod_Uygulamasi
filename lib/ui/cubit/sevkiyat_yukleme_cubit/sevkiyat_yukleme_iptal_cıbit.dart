import 'package:bien_proje/data/datasources/sevkiyat_sorguları/sevkiyat_yukleme_iptal_sprgu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SevkiyatYuklemeIptalState {
  final String? message;
  final bool isLoading;

  SevkiyatYuklemeIptalState({this.message, this.isLoading = false});
}

class SevkiyatYuklemeIptalCubit extends Cubit<SevkiyatYuklemeIptalState> {
  final SevkiyatYuklemeIptalSorgu krepo;

  SevkiyatYuklemeIptalCubit(this.krepo) : super(SevkiyatYuklemeIptalState());

  Future<void> kaydetSevkiyatYuklemeIptalCubit(String emirNo, String barkodNo) async {
    emit(SevkiyatYuklemeIptalState(isLoading: true));
    try {
      final result = await krepo.kaydetSevkiyatYuklemeIptalCubit(emirNo, barkodNo);
      emit(SevkiyatYuklemeIptalState(message: result, isLoading: false));
    } catch (e) {
      emit(SevkiyatYuklemeIptalState(message: "Hata: $e", isLoading: false));
    }
  }
}