import 'package:bien_proje/data/datasources/uretim_giriss/uretim_silme_sorgu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UretimSilmeCubit extends Cubit<UretimSilmeState> {
  final UretimSilmeSorgu repo;

  UretimSilmeCubit(this.repo) : super(UretimSilmeInitial());

  Future<void> kaydetUretimSilme(String emirNo, String barkodNo) async {
    emit(UretimSilmeLoading());
    try {
      final sonuc = await repo.kaydetUretimSilmeCubit(emirNo, barkodNo);
      if (sonuc != null) {
        if (sonuc.toLowerCase().contains("hata")) {
          throw Exception(sonuc);
        }
        emit(UretimSilmeSuccess(sonuc));
      } else {
        throw Exception("Üretim silme işlemi başarısız oldu: Sunucudan yanıt alınamadı.");
      }
    } catch (e) {
      print('UretimSilmeCubit hata: $e');
      emit(UretimSilmeError(e.toString().contains("ÜRÜN BULUNAMADI") ? "Hata: Ürün bulunamadı, lütfen geçerli bir ürün giriniz." : "Hata: $e"));
    }
  }
}

abstract class UretimSilmeState {}
class UretimSilmeInitial extends UretimSilmeState {}
class UretimSilmeLoading extends UretimSilmeState {}
class UretimSilmeSuccess extends UretimSilmeState {
  final String sonuc;
  UretimSilmeSuccess(this.sonuc);
}
class UretimSilmeError extends UretimSilmeState {
  final String hata;
  UretimSilmeError(this.hata);
}