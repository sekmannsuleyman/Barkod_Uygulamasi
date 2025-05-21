// lib/cubit/is_emrine_bagli_uretim_cubit/is_emrine_bagli_uretim_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/is_emrine_bagliuretim_sorgulamalar/IsEmrineBagliUretimSorgu.dart';

class IsEmrineBagliuretimCubit extends Cubit<IsEmrineBagliuretimState> {
  final IsEmrineBagliUretimGirisSorgu _repo;
  IsEmrineBagliuretimCubit(this._repo) : super(IsEmrineBagliuretimInitial());

  Future<void> kaydetIsEmrineBagliuretim(
      String isEmirNo, String barkodNo, String adaNo, String siraNo) async {
    emit(IsEmrineBagliuretimLoading());
    try {
      final sonuc = await _repo.kaydetIsEmrineBagliuretim(isEmirNo, barkodNo, adaNo, siraNo);
      emit(IsEmrineBagliuretimSuccess(sonuc));
    } catch (e) {
      print("hello");
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(IsEmrineBagliuretimError(msg));
    }
  }
}

abstract class IsEmrineBagliuretimState {}

class IsEmrineBagliuretimInitial extends IsEmrineBagliuretimState {}

class IsEmrineBagliuretimLoading extends IsEmrineBagliuretimState {}

class IsEmrineBagliuretimSuccess extends IsEmrineBagliuretimState {
  final String sonuc;
  IsEmrineBagliuretimSuccess(this.sonuc);
}

class IsEmrineBagliuretimError extends IsEmrineBagliuretimState {
  final String hata;
  IsEmrineBagliuretimError(this.hata);
}
