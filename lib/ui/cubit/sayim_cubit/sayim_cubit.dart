import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/sayim_sorgular/sayim_sayim_sorgu.dart';

class SayimCubit extends Cubit<SayimState> {
  final SayimSayimSorgu krepo;

  SayimCubit(this.krepo) : super(SayimInitial());

  Future<void> kaydetSayimCubit(
      String adaNo,
      String siraNo,
      String barkodNo,
      String sayimNo,
      String sicilNo,
      ) async {
    emit(SayimLoading());
    try {
      final result = await krepo.kaydetSayimCubit(
        adaNo,
        siraNo,
        barkodNo,
        sayimNo,
        sicilNo,
      );
      emit(SayimSuccess(result));
    } catch (e) {
      print('SayimCubit hata: $e');
      // Hata mesajını temizle ve emit et
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(SayimError(errorMessage));
    }
  }
}

abstract class SayimState {}

class SayimInitial extends SayimState {}

class SayimLoading extends SayimState {}

class SayimSuccess extends SayimState {
  final String sonuc;
  SayimSuccess(this.sonuc);
}

class SayimError extends SayimState {
  final String hata;
  SayimError(this.hata);
}