import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/paletleme_sorgular/palet_sorgu.dart';

class PaletlemeCubit extends Cubit<PaletlemeState> {
  final PaletSorgu krepo;

  PaletlemeCubit(this.krepo) : super(PaletlemeInitial());

  Future<void> kaydetPaletlemeCubit(String kutuBarkod, String paletBarkod) async {
    emit(PaletlemeLoading());
    try {
      final result = await krepo.kaydetPaletlemeCubit(kutuBarkod, paletBarkod);
      emit(PaletlemeSuccess(result));
    } catch (e) {
      print('PaletlemeCubit hata: $e');
      // Hata mesajını temizle ve emit et
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(PaletlemeError(errorMessage));
    }
  }
}

abstract class PaletlemeState {}

class PaletlemeInitial extends PaletlemeState {}

class PaletlemeLoading extends PaletlemeState {}

class PaletlemeSuccess extends PaletlemeState {
  final String sonuc;
  PaletlemeSuccess(this.sonuc);
}

class PaletlemeError extends PaletlemeState {
  final String hata;
  PaletlemeError(this.hata);
}