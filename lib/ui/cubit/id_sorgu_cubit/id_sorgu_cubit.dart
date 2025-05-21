import 'package:bien_proje/data/datasources/id_sorgu/id_sorgulama.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdSorguCubit extends Cubit<List<Map<String, dynamic>>?> {
  IdSorguCubit() : super(null);
  final krepo = IdSorgulama();

  Future<void> kaydetIdSorguCubit(String idNo) async {
    try {
      final veri = await krepo.idSorgula(idNo);
      emit(veri);
    } catch (e) {
      print('IdSorguCubit hata: $e');
      emit([]);
    }
  }

  void temizle() {
    emit(null);
  }
}