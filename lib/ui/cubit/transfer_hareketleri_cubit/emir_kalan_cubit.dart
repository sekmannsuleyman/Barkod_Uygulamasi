import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/transfer_hareketleri/emir_kalan_sorgu.dart';

class EmirKalanCubit extends Cubit<EmirKalanState> {
  final EmirKalanSorgu krepo;

  EmirKalanCubit(this.krepo) : super(EmirKalanInitial());

  Future<void> kaydetEmirKalanCubit(String emirNo) async {
    emit(EmirKalanLoading());
    try {
      final result = await krepo.kaydetEmirKalanCubit(emirNo);
      emit(EmirKalanSuccess(result));
    } catch (e) {
      print('EmirKalanCubit hata: $e');
      emit(EmirKalanError("Emir kalan sorgusu başarısız: $e"));
    }
  }
}

abstract class EmirKalanState {}

class EmirKalanInitial extends EmirKalanState {}

class EmirKalanLoading extends EmirKalanState {}

class EmirKalanSuccess extends EmirKalanState {
  final List<Map<String, String>> sonuc;
  EmirKalanSuccess(this.sonuc);
}

class EmirKalanError extends EmirKalanState {
  final String hata;
  EmirKalanError(this.hata);
}