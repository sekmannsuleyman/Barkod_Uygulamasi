import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/sarfa_cikis_sorgu/sarfa_cikis_sorgu.dart';

class SarfaCikisCubit extends Cubit<SarfaCikisState> {
  final SarfaCikisSorgu krepo;

  SarfaCikisCubit(this.krepo) : super(SarfaCikisInitial());

  Future<void> kaydetSarfaCikisCubit(String barkodNo, String maliyetMerkezi, String depo, String miktar) async {
    emit(SarfaCikisLoading());
    try {
      final result = await krepo.kaydetSarfaCikisCubit(barkodNo, maliyetMerkezi, depo, miktar, "1");
      emit(SarfaCikisConfirm(result));
    } catch (e) {
      print('SarfaCikisCubit hata: $e');
      emit(SarfaCikisError("Sarfa çıkış işlemi başarısız: $e"));
    }
  }

  Future<void> confirmSarfaCikis(String barkodNo, String maliyetMerkezi, String depo, String miktar) async {
    emit(SarfaCikisLoading());
    try {
      final result = await krepo.kaydetSarfaCikisCubit(barkodNo, maliyetMerkezi, depo, miktar, "0");
      emit(SarfaCikisSuccess(result['sonuc'] as String)); // Map'ten String'e çeviriyoruz
    } catch (e) {
      print('SarfaCikisCubit onay hata: $e');
      emit(SarfaCikisError("Sarfa çıkış onayı başarısız: $e"));
    }
  }
}

abstract class SarfaCikisState {}

class SarfaCikisInitial extends SarfaCikisState {}

class SarfaCikisLoading extends SarfaCikisState {}

class SarfaCikisSuccess extends SarfaCikisState {
  final String sonuc;
  SarfaCikisSuccess(this.sonuc);
}

class SarfaCikisError extends SarfaCikisState {
  final String hata;
  SarfaCikisError(this.hata);
}

class SarfaCikisConfirm extends SarfaCikisState {
  final Map<String, dynamic> result;
  SarfaCikisConfirm(this.result);
}