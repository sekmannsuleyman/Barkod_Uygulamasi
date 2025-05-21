import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/uretim_giriss/uretim_giris_sorgu.dart';

class UretimGirisCubit extends Cubit<UretimGirisState> {
  final UretimGirisSorgu repo;

  UretimGirisCubit(this.repo) : super(UretimGirisInitial());

  Future<void> uretimGirisYap(String emirNo, String barkodNo) async {
    emit(UretimGirisLoading());

    try {
      final sessionId = await repo.login();
      if (sessionId == null) {
        emit(UretimGirisError("Hata: Sunucu ile bağlantı sağlanamadı."));
        return;
      }

      final sonuc = await repo.callIASService(sessionId, emirNo, barkodNo);
      if (sonuc == null) {
        emit(UretimGirisError("Hata: Ürün bulunamadı, lütfen geçerli bir ürün giriniz."));
      } else {
        emit(UretimGirisSuccess(sonuc));
      }
    } catch (e) {
      print('UretimGirisCubit hata: $e');
      emit(UretimGirisError("Hata: $e"));
    }
  }
}

abstract class UretimGirisState {}

class UretimGirisInitial extends UretimGirisState {}
class UretimGirisLoading extends UretimGirisState {}
class UretimGirisSuccess extends UretimGirisState {
  final String sonuc;
  UretimGirisSuccess(this.sonuc);
}
class UretimGirisError extends UretimGirisState {
  final String hata;
  UretimGirisError(this.hata);
}