import 'package:bien_proje/data/datasources/urun_id_sorgu/urun_id_sorgulama.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class UrunSorguCubit extends Cubit<List<Map<String, dynamic>>> {
  UrunSorguCubit() : super([]);
  final repo = UrunIdSorgulama();

  Future<void> urunSorgula(String urunId, bool benzerParti) async {
    try {
      final sonuc = await repo.urunSorgula(urunId, benzerParti);
      emit(sonuc);
    } catch (e) {
      emit([]); // hata durumunda boş liste
    }
  }
}
