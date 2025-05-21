import 'package:bien_proje/data/datasources/urun_id_sorgu/uretim_kismi_iptal_sorgu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UretimKismiIptalCubit extends Cubit<UretimKismiIptalState> {
  final UretimKismiIptalSorgu repo;

  UretimKismiIptalCubit(this.repo) : super(UretimKismiIptalInitial());

  Future<void> kaydetUretimKismiIptal(String belgeNo, String paletBarkodNo) async {
    emit(UretimKismiIptalLoading());
    try {
      final sonuc = await repo.kaydetUretimKismiIptalCubit(belgeNo, paletBarkodNo);
      if (sonuc != null) {
        emit(UretimKismiIptalSuccess(sonuc));
      } else {
        throw Exception("HATA:Id üretim belgelerinde bulunamadı.");
      }
    } catch (e) {
      print('UretimKismiIptalCubit hata: $e');
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(UretimKismiIptalError(errorMessage));
    }
  }
}

abstract class UretimKismiIptalState {}
class UretimKismiIptalInitial extends UretimKismiIptalState {}
class UretimKismiIptalLoading extends UretimKismiIptalState {}
class UretimKismiIptalSuccess extends UretimKismiIptalState {
  final String sonuc;
  UretimKismiIptalSuccess(this.sonuc);
}
class UretimKismiIptalError extends UretimKismiIptalState {
  final String hata;
  UretimKismiIptalError(this.hata);
}