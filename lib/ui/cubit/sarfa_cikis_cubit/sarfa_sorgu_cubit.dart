import 'package:bien_proje/data/datasources/sarfa_cikis_sorgu/sarfa_sorgu_sorgu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SarfaSorguState {
  final List<Map<String, String>>? results;
  final bool loading;
  final String? error;

  SarfaSorguState({this.results, this.loading = false, this.error});
}

class SarfaSorguCubit extends Cubit<SarfaSorguState> {
  final SarfaSorguSorgu repo;

  SarfaSorguCubit(this.repo) : super(SarfaSorguState());

  Future<void> sorgula(String barkodNo, String depo, String maliyetMerkezi, String miktar) async {
    emit(SarfaSorguState(loading: true));
    try {
      final result = await repo.sarfaCikisSorgu(
        barkodNo: barkodNo,
        depo: depo,
        maliyetMerkezi: maliyetMerkezi,
        miktar: miktar,
      );
      emit(SarfaSorguState(results: result));
    } catch (e) {
      emit(SarfaSorguState(error: "Sarfa çıkış sorgusu başarısız: $e"));
    }
  }
}