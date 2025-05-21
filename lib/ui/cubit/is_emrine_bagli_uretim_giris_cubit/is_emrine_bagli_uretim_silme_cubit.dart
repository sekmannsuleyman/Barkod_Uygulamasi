import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/is_emrine_bagliuretim_sorgulamalar/IsEmrineBagliUretimSilmeSorgu.dart';

class IsEmrineBagliUretimSilmeCubit extends Cubit<IsEmrineBagliUretimSilmeState> {
  final IsemrineBagliUretimSilmeSorgu krepo;

  IsEmrineBagliUretimSilmeCubit(this.krepo) : super(IsEmrineBagliUretimSilmeInitial());

  Future<void> kaydetIsEmrineBagliuretimSilme(String isEmirNo, String barkodNo) async {
    emit(IsEmrineBagliUretimSilmeLoading());
    try {
      final result = await krepo.kaydetIsEmrineBagliuretimSilme(isEmirNo, barkodNo);
      emit(IsEmrineBagliUretimSilmeSuccess(result));
    } catch (e) {
      print('IsEmrineBagliUretimSilmeCubit hata: $e');
      // Hata mesajını temizle ve emit et
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(IsEmrineBagliUretimSilmeError(errorMessage));
    }
  }
}

abstract class IsEmrineBagliUretimSilmeState {}

class IsEmrineBagliUretimSilmeInitial extends IsEmrineBagliUretimSilmeState {}

class IsEmrineBagliUretimSilmeLoading extends IsEmrineBagliUretimSilmeState {}

class IsEmrineBagliUretimSilmeSuccess extends IsEmrineBagliUretimSilmeState {
  final String sonuc;
  IsEmrineBagliUretimSilmeSuccess(this.sonuc);
}

class IsEmrineBagliUretimSilmeError extends IsEmrineBagliUretimSilmeState {
  final String hata;
  IsEmrineBagliUretimSilmeError(this.hata);
}