import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/paletleme_sorgular/palet_silme_sorgu.dart';

class PaletSilmeCubit extends Cubit<PaletSilmeState> {
  final PaletSilmeSorgu krepo;

  PaletSilmeCubit(this.krepo) : super(PaletSilmeInitial());

  Future<void> kaydetPaletSilmeCubit(String kutuBarkod) async {
    emit(PaletSilmeLoading());
    try {
      final result = await krepo.kaydetPaletSilmeCubit(kutuBarkod);
      emit(PaletSilmeSuccess(result));
    } catch (e) {
      print('PaletSilmeCubit hata: $e');
      emit(PaletSilmeError("Palet silme işlemi başarısız: $e"));
    }
  }
}

abstract class PaletSilmeState {}

class PaletSilmeInitial extends PaletSilmeState {}

class PaletSilmeLoading extends PaletSilmeState {}

class PaletSilmeSuccess extends PaletSilmeState {
  final String sonuc;
  PaletSilmeSuccess(this.sonuc);
}

class PaletSilmeError extends PaletSilmeState {
  final String hata;
  PaletSilmeError(this.hata);
}
