import 'package:bien_proje/data/datasources/ean_sorgular/ean_sorgu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/entity/ean_model/ean_model_bilgi.dart';

class EanSorguState {
  final List<EanModel> sonuclar;
  final bool loading;
  final String? hata;
  final bool sorguYapildiMi;

  EanSorguState({
    this.sonuclar = const [],
    this.loading = false,
    this.hata,
    this.sorguYapildiMi = false,
  });
}

class EanSorguCubit extends Cubit<EanSorguState> {
  final EanSorgu repo;

  EanSorguCubit(this.repo) : super(EanSorguState());

  Future<void> eanSorgula(String eanNo) async {
    emit(EanSorguState(loading: true, sorguYapildiMi: true));
    try {
      final sonuc = await repo.callEanSorgu(eanNo);
      emit(EanSorguState(sonuclar: sonuc, sorguYapildiMi: true));
    } catch (e) {
      emit(EanSorguState(hata: 'Hata: ${e.toString()}', sorguYapildiMi: true));
    }
  }

  void temizle() {
    emit(EanSorguState(
      sonuclar: [],
      loading: false,
      hata: null,
      sorguYapildiMi: false,
    ));
  }
}
