import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/ean_sorgular/ean_palet_karsılastırma_sorgu.dart';

class EanPaletKarsilastirmaState {
  final String mesaj;
  final bool hata;
  EanPaletKarsilastirmaState({required this.mesaj, required this.hata});
}

class EanPaletKarsilastirmaCubit extends Cubit<EanPaletKarsilastirmaState?> {
  final EanPaletKarsilastirmaSorgu krepo;

  EanPaletKarsilastirmaCubit(this.krepo) : super(null);

  Future<void> karsilastir(String paletId, String eanNo) async {
    final sonuc = await krepo.karsilastirEanPalet(paletId, eanNo);
    emit(sonuc);
  }
  void temizle() {
    emit(null);
  }

}
