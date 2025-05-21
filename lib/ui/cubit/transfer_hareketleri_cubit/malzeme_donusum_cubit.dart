import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/transfer_hareketleri/malzeme_donusum_sorgu.dart';

class MalzemeDonusumCubit extends Cubit<MalzemeDonusumState> {
  final MalzemeDonusumSorgu krepo;

  MalzemeDonusumCubit(this.krepo) : super(MalzemeDonusumInitial());

  Future<void> kaydetMalzemeDonusumCubit(
      String emirNo, String eskiBarkodNo, String yeniBarkodNo) async {
    emit(MalzemeDonusumLoading());
    try {
      final result = await krepo.kaydetMalzemeDonusumCubit(emirNo, eskiBarkodNo, yeniBarkodNo);
      emit(MalzemeDonusumSuccess(result));
    } catch (e) {
      print('MalzemeDonusumCubit hata: $e');
      emit(MalzemeDonusumError("Malzeme dönüşüm işlemi başarısız: $e"));
    }
  }
}

abstract class MalzemeDonusumState {}

class MalzemeDonusumInitial extends MalzemeDonusumState {}

class MalzemeDonusumLoading extends MalzemeDonusumState {}

class MalzemeDonusumSuccess extends MalzemeDonusumState {
  final String sonuc;
  MalzemeDonusumSuccess(this.sonuc);
}

class MalzemeDonusumError extends MalzemeDonusumState {
  final String hata;
  MalzemeDonusumError(this.hata);
}